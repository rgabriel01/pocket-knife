# Story 1: RubyLLM Integration & Tool Definition - Brownfield Addition

**Epic:** LLM-Powered Natural Language Interface  
**Story ID:** LLM-1  
**Estimate:** 4 hours  
**Priority:** High (Foundation for Epic)

---

## User Story

As a **pocket-knife developer**,  
I want **RubyLLM gem integrated with a Tool that exposes the Calculator**,  
So that **the LLM can call our existing calculation logic to answer natural language queries**.

---

## Story Context

### Existing System Integration

- **Integrates with:** `Calculator` class and `CalculationRequest`/`CalculationResult` classes
- **Technology:** Ruby 3.2+, RSpec testing framework, Bundler for dependency management
- **Follows pattern:** Module-based organization under `lib/pocket_knife/`, unit tests in `spec/unit/`
- **Touch points:** 
  - `lib/pocket_knife.rb` (main module require file)
  - `lib/pocket_knife/calculator.rb` (calculation logic)
  - `Gemfile` (new optional dependency group)
  - New configuration file for API keys

---

## Acceptance Criteria

### Functional Requirements

1. **RubyLLM Gem Added**
   - `ruby_llm` gem added to Gemfile in optional `:llm` group
   - Gem version pinned to `~> 1.9` (latest stable)
   - Bundle install succeeds with and without `--with llm` flag
   - Zero impact on default bundle (without LLM group)

2. **Configuration Management Created**
   - New `lib/pocket_knife/llm_config.rb` file created
   - Reads API keys from environment variables:
     - `OPENAI_API_KEY`
     - `ANTHROPIC_API_KEY` (optional fallback)
   - Provides clear error messages when no API keys configured
   - Validates API key format (non-empty strings)
   - Configuration lazy-loaded (only when LLM features used)

3. **PercentageCalculatorTool Defined**
   - New `lib/pocket_knife/percentage_calculator_tool.rb` created
   - Inherits from `RubyLLM::Tool`
   - Defines two parameters:
     - `base`: The base amount (numeric)
     - `percentage`: The percentage to calculate (numeric)
   - `execute` method creates `CalculationRequest` and calls `Calculator.calculate`
   - Returns formatted result value (string with 2 decimal places)
   - Handles Calculator errors gracefully

### Integration Requirements

4. **Existing Calculator Untouched**
   - `Calculator`, `CalculationRequest`, and `CalculationResult` classes remain unchanged
   - All existing unit tests pass without modification
   - No new dependencies loaded when using `calc` command

5. **Module Loading Pattern**
   - Tool and config files use conditional require (check for RubyLLM constant)
   - Graceful degradation when RubyLLM not installed
   - Clear error message if `ask` attempted without gem installed

6. **Existing Patterns Followed**
   - Ruby style guide compliance (Rubocop passes)
   - Module namespacing under `PocketKnife::`
   - Frozen string literals at top of files
   - Documentation comments for all public methods

### Quality Requirements

7. **Unit Tests Created**
   - New `spec/unit/percentage_calculator_tool_spec.rb`
   - Tests tool parameter definition
   - Tests successful calculation execution
   - Tests error handling (invalid inputs, Calculator errors)
   - Tests integration with existing Calculator logic
   - Mock RubyLLM::Tool parent class
   - 100% code coverage for new classes

8. **Documentation Updated**
   - README updated with "Optional LLM Features" section
   - Installation instructions for both modes:
     - Standard: `bundle install` (calc only)
     - With LLM: `bundle install --with llm`
   - API key setup documented
   - Environment variable examples provided

9. **No Regressions**
   - All existing tests pass (unit, integration, e2e)
   - `pocket-knife calc` command still works
   - No performance degradation for calc command
   - Test coverage remains at 90%+

---

## Dev Notes

### CRITICAL Pre-Implementation Verification

**⚠️ MUST VERIFY BEFORE CODING:**

1. **CalculationRequest Constructor Signature**
   ```ruby
   # Current CLI usage (verify this matches)
   # File: lib/pocket_knife/cli.rb, line ~105
   request = CalculationRequest.new(percentage: @percentage, base: @base)
   ```
   
   **ACTION:** Open `lib/pocket_knife/calculation_request.rb` and verify the constructor accepts `percentage:` and `base:` as keyword arguments. If signature is different, update Tool implementation to match.

