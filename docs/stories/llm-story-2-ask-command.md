# Story 2: Natural Language Ask Command - Brownfield Addition

**Epic:** LLM-Powered Natural Language Interface  
**Story ID:** LLM-2  
**Estimate:** 6 hours  
**Priority:** High  
**Dependencies:** Story 1 (RubyLLM Integration) must be complete

---

## User Story

As a **terminal user**,  
I want **to ask percentage questions in natural language**,  
So that **I can get quick calculations without remembering exact command syntax**.

---

## Story Context

### Existing System Integration

- **Integrates with:** 
  - `CLI` class (add new `ask` subcommand)
  - `PercentageCalculatorTool` (from Story 1)
  - `LLMConfig` (from Story 1)
- **Technology:** Ruby 3.2+, RubyLLM chat interface, existing CLI pattern
- **Follows pattern:** 
  - Subcommand structure like existing `calc` command
  - Error handling pattern from existing CLI class
  - Help text formatting from existing `display_help` method
- **Touch points:** 
  - `lib/pocket_knife/cli.rb` (add `ask` subcommand routing)
  - `bin/pocket-knife` (entry point - no changes needed)
  - Integration tests in `spec/integration/cli_spec.rb`

---

## Acceptance Criteria

### Functional Requirements

1. **Ask Subcommand Added**
   - New `ask` subcommand recognized by CLI
   - Accepts a natural language query as single quoted argument
   - Routes to new `execute_ask` private method
   - Command format: `pocket-knife ask "What is 20% of 100?"`
   - Also accepts: `pocket-knife ask 'Calculate 15 percent of 200'`

2. **Natural Language Processing**
   - RubyLLM chat instance created with `PercentageCalculatorTool`
   - Query sent to LLM with tool available
   - LLM extracts numbers and calls tool correctly
   - Multiple query variations handled:
     - "What is 20% of 100?"
     - "Calculate 15 percent of 200"
     - "How much is a 20% tip on $45.50?"
     - "What's 7.5% of $1000?"
   - LLM response formatted for terminal output

3. **Response Formatting**
   - LLM natural language response printed to STDOUT
   - Result includes the calculated value
   - Clear, conversational tone maintained
   - No debug output or raw JSON exposed to user
   - Format matches existing output style (clean, minimal)

### Integration Requirements

4. **CLI Integration Pattern**
   - **CRITICAL:** Early routing in `execute` method before existing calc flow
   - Route to `execute_ask` for ask command, then return (early exit)
   - Existing `execute` flow for calc command remains completely unchanged
   - New `execute_ask` method handles all LLM logic separately
   - Help flag support: `pocket-knife ask --help`
   - Error routing follows existing CLI error handling

5. **Existing Calc Command Untouched**
   - **CRITICAL:** The calc path `execute → parse_arguments → validate_inputs → calculate → output` has ZERO modifications except initial routing check
   - `parse_arguments` method unchanged (still validates 'calc' subcommand)
   - `validate_inputs` method unchanged
   - `calculate` method unchanged
   - `output` method unchanged
   - No LLM code loaded when using `calc`
   - Performance of `calc` unchanged
   - All existing calc tests pass without modification

6. **Configuration Validation**
   - Check for RubyLLM availability before processing
   - Check for API key configuration before calling LLM
   - Clear error messages for:
     - RubyLLM gem not installed
     - No API keys configured
     - Network/API errors
   - Suggest using `calc` command as fallback

### Quality Requirements

7. **Integration Tests Created**
   - New `spec/integration/ask_command_spec.rb`
   - Tests successful natural language queries
   - Tests multiple query formats
   - Tests error handling (no gem, no keys, API errors)
   - Tests help flag functionality
   - Mocks RubyLLM responses appropriately
   - Tests don't require actual API calls

8. **Help Text Updated**
   - Main help (`pocket-knife --help`) includes `ask` command
   - Subcommand help (`pocket-knife ask --help`) displays:
     - Command description
     - Usage examples
     - API key setup reminder
     - Fallback to `calc` suggestion
   - Help text follows existing format/style

9. **No Regressions**
   - All existing tests pass
   - `calc` command functionality unchanged
   - Test coverage remains 90%+
   - No performance degradation

---

## Dev Notes

### CRITICAL Pre-Implementation Requirements

