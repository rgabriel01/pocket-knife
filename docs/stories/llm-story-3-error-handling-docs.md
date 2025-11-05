# Story 3: Error Handling, Fallbacks & Documentation - Brownfield Addition

**Epic:** LLM-Powered Natural Language Interface  
**Story ID:** LLM-3  
**Estimate:** 4 hours  
**Priority:** Medium  
**Dependencies:** Story 1 & 2 must be complete

---

## User Story

As a **pocket-knife user**,  
I want **clear error messages and comprehensive documentation**,  
So that **I can troubleshoot issues and understand both usage modes**.

---

## Story Context

### Existing System Integration

- **Integrates with:** 
  - All new LLM code from Stories 1 & 2
  - Existing error handling in CLI
  - README documentation
  - Help text system
- **Technology:** Ruby error handling, Markdown documentation, RSpec for error scenarios
- **Follows pattern:** 
  - Error message format from existing CLI
  - README structure and style
  - Test organization (e2e tests)
- **Touch points:** 
  - `lib/pocket_knife/cli.rb` (error handling refinement)
  - `README.md` (comprehensive documentation)
  - `spec/e2e/pocket_knife_spec.rb` (end-to-end tests)
  - New troubleshooting guide

---

## Acceptance Criteria

### Functional Requirements