2. **Current Calculator Behavior**
   - Review `lib/pocket_knife/calculator.rb` to understand existing calculation logic
   - Review `lib/pocket_knife/errors.rb` to understand error types: `InvalidInputError`, `CalculationError`
   - No modifications to these files allowed in this story

3. **Existing Test Patterns**
   - Review `spec/unit/calculator_spec.rb` for test structure
   - Review `spec/spec_helper.rb` for RSpec configuration
   - Follow existing mocking patterns

### Provider Priority Documentation

**When both API keys are set:**
- **Priority Order:** OpenAI first, Anthropic fallback
- **Implementation:** Check `OPENAI_API_KEY` first, use if present; else check `ANTHROPIC_API_KEY`
- **Document in:** README and inline comments in `LLMConfig`

### Rubocop Configuration

**Existing Standards:**
- Frozen string literal required: `# frozen_string_literal: true`
- Module namespacing: `module PocketKnife ... end`
- Method documentation: RDoc style comments for public methods
- Line length: 120 characters (check `.rubocop.yml`)

Run `bundle exec rubocop` after each file creation to ensure compliance.

---

## Technical Notes

### Integration Approach

**File Structure:**
```
lib/pocket_knife/
├── calculator.rb              # Existing - unchanged
├── calculation_request.rb     # Existing - unchanged
├── calculation_result.rb      # Existing - unchanged
├── llm_config.rb             # NEW - API key management
└── percentage_calculator_tool.rb  # NEW - RubyLLM Tool definition
```

**Gemfile Addition:**
```ruby
group :llm, optional: true do
  gem 'ruby_llm', '~> 1.9'
end
```

**Tool Implementation Pattern:**
```ruby
# lib/pocket_knife/percentage_calculator_tool.rb
# frozen_string_literal: true

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
      request = CalculationRequest.new(base, percentage)
      result = Calculator.calculate(request)
      result.value.to_s
    rescue InvalidInputError, CalculationError => e
      "Error: #{e.message}"
    end
  end
end
```

**Configuration Pattern:**
```ruby
# lib/pocket_knife/llm_config.rb
# frozen_string_literal: true

module PocketKnife
  class LLMConfig
    class << self
      def configure!
        return unless llm_available?
        
        RubyLLM.configure do |config|
          config.openai_api_key = openai_key
          config.anthropic_api_key = anthropic_key if anthropic_key
        end
      end

      def llm_available?
        require 'ruby_llm'
        true
      rescue LoadError
        false
      end

      def configured?
        openai_key || anthropic_key
      end

      private

      def openai_key
        ENV['OPENAI_API_KEY']&.strip
      end

      def anthropic_key
        ENV['ANTHROPIC_API_KEY']&.strip
      end
    end
  end
end
```

### Existing Pattern Reference

- Follow error handling pattern from `CLI` class (raise specific error types)
- Follow module organization like existing `Calculator` class
- Follow test structure from `spec/unit/calculator_spec.rb`

### Key Constraints

- RubyLLM must be truly optional - tool must work without it
- No changes to existing calculation logic
- No performance impact on `calc` command
- Maintain Ruby 3.2+ compatibility only

---

## Implementation Checklist

### Phase 1: Setup & Gemfile (30 minutes)

- [x] **1.1** Add optional gem group to Gemfile
  ```ruby
  group :llm, optional: true do
    gem 'ruby_llm', '~> 1.9'
  end
  ```
- [x] **1.2** Run `bundle install` (without `--with llm`) - verify no changes
- [x] **1.3** Run `bundle install --with llm` - verify RubyLLM installs
- [x] **1.4** Run `bundle exec rake test` - verify all existing tests pass
- [x] **1.5** Document both installation modes in README "Installation" section

### Phase 2: LLMConfig Class (60 minutes)