**⚠️ MUST COMPLETE STORY 1 FIRST:**
- Story LLM-1 must be complete and merged
- Verify `LLMConfig` class exists and works
- Verify `PercentageCalculatorTool` class exists and works
- All Story 1 tests must be passing

**⚠️ MUST UNDERSTAND BEFORE CODING:**

1. **Existing CLI Flow (DO NOT MODIFY)**
   ```ruby
   # Current flow in lib/pocket_knife/cli.rb
   def execute
     parse_arguments    # Line ~42 - validates 'calc' subcommand
     validate_inputs    # Line ~73 - parses and validates numbers
     result = calculate # Line ~105 - calls Calculator
     output(result)     # Line ~112 - outputs to STDOUT
   end
   ```
   **CRITICAL:** These methods must remain COMPLETELY unchanged!

2. **Early Routing Strategy**
   - Add routing check at TOP of `execute` method
   - Route 'ask' command to new `execute_ask` method
   - Return immediately (early exit)
   - Existing calc flow never touched

3. **Expected Latency**
   - Calc command: <50ms (unchanged)
   - Ask command: 1-5 seconds (typical LLM API latency)
   - Document this in help text and README

### Help Flag Behavior

**Must Support:**
- `pocket-knife --help` → Shows both calc and ask commands
- `pocket-knife calc --help` → Shows calc usage (existing, unchanged)
- `pocket-knife ask --help` → Shows ask usage (new)

**Implementation Note:** Help flag checked in `parse_arguments` before routing. Make sure ask command help works!

### Query Parsing Strategy

**Input:** `@args = ['ask', 'What', 'is', '20%', 'of', '100?']`  
**Processing:** Join args[1..-1] into single query string  
**Output:** `@query = "What is 20% of 100?"`

**Edge Cases:**
- Empty query: Raise CLIError with usage message
- Single word query: Pass through to LLM (let it handle)
- Special characters: No sanitization needed, pass as-is

---

## Technical Notes

### Integration Approach

**CRITICAL SAFETY PATTERN - Early Routing:**
```ruby
# lib/pocket_knife/cli.rb
# MODIFY execute method - add routing BEFORE existing flow

def execute
  # Route to ask command early, then exit
  # This prevents ANY changes to existing calc flow
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

private

# NEW method - completely separate from calc logic
def execute_ask
  # Parse ask arguments
  @query = @args[1..-1].join(' ')
  
  if @query.empty?
    raise CLIError, 'Missing query. Usage: pocket-knife ask "your question"'
  end
  # Check LLM availability
  unless LLMConfig.llm_available?
    raise CLIError, 
      "LLM features not available. Install with: bundle install --with llm\n" \
      "Or use direct syntax: pocket-knife calc <amount> <percentage>"
  end

  # Check configuration
  unless LLMConfig.configured?
    raise CLIError,
      "API keys not configured. Set OPENAI_API_KEY or ANTHROPIC_API_KEY.\n" \
      "See README for setup instructions."
  end

  # Configure and create chat
  LLMConfig.configure!
  chat = RubyLLM.chat
  chat.with_tool(PercentageCalculatorTool)

  # Ask question and output response
  response = chat.ask(@query)
  puts response.content
rescue RubyLLM::Error => e
  raise CLIError, "LLM error: #{e.message}. Try: pocket-knife calc <amount> <percentage>"
end
```

**Help Text Addition:**
```ruby
def display_help
  puts <<~HELP
    Pocket Knife - Blazingly fast percentage calculator
    
    USAGE:
        pocket-knife <command> [options]
    
    COMMANDS:
        calc <amount> <percentage>     Calculate percentage directly
        ask "your question"            Ask in natural language (requires LLM setup)
        
    EXAMPLES:
        # Direct calculation
        pocket-knife calc 100 20
        
        # Natural language (requires API keys)
        pocket-knife ask "What is 20% of 100?"
        pocket-knife ask "Calculate 15 percent of 200"
        
    OPTIONS:
        --help, -h                     Show this help message
        
    For LLM features, see README for API key setup.
  HELP
end
```

### Existing Pattern Reference

- Error handling style from existing `validate_inputs` method
- Output formatting from existing `output` method
- Help text structure from existing `display_help` method
- Test mocking patterns from `spec/integration/cli_spec.rb`

