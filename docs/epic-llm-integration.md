# LLM-Powered Natural Language Interface - Brownfield Enhancement

## Epic Goal

Add an LLM-powered natural language interface to pocket-knife using RubyLLM, allowing users to ask questions like "What is 20% of 100?" while maintaining the existing fast, direct CLI for power users. This enhancement makes percentage calculations accessible through conversational AI without disrupting the zero-dependency promise for users who don't need AI features.

---

## Epic Description

### Existing System Context

- **Current relevant functionality:** Pocket-knife is a Ruby CLI percentage calculator with a single `calc` subcommand that accepts numeric arguments (e.g., `pocket-knife calc 100 20`)
- **Technology stack:** Ruby 3.2+, zero external dependencies (pure Ruby standard library), Thor-style CLI with custom argument parsing
- **Integration points:** 
  - `CLI` class handles argument parsing and command routing
  - `Calculator` class performs the actual calculation logic
  - `CalculationRequest` and `CalculationResult` handle data validation and formatting

### Enhancement Details

- **What's being added/changed:**
  - New `ask` subcommand that accepts natural language queries
  - RubyLLM gem integration with tool/function calling support
  - `PercentageCalculatorTool` class that exposes Calculator to the LLM
  - Configuration management for API keys (OpenAI, Anthropic, etc.)
  - Natural language response generation
  
- **How it integrates:**
  - New `ask` subcommand routes to LLM processing
  - LLM uses RubyLLM's Tool feature to call existing `Calculator` logic
  - Existing `calc` command remains unchanged - zero impact to current users
  - RubyLLM added as **optional** dependency (gem group or feature flag)
  - API keys configured via environment variables or config file

- **Success criteria:**
  - Users can run `pocket-knife ask "What is 20% of 100?"` and receive correct answer
  - LLM correctly extracts numbers and calls Calculator via Tool
  - Existing `calc` command performance and behavior unchanged
  - Clear error messages when API keys missing or LLM unavailable
  - Documentation covers both CLI modes (direct and natural language)

---

## Stories

### Story 1: RubyLLM Integration & Tool Definition

Set up RubyLLM gem, create configuration management for API keys, and define `PercentageCalculatorTool` that exposes the existing Calculator to the LLM as a callable tool.

**Key Tasks:**
- Add `ruby_llm` to Gemfile (optional group)
- Create configuration class for API key management
- Define `PercentageCalculatorTool < RubyLLM::Tool` with proper parameters
- Write unit tests for tool execution
- Document API key setup in README

### Story 2: Natural Language Ask Command

Implement new `ask` subcommand in CLI that accepts natural language queries, sends them to RubyLLM with the PercentageCalculatorTool, and returns formatted responses.

**Key Tasks:**
- Add `ask` subcommand to CLI class
- Implement natural language query processing
- Integrate RubyLLM chat with tool registration
- Format LLM responses for terminal output
- Add integration tests for ask command
- Handle edge cases (ambiguous queries, multiple numbers, etc.)

### Story 3: Error Handling, Fallbacks & Documentation

Implement robust error handling for missing API keys, LLM failures, and network issues. Update all documentation and help text.

**Key Tasks:**
- Graceful error handling for missing API keys
- Fallback messages suggesting direct `calc` usage
- Network timeout and retry logic
- Update `--help` text for both commands
- Add examples to README for both usage modes
- E2E tests for error scenarios
- Document optional dependency installation

---

## Compatibility Requirements

- [x] Existing `calc` command remains unchanged - zero modifications to current workflow
- [x] No database schema changes (N/A - CLI tool)
- [x] New `ask` command follows existing CLI conventions and help text patterns
- [x] Performance impact is zero for users not using `ask` command (optional dependency)
- [x] RubyLLM gem is optional - tool works without it if users only use `calc`

---

## Risk Mitigation

### Primary Risk
Adding external dependency (RubyLLM) breaks the "zero dependencies" value proposition

**Mitigation:** 
- Make RubyLLM an **optional** dependency using Bundler groups or conditional requires
- Keep `calc` command completely independent - loads zero LLM code
- Document both installation modes: minimal (calc only) and full (with AI)
- Lazy load RubyLLM only when `ask` command is used

**Rollback Plan:**
- Simply remove the `ask` subcommand and RubyLLM gem
- `calc` command is completely isolated - no rollback needed for core functionality
- Git revert is clean since all changes are additive

### Secondary Risk
API key management and security

**Mitigation:**
- Use environment variables for API keys (standard practice)
- Never log or display API keys
- Clear error messages guide users through configuration
- Document security best practices in README

---

## Definition of Done

- [ ] All 3 stories completed with acceptance criteria met
- [ ] Existing `calc` functionality verified through all existing tests (zero regressions)
- [ ] New `ask` command works with OpenAI and Anthropic (minimum 2 providers)
- [ ] Integration tests cover happy path and error scenarios
- [ ] README documentation updated with both usage modes
- [ ] Help text (`--help`) updated for both commands
- [ ] Optional dependency installation documented
- [ ] No performance degradation for `calc` command
- [ ] API key configuration clearly documented

---

## Story Manager Handoff

**Story Manager Instructions:**

Please develop detailed user stories for this brownfield epic. Key considerations:

- This is an enhancement to an existing Ruby CLI tool using **Ruby 3.2+, standard library only**
- Integration points: 
  - `CLI` class for routing new `ask` subcommand
  - `Calculator` class via RubyLLM Tool definition
  - Existing command parsing patterns must be followed
- Existing patterns to follow: 
  - CLI help text and error formatting
  - Input validation and error handling style
  - Test structure (RSpec with unit/integration/e2e folders)
- Critical compatibility requirements:
  - RubyLLM must be **optional** dependency
  - `calc` command must remain zero-dependency
  - Existing tests must pass without modification
  - Performance of `calc` must not degrade
- Each story must include verification that existing functionality remains intact

The epic should maintain the tool's speed and simplicity while adding conversational AI as an opt-in feature.

---

## Technical Notes

### RubyLLM Tool Pattern

```ruby
class PercentageCalculatorTool < RubyLLM::Tool
  description "Calculate percentage of a number"
  param :base, description: "The base amount"
  param :percentage, description: "The percentage to calculate"

  def execute(base:, percentage:)
    request = CalculationRequest.new(base, percentage)
    result = Calculator.calculate(request)
    result.value
  end
end
```

### Configuration Approach

```ruby
# config/ruby_llm_config.rb or lib/pocket_knife/llm_config.rb
RubyLLM.configure do |config|
  config.openai_api_key = ENV['OPENAI_API_KEY']
  config.anthropic_api_key = ENV['ANTHROPIC_API_KEY']
end
```

### Command Structure

```bash
# Existing (unchanged)
pocket-knife calc 100 20

# New natural language interface
pocket-knife ask "What is 20% of 100?"
pocket-knife ask "Calculate 15 percent of 200"
pocket-knife ask "How much is a 20% tip on $45.50?"
```

---

**Created:** November 5, 2025  
**Status:** Ready for Story Development  
**Epic Owner:** Product Manager (John)
