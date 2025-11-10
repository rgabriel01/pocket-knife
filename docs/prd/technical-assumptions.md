# Technical Assumptions

## Repository Structure: Monorepo

**Decision:** Single repository containing all project code, tests, and documentation.

**Rationale:** Pocket Knife is a single executable tool with no separate services or components. A monorepo structure is unnecessary—this is a straightforward single-repo project.

## Service Architecture

**Decision:** Standalone CLI executable with no background services, daemons, or persistent processes.

**Architecture:** 
- Command-line entry point (`bin/pocket-knife`)
- Core calculation logic (`lib/pocket_knife/calculator.rb`)
- CLI interface handler (`lib/pocket_knife/cli.rb`)
- Executable exits immediately after displaying result

**Rationale:** Percentage calculations are stateless operations requiring no background processes. Each invocation is independent and completes in milliseconds.

## Testing Requirements

**Decision:** Comprehensive test coverage using RSpec with minimum 90% code coverage.

**Testing Strategy:**
- **Unit tests** for calculation logic (calculator.rb)
- **Integration tests** for CLI interface (cli.rb)
- **End-to-end tests** simulating actual command execution
- **Edge case tests** for input validation and error handling

**Test Organization:**
```
spec/
  spec_helper.rb          # RSpec configuration
  calculator_spec.rb      # Unit tests for calculation engine
  cli_spec.rb             # Integration tests for CLI
  integration/
    command_spec.rb       # End-to-end command execution tests
```

**Rationale:** High test coverage ensures reliability and enables confident refactoring. CLI tools must handle diverse inputs gracefully, requiring thorough testing. Performance will be validated manually during development rather than through automated tests.

## Additional Technical Assumptions and Requests

**Programming Language:**
- Ruby 3.2+ (required)
- No backwards compatibility for Ruby versions < 3.2

**Dependencies:**
- **Runtime:** Ruby standard library only (no external gems)
- **Development:** RSpec (testing), RuboCop (linting), Rake (build tasks)
- **Bundler:** For dependency management during development

**Installation Method:**
- Local installation via Rake task
- Binary installed to user's local gem bin directory
- No system-wide installation required

**Code Quality:**
- Follow Ruby community style guide
- RuboCop configuration for consistent formatting
- All RuboCop offenses resolved before commit

**Performance:**
- Target: <100ms execution time from invocation to output
- No optimization required for calculation logic (trivial math)
- Focus: Minimize Ruby startup overhead

**Security:**
- Input validation to prevent code injection
- No use of `eval` or dynamic code execution
- Safe numeric parsing only

**Platform Support:**
- Primary: macOS (development platform)
- Secondary: Linux distributions with Ruby 3.2+
- Excluded: Windows (may work but untested for MVP)

**Version Control:**
- Git repository
- Conventional commit messages
- Main branch protection (all tests must pass)