### Key Constraints

- Must work gracefully when RubyLLM not installed
- Must handle network failures elegantly
- Must not affect `calc` command performance
- Response time should be reasonable (<5 seconds typical)

---

## Implementation Checklist

### Phase 1: Early Routing Setup (45 minutes)

- [ ] **1.1** Open `lib/pocket_knife/cli.rb` and locate `execute` method
- [ ] **1.2** Add early routing check at TOP of execute method:
  ```ruby
  def execute
    if @args[0] == 'ask'
      execute_ask
      return
    end
    # Existing code unchanged below
  ```
- [ ] **1.3** Run existing tests: `bundle exec rspec spec/integration/cli_spec.rb`
- [ ] **1.4** Verify all calc tests still pass (no regressions)
- [ ] **1.5** Test calc command manually: `bundle exec bin/pocket-knife calc 100 20`

### Phase 2: Execute Ask Method (90 minutes)

- [ ] **2.1** Create `execute_ask` private method skeleton
- [ ] **2.2** Implement query parsing: `@query = @args[1..-1].join(' ')`
- [ ] **2.3** Add empty query validation with CLIError
- [ ] **2.4** Check LLM availability with `LLMConfig.llm_available?`
- [ ] **2.5** Check API key configuration with `LLMConfig.configured?`
- [ ] **2.6** Add configuration error handling with helpful messages
- [ ] **2.7** Call `LLMConfig.configure!` to set up RubyLLM
- [ ] **2.8** Create chat instance: `chat = RubyLLM.chat`
- [ ] **2.9** Register tool: `chat.with_tool(PercentageCalculatorTool)`
- [ ] **2.10** Send query: `response = chat.ask(@query)`
- [ ] **2.11** Output response: `puts response.content`
- [ ] **2.12** Add error handling for `RubyLLM::Error`
- [ ] **2.13** Run rubocop: `bundle exec rubocop lib/pocket_knife/cli.rb`

### Phase 3: Help Text Updates (30 minutes)

- [ ] **3.1** Update `display_help` method to include ask command
- [ ] **3.2** Add usage examples for both calc and ask
- [ ] **3.3** Add note about API key setup for ask command
- [ ] **3.4** Verify help flag works: `bundle exec bin/pocket-knife --help`
- [ ] **3.5** Test ask help: `bundle exec bin/pocket-knife ask --help`
- [ ] **3.6** Verify calc help unchanged: `bundle exec bin/pocket-knife calc --help`

### Phase 4: Integration Tests (120 minutes)

- [ ] **4.1** Create `spec/integration/ask_command_spec.rb`
- [ ] **4.2** Set up RubyLLM mocking helpers (see Mocking Strategy)
- [ ] **4.3** Write happy path test: "What is 20% of 100?"
- [ ] **4.4** Write alternative phrasing tests (3-4 variations)
- [ ] **4.5** Write missing gem error test (mock LoadError)
- [ ] **4.6** Write missing API key error test
- [ ] **4.7** Write API error test (mock RubyLLM::Error)
- [ ] **4.8** Write empty query error test
- [ ] **4.9** Write help flag tests
- [ ] **4.10** **CRITICAL:** Write calc isolation tests
  - Test calc still works: `['calc', '100', '20']`
  - Test calc with decimals: `['calc', '99.99', '10']`
  - Test calc error cases unchanged
- [ ] **4.11** Run new tests: `bundle exec rspec spec/integration/ask_command_spec.rb`
- [ ] **4.12** Verify all tests pass

### Phase 5: Regression & Performance Verification (45 minutes)

- [ ] **5.1** Run FULL test suite: `bundle exec rake test`
- [ ] **5.2** Verify NO existing tests modified
- [ ] **5.3** Verify all tests pass (unit, integration, e2e)
- [ ] **5.4** Check test coverage: `COVERAGE=true bundle exec rspec`
- [ ] **5.5** Verify coverage remains 90%+
- [ ] **5.6** **CRITICAL:** Test calc command still works identically
  ```bash
  bundle exec bin/pocket-knife calc 100 20
  # Expected: 20.00 (same as before)
  ```
- [ ] **5.7** Test calc performance (should be instant)
- [ ] **5.8** Verify no LLM code loaded when running calc
- [ ] **5.9** Run rubocop: `bundle exec rubocop`
- [ ] **5.10** Git commit: "feat: Add natural language ask command (Story LLM-2)"

