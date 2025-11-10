# Epic 1: Complete MVP - Percentage Calculator CLI

**Epic Goal:** Build a production-ready Ruby CLI tool that enables developers to perform instant percentage calculations directly in their terminal with robust validation, error handling, comprehensive testing, and professional documentation. The tool must be installable via Rake, execute in under 100ms, and achieve 90%+ test coverage.

## Story 1.1: Project Setup and Infrastructure

As a developer,
I want the project repository and development environment configured,
so that I can begin implementing features with proper tooling in place.

**Acceptance Criteria:**

1. Git repository is initialized with appropriate `.gitignore` for Ruby projects
2. Project has standard Ruby structure (`bin/`, `lib/`, `spec/` directories)
3. `Gemfile` exists with development dependencies (RSpec, RuboCop)
4. `Rakefile` exists with basic tasks (test, install)
5. `README.md` exists with project description and installation instructions
6. RSpec is configured with `spec/spec_helper.rb`
7. RuboCop is configured with project standards
8. Bundle install completes successfully
9. `rake spec` runs (even with no tests yet)
10. Repository has initial commit with working structure

## Story 1.2: Core Percentage Calculation Engine

As a user,
I want to calculate what percentage of an amount equals,
so that I can quickly determine percentage values without leaving my terminal.

**Acceptance Criteria:**

1. Calculator module exists at `lib/pocket_knife/calculator.rb`
2. Calculator has a method that accepts amount and percentage as parameters
3. Calculator correctly computes (amount × percentage) ÷ 100
4. Calculator returns result formatted to exactly 2 decimal places
5. Calculator handles integer inputs correctly (e.g., 100, 20 → 20.00)
6. Calculator handles decimal amount inputs correctly (e.g., 99.99, 10 → 10.00)
7. Calculator handles zero amount correctly (0, 50 → 0.00)
8. Calculator handles zero percentage correctly (100, 0 → 0.00)
9. Unit tests cover all calculation scenarios with 100% coverage
10. All RSpec tests pass

## Story 1.3: Command-Line Interface Implementation

As a user,
I want to invoke the percentage calculator from the command line,
so that I can access the functionality via a simple terminal command.

**Acceptance Criteria:**

1. Executable exists at `bin/pocket-knife` with proper shebang and permissions
2. CLI module exists at `lib/pocket_knife/cli.rb`
3. Command accepts format: `pocket-knife calc <amount> <percentage>`
4. Command parses arguments correctly (extracts amount and percentage)
5. Command invokes calculator with parsed arguments
6. Command displays result to stdout with correct formatting (2 decimal places)
7. Command exits with code 0 on successful execution
8. Executable can be run directly: `./bin/pocket-knife calc 100 20` works
9. Integration tests verify end-to-end command execution
10. All RSpec tests pass

## Story 1.4: Input Validation and Error Handling

As a user,
I want clear error messages when I provide invalid input,
so that I can quickly correct my mistakes and use the tool successfully.

**Acceptance Criteria:**

1. Command validates that exactly 3 arguments are provided (command, amount, percentage)
2. Command displays error when too few arguments: "Error: Missing arguments. Usage: pocket-knife calc <amount> <percentage>"
3. Command displays error when too many arguments: "Error: Too many arguments. Usage: pocket-knife calc <amount> <percentage>"
4. Command validates amount is numeric (integer or decimal)
5. Command displays error for non-numeric amount: "Error: Invalid amount. Please provide a numeric value."
6. Command validates percentage is a whole number (integer only)
7. Command displays error for non-integer percentage: "Error: Invalid percentage. Please provide a whole number."
8. Command displays error for percentage with % symbol: "Error: Invalid percentage. Please provide a whole number without the % symbol."
9. Command exits with non-zero code on all error conditions
10. All error scenarios have RSpec test coverage
11. All RSpec tests pass

## Story 1.5: Help Documentation System

As a user,
I want to access help documentation from the command line,
so that I can learn how to use the tool without consulting external resources.

**Acceptance Criteria:**

1. Command responds to `--help` flag: `pocket-knife --help`
2. Command responds to `-h` flag: `pocket-knife -h`
3. Help text includes tool description and purpose
4. Help text shows usage syntax: `pocket-knife calc <amount> <percentage>`
5. Help text includes at least 2 usage examples
6. Help text explains that percentage should be a whole number without % symbol
7. Help text explains that results display with 2 decimal places
8. Command `pocket-knife calc --help` displays subcommand-specific help
9. Help text is clear, concise, and professionally formatted
10. All help flag variations have RSpec test coverage
11. All RSpec tests pass

## Story 1.6: Local Installation and Distribution

As a user,
I want to install the tool to my local environment,
so that I can use it from any directory without specifying the full path.

**Acceptance Criteria:**

1. `Rakefile` includes `install` task
2. `rake install` copies executable to local gem bin directory
3. After installation, `pocket-knife` command is available globally
4. Installation works on macOS
5. Installation works on Linux with Ruby 3.2+
6. `README.md` documents installation steps clearly
7. `README.md` includes prerequisites (Ruby 3.2+ required)
8. `README.md` includes uninstall instructions
9. Installation can be completed in under 2 minutes
10. Installation process has been manually verified

## Story 1.7: Comprehensive Test Suite and Quality Assurance

As a developer,
I want comprehensive automated tests and code quality checks,
so that I can maintain reliability and enable confident future changes.

**Acceptance Criteria:**

1. Unit tests exist for all Calculator module methods
2. Integration tests exist for all CLI scenarios (success and errors)
3. Edge case tests cover boundary conditions (zero, negative, large numbers)
4. Test suite achieves minimum 90% code coverage
5. SimpleCov or similar tool reports coverage metrics
6. All RSpec tests pass consistently
7. RuboCop runs without offenses
8. `Rakefile` includes `rake test` task that runs full suite
9. Test execution completes in under 10 seconds
10. All tests are documented with clear descriptions