- [x] **2.1** Create `lib/pocket_knife/llm_config.rb` with class skeleton
- [x] **2.2** Implement `llm_available?` method with `require 'ruby_llm'` rescue
- [x] **2.3** Implement `configured?` method checking ENV vars
- [x] **2.4** Implement `configure!` method with provider priority (OpenAI first)
- [x] **2.5** Add custom error classes: `MissingAPIKeyError`, `InvalidAPIKeyError`
- [x] **2.6** Add frozen string literal and module namespacing
- [x] **2.7** Run `bundle exec rubocop lib/pocket_knife/llm_config.rb`
- [x] **2.8** Create unit test file: `spec/unit/llm_config_spec.rb`
- [x] **2.9** Write tests for all methods (see Testing Strategy)
- [x] **2.10** Run tests: `bundle exec rspec spec/unit/llm_config_spec.rb`
- [x] **2.11** Verify 100% coverage for this file

### Phase 3: PercentageCalculatorTool Class (90 minutes)

- [x] **3.1** **CRITICAL:** Verify `CalculationRequest` constructor signature first!
- [x] **3.2** Create `lib/pocket_knife/percentage_calculator_tool.rb` with class skeleton
- [x] **3.3** Add `< RubyLLM::Tool` inheritance
- [x] **3.4** Add tool description: `description "Calculate what percentage of a number equals"`
- [x] **3.5** Define parameters with correct types and descriptions
- [x] **3.6** Implement `execute` method with Calculator integration
- [x] **3.7** Add error handling for `InvalidInputError` and `CalculationError`
- [x] **3.8** Add frozen string literal and module namespacing
- [x] **3.9** Run `bundle exec rubocop lib/pocket_knife/percentage_calculator_tool.rb`
- [x] **3.10** Create unit test file: `spec/unit/percentage_calculator_tool_spec.rb`
- [x] **3.11** Mock `RubyLLM::Tool` parent class appropriately
- [x] **3.12** Write tests for successful execution and error cases
- [x] **3.13** Run tests: `bundle exec rspec spec/unit/percentage_calculator_tool_spec.rb`
- [x] **3.14** Verify 100% coverage for this file

### Phase 4: Documentation & Integration (60 minutes)

- [x] **4.1** Add new files to `lib/pocket_knife.rb` requires (conditional loading notes)
- [x] **4.2** Update README with "Optional LLM Features" section
- [x] **4.3** Document environment variable setup (OpenAI & Anthropic)
- [x] **4.4** Add installation instructions for both modes
- [x] **4.5** Add provider priority documentation
- [x] **4.6** Run full test suite: `bundle exec rake test`
- [x] **4.7** Verify all existing tests still pass
- [x] **4.8** Check test coverage: `COVERAGE=true bundle exec rspec`
- [x] **4.9** Verify coverage remains 90%+ overall
- [x] **4.10** Run rubocop on entire project: `bundle exec rubocop`

### Phase 5: Final Verification (30 minutes)

- [x] **5.1** Test calc command still works: `bundle exec bin/pocket-knife calc 100 20`
- [x] **5.2** Verify no LLM code loaded when running calc (check startup time)
- [x] **5.3** Test with and without `--with llm` bundle installation
- [x] **5.4** Verify graceful degradation when RubyLLM missing
- [x] **5.5** Review all acceptance criteria marked complete
- [x] **5.6** Git commit with message: "feat: Add RubyLLM integration foundation (Story LLM-1)"

---

## Verification Steps

### After Each Phase

1. **Code Quality:**
   ```bash
   bundle exec rubocop [file_path]
   bundle exec rspec [test_file_path]
   ```

2. **Regression Check:**
   ```bash
   bundle exec rake test
   bundle exec bin/pocket-knife calc 100 20
   # Should output: 20.00
   ```

3. **Coverage Check:**
   ```bash
   COVERAGE=true bundle exec rspec
   open coverage/index.html
   # Verify 90%+ coverage maintained
   ```

### Final Story Verification