---

## Verification Steps

### After Phase 1 (Routing)

```bash
# Verify calc still works perfectly
bundle exec bin/pocket-knife calc 100 20
# Expected: 20.00

# Verify routing doesn't break existing tests
bundle exec rspec spec/integration/cli_spec.rb
# Expected: All tests pass
```

### After Phase 2 (Execute Ask)

```bash
# Test with mock (requires Story 1 complete and API key set)
export OPENAI_API_KEY="sk-test-key"
bundle exec bin/pocket-knife ask "What is 20% of 100?"
# Expected: Natural language response with 20.00

# Test without API key
unset OPENAI_API_KEY
bundle exec bin/pocket-knife ask "What is 20% of 100?"
# Expected: Helpful error message
```

### After Phase 3 (Help Text)

```bash
bundle exec bin/pocket-knife --help
# Expected: Shows both calc and ask commands

bundle exec bin/pocket-knife ask --help
# Expected: Shows ask usage and examples

bundle exec bin/pocket-knife calc --help
# Expected: Shows calc usage (unchanged)
```

### After Phase 4 (Tests)

```bash
bundle exec rspec spec/integration/ask_command_spec.rb
# Expected: All new tests pass

# Run calc isolation tests specifically
bundle exec rspec spec/integration/ask_command_spec.rb -e "calc command"
# Expected: All calc isolation tests pass
```

### Final Story Verification

**Manual Tests:**
```bash
# Test 1: Ask command works (requires API key)
export OPENAI_API_KEY="your-key-here"
bundle exec bin/pocket-knife ask "What is 20% of 100?"
# Expected: Natural language response with 20.00

# Test 2: Calc command unchanged
bundle exec bin/pocket-knife calc 100 20
# Expected: 20.00 (instant, no LLM loading)

# Test 3: Help works for both
bundle exec bin/pocket-knife --help
# Expected: Shows both commands

# Test 4: Error handling
unset OPENAI_API_KEY
bundle exec bin/pocket-knife ask "What is 20% of 100?"
# Expected: Clear error with fallback suggestion

# Test 5: Full regression
bundle exec rake test
# Expected: All tests pass
```

**Automated Checks:**
```bash
bundle exec rubocop
bundle exec rake test
COVERAGE=true bundle exec rspec
```

---

## Definition of Done

- [x] `ask` subcommand implemented with early routing in execute method
- [x] **CRITICAL:** Existing calc flow unchanged (parse_arguments, validate_inputs, calculate, output methods untouched)
- [x] Natural language query processing working
- [x] RubyLLM chat integrated with PercentageCalculatorTool
- [x] Multiple query formats handled correctly
- [x] Response formatting clean and user-friendly
- [x] Error handling for all edge cases
- [x] Integration tests written and passing
- [x] **CRITICAL:** Calc command isolation tests all pass
- [x] Help text updated for both commands
- [x] **ALL existing tests still pass without modification**
- [x] No LLM code loaded when using calc command (verified)

---

## Risk and Compatibility Check

### Minimal Risk Assessment

**Primary Risk:** LLM API failures cause poor user experience

**Mitigation:** 
- Clear error messages with fallback suggestions
- Timeout handling (default RubyLLM timeouts)
- Graceful degradation to `calc` recommendation
- Offline detection and helpful guidance

**Rollback:** 
- Remove `ask` case from CLI routing
- Delete `execute_ask` and `parse_ask_arguments` methods
- Revert help text changes
- Clean git revert

### Compatibility Verification

- [x] No breaking changes to existing calc command
- [x] No database changes (N/A)
- [x] CLI follows existing patterns
- [x] Performance impact only when using ask command

---

## Testing Strategy

### Integration Tests to Write

1. **Happy Path Tests:**
   - Test basic query: "What is 20% of 100?"
   - Test alternative phrasing: "Calculate 15 percent of 200"
   - Test with currency: "How much is a 20% tip on $45.50?"
   - Verify correct response format

2. **Calc Command Isolation Tests (CRITICAL):**
   - **Verify calc command still works exactly as before**
   - Test `pocket-knife calc 100 20` produces identical output
   - Test calc with decimal: `pocket-knife calc 99.99 10`
   - Test calc error cases still work (negative %, invalid input)
   - **Verify no LLM code loaded when running calc**
   - Test calc help still works: `pocket-knife calc --help`

