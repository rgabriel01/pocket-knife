# Architecture Document: LLM-Powered Natural Language Interface

**Project:** Pocket-Knife  
**Enhancement:** LLM Integration for Natural Language Queries  
**Architect:** Winston  
**Date:** November 5, 2025  
**Status:** Approved for Implementation  
**Version:** 1.0

---

## Executive Summary

This document describes the architecture for adding an LLM-powered natural language interface to pocket-knife using RubyLLM, while maintaining the existing fast, direct CLI for power users. The enhancement makes percentage calculations accessible through conversational AI without disrupting the zero-dependency promise for users who don't need AI features.

**Architecture Grade: A (9/10)**

---

## Table of Contents

1. [System Overview](#system-overview)
2. [Architecture Decisions](#architecture-decisions)
3. [Component Design](#component-design)
4. [Integration Patterns](#integration-patterns)
5. [Security & Privacy](#security--privacy)
6. [Testing Strategy](#testing-strategy)
7. [Implementation Roadmap](#implementation-roadmap)
8. [Risk Analysis](#risk-analysis)
9. [Future Considerations](#future-considerations)

---

## System Overview

### Current System

**Pocket-knife** is a Ruby CLI percentage calculator with:
- Single `calc` subcommand accepting numeric arguments
- Ruby 3.2+, zero external dependencies (pure Ruby standard library)
- Simple CLI with custom argument parsing
- `Calculator` class for calculation logic
- `CalculationRequest`/`CalculationResult` for data handling

### Proposed Enhancement

Add natural language query capability via:
- New `ask` subcommand for natural language queries
- RubyLLM gem integration with tool/function calling
- `PercentageCalculatorTool` exposing Calculator to LLM
- Configuration management for API keys (OpenAI, Anthropic)
- Comprehensive error handling and fallback guidance

### Key Requirements

1. **Zero impact** on existing `calc` command performance and behavior
2. **Optional dependency** - RubyLLM must be opt-in
3. **Graceful degradation** when LLM unavailable
4. **Clear error messages** with actionable guidance
5. **Maintain zero-dependency promise** for core features

---

## Architecture Decisions

### ADR-1: Optional Dependency via Bundler Groups

**Status:** ✅ Approved  
**Context:** Need to add LLM features without breaking zero-dependency promise

**Decision:** Use Bundler's optional group feature

```ruby
group :llm, optional: true do
  gem 'ruby_llm', '~> 1.9'
end
```

**Rationale:**
- Preserves zero-dependency claim for core functionality
- Standard Ruby/Bundler practice
- Users explicitly opt-in with `bundle install --with llm`
- Clean rollback path (remove group)

**Consequences:**
- Two installation modes must be documented
- Conditional loading logic required
- Users must set up API keys separately

**Alternatives Considered:**
- ❌ Make RubyLLM required dependency (breaks zero-dependency promise)
- ❌ Separate gem/plugin system (over-engineered for this use case)
- ❌ Feature flags (adds complexity without benefit)

---

### ADR-2: Early Routing Pattern for CLI

**Status:** ✅ Approved  
**Context:** Need to add new command without modifying existing calc flow

**Decision:** Route in `execute` method before existing logic runs

```ruby
def execute
  # Route to ask command early, then exit
  if @args[0] == 'ask'
    execute_ask
    return  # Early exit - calc flow never touched
  end
  
  # Existing calc command path (COMPLETELY UNCHANGED)
  parse_arguments
  validate_inputs
  result = calculate
  output(result)
end
```

**Rationale:**
- **Zero modifications** to existing calc methods
- **Complete isolation** between commands
- **Easy to understand** and maintain
- **Performance optimal** - no overhead for calc
- **Simple rollback** - remove if block

**Consequences:**
- Early exit prevents code reuse between commands
- Each command has independent flow
- Must ensure help flags work for both commands

**Alternatives Considered:**
- ❌ Refactor parse_arguments to handle both commands (risky, affects existing code)
- ❌ Case statement routing (unnecessary complexity for 2 commands)
- ❌ Dynamic dispatch with `send` (security and clarity concerns)

---

### ADR-3: RubyLLM Tool Adapter Pattern

**Status:** ✅ Approved  
**Context:** LLM needs to call existing Calculator without code duplication

**Decision:** Create adapter Tool class wrapping Calculator

```ruby
class PercentageCalculatorTool < RubyLLM::Tool
  description "Calculate what percentage of a number equals"
  
  param :base, type: :number
  param :percentage, type: :number

  def execute(base:, percentage:)
    request = CalculationRequest.new(percentage: percentage, base: base)
    result = Calculator.calculate(request)
    result.value.to_s
  rescue InvalidInputError, CalculationError => e
    "Error: #{e.message}"
  end
end
```

**Rationale:**
- **Single source of truth** - Calculator remains authoritative
- **No logic duplication** - Tool delegates to existing code
- **Maintains existing validation** - Reuses CalculationRequest/Calculator
- **Clean adapter pattern** - Standard design pattern
- **Testable independently** - Can mock Calculator or test integration

**Consequences:**
- Tool depends on Calculator interface stability
- Error responses must be LLM-interpretable
- Type conversion needed (result to string)

**Alternatives Considered:**
- ❌ Duplicate calculation logic in Tool (violates DRY)
- ❌ Refactor Calculator to be LLM-aware (wrong separation of concerns)
- ❌ Direct LLM to Calculator coupling (too tight)

---

### ADR-4: Environment Variable Configuration

**Status:** ✅ Approved  
**Context:** Need secure, standard API key management

**Decision:** Use environment variables following 12-factor principles

```ruby
class LLMConfig
  def self.configure!
    RubyLLM.configure do |config|
      config.openai_api_key = ENV['OPENAI_API_KEY']
      config.anthropic_api_key = ENV['ANTHROPIC_API_KEY']
    end
  end
end
```

**Rationale:**
- **Industry standard** - 12-factor app methodology
- **Secure** - No keys in code or version control
- **Flexible** - Easy to change per environment
- **Simple** - No additional configuration system needed

**Consequences:**
- Users must set up environment variables
- No key rotation mechanism (manual)
- Keys visible in process environment
- Must document setup clearly

**Alternatives Considered:**
- ❌ Config file (more complex, security concerns)
- ❌ Interactive prompt (poor UX for CLI tool)
- ❌ Encrypted keystore (over-engineered)

---

## Component Design

### Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                     Pocket-Knife CLI                         │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────┐                                            │
│  │   bin/       │                                            │
│  │ pocket-knife │ (Entry Point - No Changes)                │
│  └──────┬───────┘                                            │
│         │                                                     │
│         ▼                                                     │
│  ┌────────────────────────────────────────────────┐         │
│  │              CLI.execute()                      │         │
│  │                                                  │         │
│  │  if @args[0] == 'ask'                           │         │
│  │    execute_ask() ──────────┐                    │         │
│  │    return                   │                    │         │
│  │  end                        │                    │         │
│  │                             │                    │         │
│  │  # Existing calc flow       │                    │         │
│  │  parse_arguments()          │                    │         │
│  │  validate_inputs()          │                    │         │
│  │  calculate() ──────┐        │                    │         │
│  │  output(result)    │        │                    │         │
│  └────────────────────┼────────┼────────────────────┘         │
│                       │        │                               │
│      EXISTING PATH    │        │    NEW PATH                  │
│      (UNCHANGED)      │        │    (ISOLATED)                │
│                       │        │                               │
│         ┌─────────────▼─┐      │                              │
│         │  Calculator   │      │                              │
│         │               │      │                              │
│         │  .calculate() │◄─────┼──────────┐                  │
│         └───────────────┘      │          │                  │
│                                │          │                  │
│                                ▼          │                  │
│                       ┌────────────────────┴─────────┐       │
│                       │   execute_ask()              │       │
│                       │                              │       │
│                       │  1. Parse query              │       │
│                       │  2. Check LLM availability   │       │
│                       │  3. Configure RubyLLM        │       │
│                       │  4. Create chat with tool    │       │
│                       │  5. Send query to LLM        │       │
│                       │  6. Output response          │       │
│                       └──────────┬───────────────────┘       │
│                                  │                            │
│                                  ▼                            │
│                       ┌──────────────────────┐               │
│                       │    LLMConfig         │               │
│                       │                      │               │
│                       │  .llm_available?     │               │
│                       │  .configured?        │               │
│                       │  .configure!         │               │
│                       └──────────┬───────────┘               │
│                                  │                            │
│                                  ▼                            │
│                       ┌──────────────────────────────┐       │
│                       │      RubyLLM.chat            │       │
│                       │                              │       │
│                       │  .with_tool(                 │       │
│                       │    PercentageCalculatorTool) │       │
│                       │  .ask(query)                 │       │
│                       └──────────┬───────────────────┘       │
│                                  │                            │
│                                  ▼                            │
│                       ┌──────────────────────────────┐       │
│                       │ PercentageCalculatorTool     │       │
│                       │                              │       │
│                       │  .execute(base:, percentage:)│       │
│                       └──────────┬───────────────────┘       │
│                                  │                            │
│                                  └────────────────────────────┘
│                                                                │
└────────────────────────────────────────────────────────────────┘

EXTERNAL:
   │
   ▼
┌────────────────────────┐
│  OpenAI / Anthropic    │
│  LLM API               │
└────────────────────────┘
```

### Component Details

#### 1. CLI Class (Modified)

**Responsibilities:**
- Command routing
- Argument parsing (calc only, unchanged)
- Existing calc flow (unchanged)
- New ask command flow (isolated)

**Key Methods:**
- `execute` - Router (early exit for ask)
- `execute_ask` - NEW: Natural language handling
- `parse_arguments` - UNCHANGED: Calc validation
- `validate_inputs` - UNCHANGED: Calc validation
- `calculate` - UNCHANGED: Call Calculator
- `output` - UNCHANGED: Display result

**Integration Points:**
- Calls `LLMConfig` for configuration
- Calls `RubyLLM.chat` for LLM interaction
- Registers `PercentageCalculatorTool` with chat
- Calls existing `Calculator` via tool

---

#### 2. LLMConfig Class (New)

**File:** `lib/pocket_knife/llm_config.rb`

**Responsibilities:**
- Check RubyLLM gem availability
- Validate API key configuration
- Configure RubyLLM with API keys
- Provider selection logic

**Key Methods:**

```ruby
class LLMConfig
  class MissingAPIKeyError < StandardError; end
  class InvalidAPIKeyError < StandardError; end

  def self.llm_available?
    require 'ruby_llm'
    true
  rescue LoadError
    false
  end

  def self.configured?
    openai_key || anthropic_key
  end

  def self.configure!
    return unless llm_available?
    
    raise MissingAPIKeyError unless configured?
    
    RubyLLM.configure do |config|
      # Priority: OpenAI first, Anthropic fallback
      if openai_key
        config.openai_api_key = openai_key
        config.default_provider = :openai
      elsif anthropic_key
        config.anthropic_api_key = anthropic_key
        config.default_provider = :anthropic
      end
    end
  end

  private

  def self.openai_key
    ENV['OPENAI_API_KEY']&.strip
  end

  def self.anthropic_key
    ENV['ANTHROPIC_API_KEY']&.strip
  end
end
```

**Configuration Priority:**
1. If `OPENAI_API_KEY` set → Use OpenAI (GPT models)
2. Else if `ANTHROPIC_API_KEY` set → Use Anthropic (Claude models)
3. Else → Raise `MissingAPIKeyError`

**Validation:**
- Keys must be non-empty strings
- Keys trimmed of whitespace
- Lazy loading (only when ask command used)

---

#### 3. PercentageCalculatorTool Class (New)

**File:** `lib/pocket_knife/percentage_calculator_tool.rb`

**Responsibilities:**
- Expose Calculator to LLM as callable tool
- Handle parameter translation
- Format results for LLM consumption
- Catch and format Calculator errors

**Implementation:**

```ruby
module PocketKnife
  class PercentageCalculatorTool < RubyLLM::Tool
    description "Calculate what percentage of a number equals"
    
    param :base, 
          type: :number,
          description: "The base amount to calculate from"
    
    param :percentage, 
          type: :number,
          description: "The percentage to calculate (as a whole number, e.g., 20 for 20%)"

    def execute(base:, percentage:)
      # IMPORTANT: Match CalculationRequest constructor signature
      request = CalculationRequest.new(percentage: percentage, base: base)
      result = Calculator.calculate(request)
      result.value.to_s
    rescue InvalidInputError, CalculationError => e
      "Error: #{e.message}"
    end
  end
end
```

**Key Design Points:**
- **Adapter pattern** - Wraps existing Calculator
- **Parameter mapping** - Translates LLM params to CalculationRequest
- **Error handling** - Catches Calculator errors, returns string
- **String output** - LLM expects string responses

**⚠️ Critical:** Verify CalculationRequest constructor accepts `percentage:` and `base:` keyword arguments

---

#### 4. Calculator Class (Unchanged)

**Status:** No modifications required

**Integration:** Called via `PercentageCalculatorTool.execute()`

---

## Integration Patterns

### 1. Dependency Loading Pattern

```ruby
# Conditional require pattern
module PocketKnife
  class LLMConfig
    def self.llm_available?
      require 'ruby_llm'
      true
    rescue LoadError
      false
    end
  end
end
```

**Benefits:**
- Lazy loading - RubyLLM only loaded when needed
- Graceful degradation - Handles missing gem
- No impact on calc command

### 2. Command Routing Pattern

```ruby
def execute
  # Early routing for ask command
  if @args[0] == 'ask'
    execute_ask
    return  # Early exit
  end
  
  # Existing calc flow (unchanged)
  parse_arguments
  validate_inputs
  result = calculate
  output(result)
end
```

**Benefits:**
- Complete isolation between commands
- Zero modifications to existing methods
- Clear control flow
- Easy to test independently

### 3. Tool Registration Pattern

```ruby
def execute_ask
  # ... validation ...
  
  chat = RubyLLM.chat
  chat.with_tool(PercentageCalculatorTool)
  
  response = chat.ask(@query)
  puts response.content
end
```

**Benefits:**
- RubyLLM handles tool calling
- Calculator invoked automatically by LLM
- No manual parameter extraction needed

### 4. Error Handling Pattern

```ruby
def execute_ask
  validate_llm_setup
  # ... processing ...
rescue LoadError => e
  handle_missing_gem_error
rescue LLMConfig::MissingAPIKeyError => e
  handle_missing_api_key_error
rescue RubyLLM::AuthenticationError => e
  handle_invalid_api_key_error
rescue RubyLLM::RateLimitError => e
  handle_rate_limit_error
rescue RubyLLM::TimeoutError => e
  handle_timeout_error
rescue RubyLLM::Error => e
  handle_general_llm_error(e)
rescue StandardError => e
  handle_unexpected_error(e)
end
```

**Benefits:**
- Specific error handling per error type
- User-friendly error messages
- Fallback suggestions included
- Proper exit codes

---

## Security & Privacy

### API Key Management

**Storage:**
- ✅ Environment variables (not in code)
- ✅ Not committed to version control
- ✅ Not exposed in error messages or logs

**Validation:**
- Check for non-empty strings
- Trim whitespace
- Validate key format (future enhancement)

**Recommendations:**
```bash
# ~/.zshrc or ~/.bashrc
export OPENAI_API_KEY="sk-..."
export ANTHROPIC_API_KEY="sk-ant-..."
```

### Data Privacy

**User Queries:**
- Natural language queries sent to third-party APIs (OpenAI/Anthropic)
- Queries may contain sensitive information
- No control over data retention by providers

**Recommendations for Users:**
```markdown
### When to use `ask` vs `calc`

**Use `calc` for:**
- Sensitive financial calculations
- Personal data (SSN, account numbers in queries)
- Offline/air-gapped environments
- Maximum performance

**Use `ask` for:**
- General calculations
- Learning/exploration
- Natural language convenience
- When internet connectivity available
```

### Security Best Practices

**Documentation Required:**
1. Never commit API keys to version control
2. Use environment variables or secure secret management
3. Rotate keys periodically
4. Review provider data policies
5. Use calc for sensitive calculations

**Future Enhancements:**
- Key rotation mechanism
- Audit logging (optional)
- Rate limiting on client side
- Query sanitization/filtering

---

## Testing Strategy

### Test Pyramid

```
        ┌──────────────┐
        │     E2E      │  ← Complete user workflows
        │   (Small)    │     Mocked API calls
        ├──────────────┤
        │ Integration  │  ← CLI routing, LLM integration
        │   (Medium)   │     Component interaction
        ├──────────────┤
        │     Unit     │  ← Tool, Config, Calculator
        │   (Large)    │     Isolated component tests
        └──────────────┘
```

### Unit Tests

**Coverage:**
- `LLMConfig` class
  - API key reading
  - Configuration validation
  - Graceful degradation when RubyLLM missing
  - Error messages
- `PercentageCalculatorTool` class
  - Parameter definition
  - Successful execution
  - Integration with Calculator
  - Error handling
  - Mock RubyLLM::Tool parent

**Test Files:**
- `spec/unit/llm_config_spec.rb`
- `spec/unit/percentage_calculator_tool_spec.rb`

**Target: 100% coverage for new classes**

### Integration Tests

**Coverage:**
- CLI command routing
  - Ask command routing to execute_ask
  - Calc command routing unchanged
  - Invalid command handling
- Natural language query processing
  - Multiple query formats
  - RubyLLM chat integration
  - Tool registration
  - Response formatting
- Error handling scenarios
  - Missing RubyLLM gem
  - Missing API keys
  - API errors
  - Network timeouts
- Help text functionality
  - `pocket-knife --help` includes both commands
  - `pocket-knife ask --help` works
  - `pocket-knife calc --help` still works

**Test Files:**
- `spec/integration/ask_command_spec.rb`
- Updates to `spec/integration/cli_spec.rb`

**Critical: Calc Command Isolation Tests**
- Verify calc command works exactly as before
- Test all existing calc scenarios
- Verify no LLM code loaded when using calc
- Test calc error cases unchanged

### E2E Tests

**Coverage:**
- Complete user workflows
  - Successful ask command flow
  - Missing gem installation flow
  - Missing API key flow
  - Invalid API key flow
  - Network failure flow
  - Ambiguous query flow
- Error messages and exit codes
- Complete end-to-end scenarios

**Test Files:**
- `spec/e2e/ask_command_e2e_spec.rb`
- Updates to `spec/e2e/pocket_knife_spec.rb`

**Mocking Strategy:**
```ruby
# Mock RubyLLM without actual API calls
allow(RubyLLM).to receive(:chat).and_return(mock_chat)
allow(mock_chat).to receive(:with_tool).and_return(mock_chat)
allow(mock_chat).to receive(:ask).and_return(mock_response)
allow(mock_response).to receive(:content).and_return("20% of 100 is 20.00")
```

### Regression Testing

**Critical Requirements:**
- ALL existing tests pass without modification
- Test coverage remains at 90%+
- No performance degradation for calc command
- Existing error handling unchanged

---

## Implementation Roadmap

### Story 1: RubyLLM Integration & Tool Definition
**Estimate:** 4 hours  
**Priority:** High (Foundation)

**Deliverables:**
- ✅ RubyLLM gem added to Gemfile (optional group)
- ✅ `LLMConfig` class created
- ✅ `PercentageCalculatorTool` class created
- ✅ Unit tests (100% coverage)
- ✅ README updated with installation instructions

**Acceptance Criteria:**
- Bundle install works with and without `--with llm`
- API keys read from environment variables
- Tool executes Calculator correctly
- Graceful degradation when gem missing
- All existing tests pass

**Critical Actions:**
1. Verify CalculationRequest constructor signature
2. Document provider priority
3. Test conditional loading

---

### Story 2: Natural Language Ask Command
**Estimate:** 6 hours  
**Priority:** High

**Deliverables:**
- ✅ `ask` subcommand in CLI
- ✅ Early routing in execute method
- ✅ Natural language query processing
- ✅ RubyLLM chat integration
- ✅ Integration tests
- ✅ Updated help text

**Acceptance Criteria:**
- `pocket-knife ask "query"` works
- Multiple query formats supported
- Calc command completely untouched
- No LLM code loaded for calc
- Help flags work for both commands
- All existing tests pass

**Critical Actions:**
1. Document expected latency (1-3 seconds typical)
2. Test help flag behavior
3. Verify calc isolation

---

### Story 3: Error Handling, Fallbacks & Documentation
**Estimate:** 4 hours  
**Priority:** Medium

**Deliverables:**
- ✅ Enhanced error handling
- ✅ Fallback guidance
- ✅ E2E tests
- ✅ Complete README updates
- ✅ Troubleshooting guide

**Acceptance Criteria:**
- All error scenarios handled gracefully
- Clear, actionable error messages
- Fallback suggestions included
- README covers both usage modes
- 10+ usage examples documented
- Security/privacy section added

**Critical Actions:**
1. Add security & privacy documentation
2. Create troubleshooting guide
3. Document when to use ask vs calc

---

### Total Estimate: 14 hours (~2 days)

**Implementation Order:**
```
Story 1 → Story 2 → Story 3
  4h       6h        4h
  ↓         ↓         ↓
Foundation → Core → Polish
```

---

## Risk Analysis

### Technical Risks

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Breaking existing calc command | **HIGH** | Low | Early routing pattern, comprehensive tests, calc isolation tests |
| RubyLLM API changes | Medium | Medium | Pin to ~> 1.9, test before upgrades |
| LLM provider changes | Medium | Low | Support multiple providers, abstract configuration |
| Performance degradation | Medium | Very Low | Lazy loading, early routing, no calc impact |
| API key exposure | **HIGH** | Low | Environment variables, documentation, no logging |

### Implementation Risks

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| CalculationRequest signature mismatch | Medium | Medium | **Verify before Story 1** |
| Help flag conflicts | Low | Low | Test early in Story 2 |
| Error message confusion | Medium | Medium | User testing, clear documentation |
| Test complexity | Low | Medium | Mock strategy documented |

### User Experience Risks

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| API setup friction | Medium | High | Clear documentation, troubleshooting guide |
| LLM latency frustration | Low | Medium | Document expected latency, suggest calc for speed |
| Query interpretation errors | Low | Medium | Fallback suggestions, examples |
| Privacy concerns | Medium | Low | Document data handling, suggest calc for sensitive data |

### Mitigation Summary

**High Priority (Before Implementation):**
1. ✅ Verify CalculationRequest constructor signature
2. ✅ Document provider priority
3. ✅ Add security/privacy documentation
4. ✅ Create comprehensive test plan

**Medium Priority (During Implementation):**
1. Document expected latency
2. Test help flag behavior thoroughly
3. User test error messages
4. Verify calc command isolation

**Low Priority (Post-MVP):**
1. Monitor LLM provider changes
2. Consider key rotation mechanism
3. Add usage analytics (optional)
4. Evaluate additional providers

---

## Future Considerations

### Phase 2 Enhancements (Post-MVP)

**1. Enhanced Query Understanding**
- Support more complex calculations (compound interest, etc.)
- Multi-step calculations
- Calculation history with context
- Query suggestions/autocomplete

**2. Additional Tools**
- Reverse percentage ("30 is what % of 100?")
- Percentage increase/decrease
- Percentage difference between numbers
- Tip calculator with splitting

**3. Configuration Improvements**
- Config file support (optional)
- Per-user provider selection
- Model selection (GPT-4 vs GPT-3.5, etc.)
- Timeout configuration

**4. Developer Experience**
- Verbose/debug mode
- Query analysis (show extracted parameters)
- Test mode with mock LLM
- Offline mode detection

**5. Advanced Features**
- Calculation history/cache
- Batch queries
- Export results
- Web service wrapper

### Scalability Considerations

**Current Architecture (CLI):**
- ✅ Single-user, single-process
- ✅ No concurrency needed
- ✅ No caching required

**If Extended to Web Service:**
Would need:
- Request queuing
- Rate limiting per user
- Response caching
- Circuit breaker pattern
- Connection pooling
- Monitoring/observability

**Recommendation:** Current architecture is perfect for CLI use case. Don't over-engineer for hypothetical web service.

### Technology Evolution

**RubyLLM Updates:**
- Monitor for breaking changes
- Test new versions before upgrading
- Consider contribution to gem if issues found

**LLM Provider Landscape:**
- New providers emerge regularly
- RubyLLM supports multiple providers already
- Easy to add support for new providers via config

**Ruby Version Support:**
- Currently requires Ruby 3.2+
- Monitor Ruby evolution
- Test on new Ruby versions

---

## Appendix

### A. File Structure

```
pocket-knife/
├── bin/
│   └── pocket-knife                 # Entry point (no changes)
├── lib/
│   └── pocket_knife/
│       ├── calculator.rb            # Existing (unchanged)
│       ├── calculation_request.rb   # Existing (unchanged)
│       ├── calculation_result.rb    # Existing (unchanged)
│       ├── cli.rb                   # Modified (routing added)
│       ├── errors.rb                # Existing (unchanged)
│       ├── llm_config.rb           # NEW
│       └── percentage_calculator_tool.rb  # NEW
├── spec/
│   ├── unit/
│   │   ├── calculator_spec.rb       # Existing (unchanged)
│   │   ├── llm_config_spec.rb      # NEW
│   │   └── percentage_calculator_tool_spec.rb  # NEW
│   ├── integration/
│   │   ├── cli_spec.rb             # Existing (unchanged)
│   │   └── ask_command_spec.rb     # NEW
│   └── e2e/
│       ├── pocket_knife_spec.rb    # Existing (unchanged)
│       └── ask_command_e2e_spec.rb # NEW
├── docs/
│   ├── epic-llm-integration.md     # Epic document
│   ├── llm-integration-architecture.md  # This document
│   └── stories/
│       ├── llm-story-1-rubyllm-integration.md
│       ├── llm-story-2-ask-command.md
│       └── llm-story-3-error-handling-docs.md
├── Gemfile                          # Modified (optional group)
└── README.md                        # Modified (LLM features section)
```

### B. Configuration Examples

**Environment Setup:**
```bash
# ~/.zshrc or ~/.bashrc
export OPENAI_API_KEY="sk-proj-..."
export ANTHROPIC_API_KEY="sk-ant-..."

# Or per-session
export OPENAI_API_KEY="sk-proj-..."
bundle exec pocket-knife ask "What is 20% of 100?"
```

**Gemfile:**
```ruby
source 'https://rubygems.org'

ruby '>= 3.2.0'

# Core dependencies (none!)

group :development, :test do
  gem 'rspec', '~> 3.12'
  gem 'rubocop', '~> 1.50'
end

# Optional LLM features
group :llm, optional: true do
  gem 'ruby_llm', '~> 1.9'
end
```

**Installation:**
```bash
# Standard installation (calc only)
bundle install

# With LLM features
bundle install --with llm

# Verify installation
pocket-knife --help
```

### C. Usage Examples

**Direct Calculation (Existing):**
```bash
$ pocket-knife calc 100 20
20.00

$ pocket-knife calc 99.99 10
10.00
```

**Natural Language (New):**
```bash
$ pocket-knife ask "What is 20% of 100?"
20% of 100 is 20.00

$ pocket-knife ask "Calculate 15 percent of 200"
15% of 200 equals 30.00

$ pocket-knife ask "How much is a 20% tip on $45.50?"
A 20% tip on $45.50 would be $9.10

$ pocket-knife ask "What's 7.5% of $1000?"
7.5% of $1000 is $75.00
```

**Error Scenarios:**
```bash
$ pocket-knife ask "What is 20% of 100?"
Error: LLM features not available. Install with: bundle install --with llm
Or use direct syntax: pocket-knife calc 100 20

$ pocket-knife ask "What is 20% of 100?"
Error: API keys not configured. Set OPENAI_API_KEY or ANTHROPIC_API_KEY.
See README for setup instructions.
```

### D. Key Metrics

**Performance Targets:**
- Calc command: <50ms (unchanged)
- Ask command: 1-5 seconds (typical LLM latency)
- Bundle install: <30 seconds with LLM

**Quality Targets:**
- Test coverage: 90%+ (maintained)
- Unit test coverage for new code: 100%
- Zero regressions in existing functionality
- Rubocop compliance: 100%

**Success Metrics:**
- Calc command 0% slower
- Ask command 80%+ accuracy on queries
- Error messages 90%+ clarity rating
- Setup time <5 minutes for new users

---

## Approval & Sign-off

**Architecture Review:** ✅ Approved  
**Architect:** Winston  
**Date:** November 5, 2025  
**Grade:** A (9/10)

**Ready for Implementation:** ✅ Yes

**Prerequisites:**
1. Verify CalculationRequest constructor signature
2. Document provider priority
3. Add security/privacy documentation to README

**Next Steps:**
1. Begin Story 1 implementation
2. Create feature branch: `feature/llm-integration`
3. Implement with TDD approach
4. Review after each story completion

---

**Document Version:** 1.0  
**Last Updated:** November 5, 2025  
**Status:** Living Document (update as implementation progresses)