1. **Enhanced Error Handling**
   - Timeout handling for LLM API calls (use RubyLLM's built-in timeout)
   - Network error detection with retry suggestions
   - Rate limit error detection with helpful messages
   - Invalid API key detection with setup reminders
   - Ambiguous query handling with clarification prompts
   - All errors include actionable next steps

2. **Fallback Guidance**
   - All LLM errors suggest using `calc` command
   - Include equivalent `calc` syntax in error messages when possible
   - Example: "Try: pocket-knife calc 100 20" after LLM failure
   - Graceful degradation messaging
   - No confusing technical jargon exposed to users

3. **Error Message Quality**
   - Clear, friendly tone
   - Actionable steps provided
   - No stack traces to users (log to stderr if needed)
   - Consistent formatting with existing error messages
   - Examples included where helpful

### Integration Requirements

4. **Consistent Error Handling**
   - All LLM errors caught and handled gracefully
   - Error format matches existing CLI error format
   - Exit codes consistent with existing commands:
     - 0 = success
     - 1 = user error (invalid input, missing config)
     - 2 = system error (API failure, network issue)
   - Errors written to STDERR, not STDOUT

5. **Existing Error Patterns Maintained**
   - `CLIError` still used for user-facing errors
   - Error handling doesn't affect `calc` command
   - Existing error messages unchanged
   - Error test patterns followed

6. **Configuration Validation Enhanced**
   - Validate API key format (not just presence)
   - Check for common key mistakes (spaces, quotes)
   - Validate RubyLLM gem version compatibility
   - Helpful setup wizard suggestion for first-time users

### Quality Requirements

7. **Comprehensive E2E Tests**
   - New `spec/e2e/ask_command_e2e_spec.rb`
   - Tests complete user workflows:
     - Successful ask command flow
     - Missing gem installation flow
     - Missing API key flow
     - Invalid API key flow
     - Network failure flow
     - Ambiguous query flow
   - Tests verify error messages and exit codes
   - Mocks external API calls appropriately

8. **Complete Documentation**
   - **README Updates:**
     - New "LLM Features" section with:
       - Feature overview
       - Installation instructions (both modes)
       - API key setup (OpenAI & Anthropic)
       - Usage examples (multiple query formats)
       - Troubleshooting guide
       - When to use `ask` vs `calc`
     - Updated feature list
     - Updated requirements section
   - **Troubleshooting Guide:**
     - Common errors with solutions
     - API key setup verification
     - Gem installation verification
     - Network debugging tips
   - **Examples Section:**
     - 10+ natural language query examples
     - Shows variety of phrasings
     - Includes expected outputs

9. **Documentation Quality**
   - Clear, concise writing
   - Code examples are tested and work
   - Screenshots or ASCII art where helpful
   - Links to relevant RubyLLM documentation
   - Table of contents updated
   - All existing docs remain accurate

---

## Dev Notes

### CRITICAL Pre-Implementation Requirements

**⚠️ MUST COMPLETE STORIES 1 & 2 FIRST:**
- Story LLM-1 complete: LLMConfig and Tool exist
- Story LLM-2 complete: Ask command working
- Can run `pocket-knife ask` successfully with API key
- All previous tests passing

**⚠️ ERROR HANDLING MATRIX TO IMPLEMENT:**

| Error Type | Exception Class | User Message | Exit Code | Fallback |
|------------|----------------|--------------|-----------|----------|
| Missing Gem | `LoadError` | "LLM features not available..." | 1 | Suggest calc |
| Missing API Key | `LLMConfig::MissingAPIKeyError` | "API keys not configured..." | 1 | Setup docs |
| Invalid API Key | `RubyLLM::AuthenticationError` | "Invalid API key..." | 1 | Check key |
| Rate Limit | `RubyLLM::RateLimitError` | "Rate limit exceeded..." | 2 | Wait/calc |
| Timeout | `RubyLLM::TimeoutError` | "Request timed out..." | 2 | Retry/calc |
| Network Error | `RubyLLM::Error` | "LLM error..." | 2 | Check network |
| Unexpected | `StandardError` | "Unexpected error..." | 2 | Report/calc |

**Exit Code Convention:**
- `0` = Success
- `1` = User error (configuration, invalid input)
- `2` = System error (network, API service)

### Documentation Checklist

**README Sections to Add/Update:**
1. Features list - Add AI-powered bullet
2. Requirements - Clarify optional LLM dependency
3. Installation - Two modes (standard vs with LLM)
4. Usage - Both calc and ask examples
5. LLM Features (NEW) - Setup, examples, troubleshooting
6. FAQ (NEW) - Common questions, privacy, costs

**Security & Privacy Section Required:**
- Document data sent to third-party APIs
- API key management best practices
- When to use calc vs ask
- Review provider data policies

### Example Error Message Format

**Standard Template:**
```
Error: [Clear description of what went wrong]

[Why this happened / context]

[Actionable steps to resolve]:
  1. [Step 1]
  2. [Step 2]

Fallback: Use direct syntax
  pocket-knife calc <amount> <percentage>
```

---

## Technical Notes

### Integration Approach

**Enhanced Error Handling:**
```ruby
# lib/pocket_knife/cli.rb

def execute_ask
  validate_llm_setup
  
  LLMConfig.configure!
  chat = create_llm_chat
  
  response = chat.ask(@query)
  puts response.content
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

private

def handle_missing_gem_error
  error_message = <<~ERROR
    LLM features not available.
    
    To enable natural language queries:
      bundle install --with llm
    
    Or use the direct calculator:
      pocket-knife calc #{extract_numbers_if_possible}
  ERROR
  raise CLIError, error_message
end

def handle_timeout_error
  error_message = <<~ERROR
    Request timed out.
    
    This might be due to:
      - Slow network connection
      - API service issues
      
    Try again, or use the direct calculator:
      pocket-knife calc <amount> <percentage>
  ERROR
  raise CLIError, error_message
end

def suggest_calc_equivalent
  # Attempt to extract numbers from query to suggest calc command
  numbers = @query.scan(/\d+\.?\d*/)
  return "" if numbers.length != 2
  "\n\nTry: pocket-knife calc #{numbers[0]} #{numbers[1]}"
end
```

**API Key Validation:**
```ruby
# lib/pocket_knife/llm_config.rb

class MissingAPIKeyError < StandardError; end
class InvalidAPIKeyError < StandardError; end

def validate_api_key!
  raise MissingAPIKeyError, "No API keys configured" unless configured?
  
  key = openai_key || anthropic_key
  
  # Check for common mistakes
  if key.include?("'") || key.include?('"')
    raise InvalidAPIKeyError, "API key contains quotes - remove them from ENV var"
  end
  
  if key.include?(" ")
    raise InvalidAPIKeyError, "API key contains spaces - check ENV var format"
  end
  
  if key.start_with?("sk-") && key.length < 20
    raise InvalidAPIKeyError, "API key appears malformed - check ENV var"
  end
end
```

**README Documentation Structure:**
```markdown
## Features

- 🚀 **Fast**: Calculate percentages in milliseconds
- 🎯 **Simple**: Clean, intuitive command syntax
- 🤖 **AI-Powered**: Natural language queries (optional)
- 🔒 **Zero Dependencies**: Core features use only Ruby standard library
- ✅ **Well-Tested**: 90%+ code coverage

## Usage

### Quick Calculation (No Setup Required)

\`\`\`bash
pocket-knife calc 200 15
# Output: 30.00
\`\`\`

### Natural Language (Optional, Requires API Key)

\`\`\`bash
pocket-knife ask "What is 15% of 200?"
# Output: 15% of 200 is 30.00
\`\`\`

## Installation

### Standard Installation (Calculator Only)

\`\`\`bash
bundle install
\`\`\`

### With AI Features

\`\`\`bash
bundle install --with llm
\`\`\`

Then set up your API key...
```

### Existing Pattern Reference

- Error message format from `CLIError` raising in existing CLI
- Documentation style from current README
- E2E test patterns from `spec/e2e/pocket_knife_spec.rb`

### Key Constraints

- Error messages must be helpful, not technical
- Documentation must work for both usage modes
- No breaking changes to existing documentation
- All code examples must be tested

---

## Implementation Checklist

### Phase 1: Enhanced Error Handling in CLI (90 minutes)

- [x] **1.1** Open `lib/pocket_knife/cli.rb` and locate `execute_ask` method
- [x] **1.2** Add comprehensive rescue blocks (see Error Handling Matrix)
- [x] **1.3** Create error handler methods for each error type:
  - `handle_missing_gem_error`
  - `handle_missing_api_key_error`
  - `handle_invalid_api_key_error`
  - `handle_rate_limit_error`
  - `handle_timeout_error`
  - `handle_general_llm_error(e)`
  - `handle_unexpected_error(e)`
- [x] **1.4** Implement `suggest_calc_equivalent` helper method
- [x] **1.5** Ensure all error messages follow standard template
- [x] **1.6** Verify correct exit codes for each error type
- [x] **1.7** Test error handling manually (see Verification Steps)
- [x] **1.8** Run rubocop: `bundle exec rubocop lib/pocket_knife/cli.rb`

### Phase 2: Enhanced API Key Validation (45 minutes)

- [x] **2.1** Open `lib/pocket_knife/llm_config.rb`
- [x] **2.2** Add custom exception classes if not present:
  - `MissingAPIKeyError`
  - `InvalidAPIKeyError`
- [x] **2.3** Create `validate_api_key!` method
- [x] **2.4** Check for common mistakes (quotes, spaces)
- [x] **2.5** Validate key format (starts with sk-, minimum length)
- [x] **2.6** Add provider-specific validation (OpenAI vs Anthropic)
- [x] **2.7** Update `configure!` to call validation
- [x] **2.8** Add unit tests for validation in `spec/unit/llm_config_spec.rb`
- [x] **2.9** Run tests: `bundle exec rspec spec/unit/llm_config_spec.rb`

### Phase 3: E2E Error Scenario Tests (90 minutes)

- [x] **3.1** Create `spec/e2e/ask_command_e2e_spec.rb`
- [x] **3.2** Write test for successful ask command flow
- [x] **3.3** Write test for missing RubyLLM gem
- [x] **3.4** Write test for missing API keys
- [x] **3.5** Write test for invalid API key format
- [x] **3.6** Write test for malformed API key (quotes, spaces)
- [x] **3.7** Write test for network timeout (mock)
- [x] **3.8** Write test for rate limit error (mock)
- [x] **3.9** Write test for empty query
- [x] **3.10** Verify error messages are user-friendly
- [x] **3.11** Verify exit codes are correct
- [x] **3.12** Verify fallback suggestions present
- [x] **3.13** Run E2E tests: `bundle exec rspec spec/e2e/ask_command_e2e_spec.rb`

### Phase 4: README Documentation Updates (90 minutes)

- [x] **4.1** Open `README.md`
- [x] **4.2** Update Features section - add AI-powered bullet point
- [x] **4.3** Update Requirements section - clarify optional LLM dependency
- [x] **4.4** Update Installation section:
  - Document standard install (calc only)
  - Document LLM install (with --with llm)
  - Show both commands side by side
- [x] **4.5** Update Usage section:
  - Keep existing calc examples
  - Add natural language ask examples
  - Add "When to use calc vs ask" guidance
- [x] **4.6** Create new "LLM Features" section:
  - Feature overview
  - API key setup (OpenAI & Anthropic)
  - Provider priority documentation
  - 10+ usage examples with variety
  - Troubleshooting common issues
- [x] **4.7** Create new "FAQ" section:
  - Common questions
  - API costs and usage
  - Privacy considerations
- [x] **4.8** Test all README code examples manually
- [x] **4.9** Verify markdown formatting

### Phase 5: Security & Privacy Documentation (45 minutes)

- [x] **5.1** Add "Security & Privacy" section to README
- [x] **5.2** Document:
  - API keys management best practices
  - Never commit keys to version control
  - Key rotation recommendations
- [x] **5.3** Document data privacy:
  - Queries sent to third-party APIs
  - Data retention by providers
  - When to use calc for sensitive data
- [x] **5.4** Link to provider privacy policies:
  - OpenAI data policy
  - Anthropic data policy
- [x] **5.5** Create `docs/TROUBLESHOOTING.md` with:
  - Installation issues
  - API key problems
  - Network errors
  - Rate limits
  - Unexpected results
  - When to use calc vs ask

### Phase 6: Final Documentation Review & Testing (60 minutes)

- [x] **6.1** Review all documentation for clarity and accuracy
- [x] **6.2** Test every code example in README
- [x] **6.3** Verify all links work
- [x] **6.4** Check markdown formatting renders correctly
- [x] **6.5** Verify table of contents updated
- [x] **6.6** Run full test suite: `bundle exec rake test`
- [x] **6.7** Check test coverage: `COVERAGE=true bundle exec rspec`
- [x] **6.8** Verify coverage remains 90%+
- [x] **6.9** Run rubocop: `bundle exec rubocop`
- [x] **6.10** Manual smoke test of all features:
  - Calc command
  - Ask command with API key
  - Ask command without API key
  - All error scenarios
  - Help text for both commands
- [x] **6.11** Git commit: "feat: Add error handling, fallbacks & documentation (Story LLM-3)"

---

## Verification Steps

### After Phase 1 (Error Handling)

```bash
# Test each error scenario manually

# 1. Missing gem (if possible without --with llm)
bundle install
bundle exec bin/pocket-knife ask "What is 20% of 100?"
# Expected: Clear error with install instructions

# 2. Missing API key
bundle install --with llm
unset OPENAI_API_KEY
unset ANTHROPIC_API_KEY
bundle exec bin/pocket-knife ask "What is 20% of 100?"
# Expected: Clear error with setup instructions

# 3. Invalid API key
export OPENAI_API_KEY="invalid-key"
bundle exec bin/pocket-knife ask "What is 20% of 100?"
# Expected: Authentication error with helpful message

# 4. Empty query
bundle exec bin/pocket-knife ask ""
# Expected: Usage error
```

### After Phase 2 (Validation)

```bash
# Test API key validation

# Quotes in key
export OPENAI_API_KEY='"sk-test-key"'
bundle exec bin/pocket-knife ask "test"
# Expected: Error about quotes

# Spaces in key
export OPENAI_API_KEY="sk-test key"
bundle exec bin/pocket-knife ask "test"
# Expected: Error about spaces

# Malformed key
export OPENAI_API_KEY="short"
bundle exec bin/pocket-knife ask "test"
# Expected: Error about format
```

### After Phase 3 (E2E Tests)

```bash
bundle exec rspec spec/e2e/ask_command_e2e_spec.rb
# Expected: All E2E tests pass

bundle exec rspec spec/e2e/ask_command_e2e_spec.rb --format documentation
# Expected: Clear test output showing all scenarios
```

### After Phase 4 (README)

```bash
# Test every code example from README

# Example 1: Standard calc
pocket-knife calc 200 15
# Expected: 30.00

# Example 2: Ask with LLM
export OPENAI_API_KEY="your-key"
pocket-knife ask "What is 15% of 200?"
# Expected: Natural language response

# Example 3: Installation commands
bundle install
bundle install --with llm
# Expected: Both work

# Verify all examples in README work
```

### After Phase 5 (Security Docs)

```bash
# Verify TROUBLESHOOTING.md exists
cat docs/TROUBLESHOOTING.md
# Expected: Complete troubleshooting guide

# Verify security section in README
grep -A 20 "Security" README.md
# Expected: Security & privacy guidance
```

### Final Story Verification

**Complete Feature Test:**
```bash
# 1. Calc command (unchanged)
bundle exec bin/pocket-knife calc 100 20
# Expected: 20.00

# 2. Ask command (with key)
export OPENAI_API_KEY="your-real-key"
bundle exec bin/pocket-knife ask "What is 20% of 100?"
# Expected: Natural language response with 20.00

# 3. All error scenarios work
# (Test each manually from Phase 1 verification)

# 4. Help text complete
bundle exec bin/pocket-knife --help
# Expected: Complete help for both commands

# 5. Documentation complete
cat README.md
cat docs/TROUBLESHOOTING.md
# Expected: All sections present and accurate

# 6. All tests pass
bundle exec rake test
# Expected: 100% pass rate

# 7. Coverage maintained
COVERAGE=true bundle exec rspec
# Expected: 90%+ coverage
```

**Automated Checks:**
```bash
bundle exec rubocop
bundle exec rake test
COVERAGE=true bundle exec rspec
```

---

## Definition of Done

- [x] Enhanced error handling for all LLM error scenarios
- [x] Timeout and retry logic implemented
- [x] Fallback suggestions in all error messages
- [x] API key validation with helpful messages
- [x] E2E tests written for all error scenarios
- [x] README fully updated with LLM features section
- [x] Troubleshooting guide created
- [x] 10+ usage examples documented
- [x] All code examples tested and working
- [x] Existing documentation remains accurate

---

## Risk and Compatibility Check

### Minimal Risk Assessment

**Primary Risk:** Poor error messages cause user confusion

**Mitigation:** 
- User testing of error messages
- Clear, actionable guidance in all errors
- Fallback suggestions always provided
- Documentation reviewed for clarity

**Rollback:** 
- Revert error handling changes
- Restore original README
- No impact on core functionality

### Compatibility Verification

- [x] No breaking changes to existing commands
- [x] No database changes (N/A)
- [x] Error format consistent with existing patterns
- [x] Documentation backwards compatible

---

## Testing Strategy

### E2E Tests to Write

1. **Success Flow:**
   - Complete ask command workflow
   - Verify output format
   - Test multiple query formats

2. **Error Scenarios:**
   - Missing RubyLLM gem
   - Missing API keys
   - Invalid API key format
   - Network timeout
   - Rate limit hit
   - API service unavailable
   - Ambiguous query
   - Query with no numbers

3. **Error Message Validation:**
   - Verify helpful error messages
   - Check fallback suggestions present
   - Verify exit codes correct
   - Check STDERR vs STDOUT usage

4. **Documentation Tests:**
   - Verify all README examples work
   - Test setup instructions
   - Validate code snippets

### Regression Tests

- Full test suite passes
- Existing error handling unchanged
- Documentation links valid
- Test coverage 90%+

---

## Documentation Sections to Add/Update

### README Updates

1. **Features Section:** Add AI-powered bullet point
2. **Requirements Section:** Clarify optional LLM dependency
3. **Installation Section:** Two modes (standard vs with LLM)
4. **Usage Section:** 
   - Existing calc examples (unchanged)
   - New natural language examples
   - When to use each mode
5. **LLM Features Section (NEW):**
   - Setup instructions
   - API key configuration
   - Usage examples
   - Troubleshooting
6. **Examples Section:** 10+ query variations
7. **FAQ Section (NEW):**
   - Common questions about LLM features
   - API costs and usage
   - Privacy considerations

### Troubleshooting Guide (NEW)

Create `docs/TROUBLESHOOTING.md`:

1. **Installation Issues**
2. **API Key Problems**
3. **Network Errors**
4. **Rate Limits**
5. **Unexpected Results**
6. **When to Use calc vs ask**

---

## Example Error Messages

### Missing Gem
```
Error: LLM features not available.

To enable natural language queries:
  bundle install --with llm

Or use the direct calculator:
  pocket-knife calc 100 20
```

### Missing API Key
```
Error: API keys not configured.

Set an API key:
  export OPENAI_API_KEY="sk-..."
  
Or:
  export ANTHROPIC_API_KEY="sk-ant-..."

See docs/TROUBLESHOOTING.md for detailed setup.

Fallback: Use direct syntax
  pocket-knife calc 100 20
```

### Rate Limit
```
Error: API rate limit exceeded.

You've hit your API provider's rate limit.

Solutions:
  1. Wait a few moments and try again
  2. Check your API usage dashboard
  3. Use the direct calculator: pocket-knife calc 100 20
```

### Timeout
```
Error: Request timed out.

This might be due to:
  - Slow network connection
  - API service issues

Try:
  1. Check your internet connection
  2. Try again in a moment
  3. Use direct calculator: pocket-knife calc 100 20
```

---

---

## Dependencies & Relationships

**Dependencies:** 
- **Story 1 (LLM-1)** - MUST be complete (requires LLMConfig for validation)
- **Story 2 (LLM-2)** - MUST be complete (requires working ask command to test errors)

**Blocks:** 
- None - This completes the epic!

**Estimated Time:** 4 hours
- Enhanced Error Handling: 90 min
- API Key Validation: 45 min
- E2E Error Tests: 90 min
- README Updates: 90 min
- Security Documentation: 45 min
- Final Review & Testing: 60 min

---

## Reference Materials

**Key Files to Review Before Starting:**
1. `lib/pocket_knife/cli.rb` - Add error handlers to execute_ask
2. `lib/pocket_knife/llm_config.rb` - Add validation methods
3. `README.md` - PRIMARY documentation file to update
4. `spec/e2e/pocket_knife_spec.rb` - E2E test patterns to follow

**External Documentation:**
- [RubyLLM Error Handling](https://rubyllm.com/docs/errors)
- [12-Factor App Config](https://12factor.net/config)

**Architecture Reference:**
- See `docs/llm-integration-architecture.md` Section 6: Security & Privacy
- See `docs/llm-integration-architecture.md` Appendix C: Usage Examples

**Error Message Guidelines:**
- Clear, friendly tone
- No technical jargon
- Actionable steps
- Always include fallback suggestion
- Consistent formatting

---

## Documentation Quality Checklist

Before marking story complete, verify:

- [ ] All README code examples tested and working
- [ ] Markdown formatting renders correctly
- [ ] All links functional
- [ ] Table of contents updated
- [ ] No typos or grammar errors
- [ ] Security section complete
- [ ] Privacy considerations documented
- [ ] Troubleshooting guide comprehensive
- [ ] FAQ answers common questions
- [ ] Both installation modes documented
- [ ] Provider priority explained
- [ ] 10+ usage examples included
- [ ] When to use calc vs ask guidance clear

---

**Story Status:** Ready for Development  
**Story ID:** LLM-3  
**Created:** November 5, 2025  
**Author:** Product Manager (John)  
**Reviewed by:** Architect (Winston), Scrum Master (Bob)

**Epic Status:** This story completes the LLM-Powered Natural Language Interface epic! 🎉