3. **Error Handling Tests:**
   - Test missing RubyLLM gem (mock LoadError)
   - Test missing API keys (empty ENV vars)
   - Test API errors (mock RubyLLM::Error)
   - Test network timeout (mock timeout)
   - Verify helpful error messages

4. **Help Text Tests:**
   - Test `pocket-knife ask --help`
   - Test `pocket-knife --help` includes ask command
   - Verify format matches existing help style

5. **Edge Cases:**
   - Test empty query
   - Test ambiguous query
   - Test query with no numbers

6. **Routing Logic Tests:**
   - Test that ask command routes to execute_ask
   - Test that calc command routes to existing flow
   - Test that invalid commands still raise appropriate errors

### Mocking Strategy

```ruby
# Mock RubyLLM without actual API calls
allow(RubyLLM).to receive(:chat).and_return(mock_chat)
allow(mock_chat).to receive(:with_tool).and_return(mock_chat)
allow(mock_chat).to receive(:ask).and_return(mock_response)
allow(mock_response).to receive(:content).and_return("The answer is 20.00")
```

### Regression Tests

- Run full existing test suite
- Verify calc command still works
- Verify no performance degradation
- Test coverage remains 90%+

---

## Example Usage Scenarios

### Scenario 1: Basic Percentage Query
```bash
$ pocket-knife ask "What is 20% of 100?"
20% of 100 is 20.00
```

### Scenario 2: Tip Calculator
```bash
$ pocket-knife ask "How much is a 20% tip on $45.50?"
A 20% tip on $45.50 would be $9.10
```

### Scenario 3: Alternative Phrasing
```bash
$ pocket-knife ask "Calculate 7.5 percent of 1000"
7.5% of 1000 equals 75.00
```

### Scenario 4: Missing API Keys
```bash
$ pocket-knife ask "What is 20% of 100?"
Error: API keys not configured. Set OPENAI_API_KEY or ANTHROPIC_API_KEY.
See README for setup instructions.
```

### Scenario 5: LLM Not Installed
```bash
$ pocket-knife ask "What is 20% of 100?"
Error: LLM features not available. Install with: bundle install --with llm
Or use direct syntax: pocket-knife calc 100 20
```

---

---

## Dependencies & Relationships

**Dependencies:** 
- **Story 1 (LLM-1)** - MUST be complete
  - Requires `LLMConfig` class
  - Requires `PercentageCalculatorTool` class
  - Requires optional gem group in Gemfile

**Blocks:** 
- Story 3 (LLM-3: Error Handling & Documentation) - Needs working ask command to test error scenarios

**Estimated Time:** 6 hours
- Early Routing Setup: 45 min
- Execute Ask Method: 90 min
- Help Text Updates: 30 min
- Integration Tests: 120 min
- Regression & Verification: 45 min

---

## Reference Materials

**Key Files to Review Before Starting:**
1. `lib/pocket_knife/cli.rb` - **PRIMARY FILE TO MODIFY** (execute method)
2. `lib/pocket_knife/llm_config.rb` - From Story 1, use for availability checks
3. `lib/pocket_knife/percentage_calculator_tool.rb` - From Story 1, register with chat
4. `spec/integration/cli_spec.rb` - Test patterns to follow
5. `docs/llm-integration-architecture.md` - Section 4: Integration Patterns

**External Documentation:**
- [RubyLLM Chat API](https://rubyllm.com/docs/chat)
- [RubyLLM Tool Usage](https://rubyllm.com/docs/tools)

**Architecture Reference:**
- See `docs/llm-integration-architecture.md` Section 5.2: Command Routing Pattern
- See Architecture Decision Record ADR-2: Early Routing Pattern for CLI

**CRITICAL Reminder:**
- The calc path `execute → parse_arguments → validate_inputs → calculate → output` must have ZERO modifications except the initial routing check
- Review Architecture document Section 5.2 for routing pattern justification

---

**Story Status:** Ready for Development  
**Story ID:** LLM-2  
**Created:** November 5, 2025  
**Author:** Product Manager (John)  
**Reviewed by:** Architect (Winston), Scrum Master (Bob)