**Manual Tests:**
```bash
# Test 1: Standard install (no LLM)
bundle install
bundle exec bin/pocket-knife calc 100 20
# Expected: Works perfectly, no LLM code loaded

# Test 2: With LLM install
bundle install --with llm
# Expected: RubyLLM gem installs successfully

# Test 3: Verify new files exist
ls lib/pocket_knife/llm_config.rb
ls lib/pocket_knife/percentage_calculator_tool.rb
ls spec/unit/llm_config_spec.rb
ls spec/unit/percentage_calculator_tool_spec.rb
# Expected: All files present

# Test 4: Run new tests
bundle exec rspec spec/unit/llm_config_spec.rb
bundle exec rspec spec/unit/percentage_calculator_tool_spec.rb
# Expected: All tests pass

# Test 5: Full regression
bundle exec rake test
# Expected: All tests pass, no failures
```

**Automated Checks:**
```bash
# All must pass
bundle exec rubocop
bundle exec rake test
COVERAGE=true bundle exec rspec
```

---

## Definition of Done

- [x] RubyLLM gem added to Gemfile in optional group
- [x] `LLMConfig` class created with API key management
- [x] `PercentageCalculatorTool` class created and tested
- [x] Unit tests written with 100% coverage of new code
- [x] All existing tests pass without modification
- [x] Rubocop passes for all new files
- [x] README updated with installation instructions
- [x] API key setup documented
- [x] Conditional loading works correctly
- [x] Error messages clear and helpful

---

## Risk and Compatibility Check

### Minimal Risk Assessment

**Primary Risk:** Adding dependency breaks zero-dependency promise

**Mitigation:** 
- Optional gem group in Bundler
- Conditional requires with graceful degradation
- Clear documentation of two installation modes
- Default bundle doesn't include RubyLLM

**Rollback:** 
- Remove optional gem group from Gemfile
- Delete new files (llm_config.rb, percentage_calculator_tool.rb)
- Revert README changes
- Git revert is clean (all changes are additive)

### Compatibility Verification

- [x] No breaking changes to existing APIs
- [x] No database changes (N/A)
- [x] No UI changes (N/A - CLI tool)
- [x] Performance impact is zero for calc command (lazy loading)

---

## Testing Strategy

### Unit Tests to Write

1. **LLMConfig Tests:**
   - Test API key reading from environment
   - Test configuration validation
   - Test graceful handling when RubyLLM not installed
   - Test error messages for missing API keys

2. **PercentageCalculatorTool Tests:**
   - Test tool parameter definitions
   - Test successful calculation execution
   - Test integration with Calculator
   - Test error handling for invalid inputs
   - Test error handling for Calculator errors
   - Mock RubyLLM::Tool parent class appropriately

### Regression Tests

- Run full existing test suite
- Verify no tests modified
- Verify test coverage remains 90%+
- Verify calc command still works

---

---

## Dependencies & Relationships

**Dependencies:** 
- None (foundation story - implements base infrastructure)

**Blocks:** 
- Story 2 (LLM-2: Natural Language Ask Command) - Cannot implement ask command without Tool and Config
- Story 3 (LLM-3: Error Handling & Documentation) - Needs this infrastructure to test error scenarios

**Estimated Time:** 4 hours
- Setup & Gemfile: 30 min
- LLMConfig Class: 60 min  
- PercentageCalculatorTool: 90 min
- Documentation: 60 min
- Final Verification: 30 min

---

## Reference Materials

**Key Files to Review Before Starting:**
1. `lib/pocket_knife/calculator.rb` - Understand calculation logic
2. `lib/pocket_knife/calculation_request.rb` - **VERIFY CONSTRUCTOR SIGNATURE**
3. `lib/pocket_knife/errors.rb` - Understand error types
4. `spec/unit/calculator_spec.rb` - Test patterns to follow
5. `.rubocop.yml` - Code style configuration
6. `README.md` - Current documentation structure

**External Documentation:**
- [RubyLLM Tool Documentation](https://rubyllm.com/docs/tools)
- [Bundler Optional Groups](https://bundler.io/guides/groups.html)

**Architecture Reference:**
- See `docs/llm-integration-architecture.md` Section 3: Component Design
- See Architecture Decision Record ADR-3: RubyLLM Tool Adapter Pattern

---

**Story Status:** Ready for Development  
**Story ID:** LLM-1  
**Created:** November 5, 2025  
**Author:** Product Manager (John)  
**Reviewed by:** Architect (Winston), Scrum Master (Bob)
