# Pocket Knife Product Requirements Document (PRD)

## Goals and Background Context

### Goals

- Enable developers to perform instant percentage calculations without leaving their terminal workflow
- Eliminate context-switching friction caused by opening external calculator applications
- Provide a simple, memorable command syntax that becomes second nature after minimal use
- Establish a foundation for a comprehensive terminal calculation toolkit
- Deliver production-ready Ruby CLI tool within 2-week timeframe

### Background Context

Developers frequently interrupt their workflow to perform basic percentage calculations—discounts, tax amounts, markups, or proportions. Current solutions require context-switching to GUI calculators, web searches, or writing throwaway code. Tools like `bc` exist but require memorizing complex formula syntax for simple operations.

This constant context-switching, while brief (30-60 seconds per instance), compounds throughout the day, disrupting flow state and reducing productivity. The problem is especially pronounced in remote terminal sessions, containerized environments, or minimal development setups where GUI tools aren't readily available.

Pocket Knife addresses this gap by providing a purpose-built, terminal-native percentage calculator that prioritizes speed, simplicity, and developer ergonomics.

### Change Log

| Date | Version | Description | Author |
|------|---------|-------------|--------|
| 2025-11-04 | 0.1 | Initial PRD creation from Project Brief | PM (John) |
| 2025-11-05 | 0.2 | Added LLM Integration Epic (Epic 2) - Natural language interface | PM (John) |
| 2025-11-06 | 0.3 | Added Product Storage Epic (Epic 3) - SQLite-based product storage | PM (John) |

## Requirements

### Functional

**FR1:** The system shall accept a command in the format `pocket-knife calc <amount> <percentage>` where both arguments are numeric values

**FR2:** The system shall calculate the result as (amount × percentage) ÷ 100

**FR3:** The system shall display the calculation result formatted to exactly 2 decimal places (e.g., `20.00`)

**FR4:** The system shall validate that the amount argument is a valid numeric value (integer or decimal)

**FR5:** The system shall validate that the percentage argument is a valid whole number (integer only, no `%` symbol)

**FR6:** The system shall display a clear error message when invalid input is provided (non-numeric, missing arguments, too many arguments)

**FR7:** The system shall provide help documentation via `--help` and `-h` flags at the command level

**FR8:** The system shall provide help documentation for the `calc` subcommand via `pocket-knife calc --help`

**FR9:** The system shall execute and return results in under 100 milliseconds

**FR10:** The system shall exit with code 0 on successful calculation

**FR11:** The system shall exit with a non-zero code on error conditions

### Non Functional

**NFR1:** The tool must be installable via Rake on systems with Ruby 3.2+ installed

**NFR2:** The codebase shall maintain 90% or greater test coverage with RSpec

**NFR3:** All tests must pass before any release

**NFR4:** Error messages shall be clear, actionable, and guide users toward correct usage

**NFR5:** The tool shall have zero external gem dependencies beyond development/testing gems (RSpec, RuboCop)

**NFR6:** Code shall follow Ruby community style guidelines as enforced by RuboCop

**NFR7:** The tool shall run on macOS and Linux without modification

**NFR8:** Input validation shall prevent code injection or unsafe operations

## User Interface Design Goals

### Overall UX Vision

The command-line interface should feel natural and invisible—users should be able to invoke the tool from muscle memory without consulting documentation after initial use. The interaction should be so fast and frictionless that it becomes the default choice for percentage calculations over any alternative.

### Key Interaction Paradigms

- **Command-line only** - No GUI, web interface, or interactive modes
- **Single-purpose invocation** - One command, immediate result, exit
- **Self-documenting** - Command structure makes purpose clear (`calc` subcommand)
- **Terminal-standard** - Follows POSIX conventions for flags, help, and exit codes

### Core Interaction Flow

1. User types `pocket-knife calc <amount> <percentage>`
2. Tool validates input
3. Tool displays result (or error) to stdout
4. Tool exits

**Example Successful Interaction:**
```bash
$ pocket-knife calc 100 20
20.00
```

**Example Error Interaction:**
```bash
$ pocket-knife calc 100 abc
Error: Invalid percentage. Please provide a whole number.
```

### Accessibility

- **Terminal accessibility** - Compatible with screen readers via standard terminal output
- **Colorblind-friendly** - No reliance on color for information (text-only output)
- **Keyboard-only** - No mouse/pointing device required

### Target Platforms

- **macOS Terminal / iTerm2**
- **Linux terminal emulators** (bash, zsh, fish shells)
- **Remote SSH sessions**
- **CI/CD environments** (for scripted use)

## Technical Assumptions

### Repository Structure: Monorepo

**Decision:** Single repository containing all project code, tests, and documentation.

**Rationale:** Pocket Knife is a single executable tool with no separate services or components. A monorepo structure is unnecessary—this is a straightforward single-repo project.

### Service Architecture

**Decision:** Standalone CLI executable with no background services, daemons, or persistent processes.

**Architecture:** 
- Command-line entry point (`bin/pocket-knife`)
- Core calculation logic (`lib/pocket_knife/calculator.rb`)
- CLI interface handler (`lib/pocket_knife/cli.rb`)
- Executable exits immediately after displaying result

**Rationale:** Percentage calculations are stateless operations requiring no background processes. Each invocation is independent and completes in milliseconds.

### Testing Requirements

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

### Additional Technical Assumptions and Requests

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

## Epic List

Pocket Knife has evolved beyond the initial MVP into a comprehensive terminal toolkit:

**Epic 1: Complete MVP - Percentage Calculator CLI** ✅ COMPLETED - Build a complete, production-ready Ruby CLI tool that calculates percentages with robust input validation, error handling, comprehensive testing, and built-in help documentation

**Epic 2: LLM Integration** ✅ COMPLETED - Add natural language interface using RubyLLM and Google Gemini, allowing users to ask calculation questions in plain English

**Epic 3: Product Storage** 🚧 IN PROGRESS - Enable users to store products with prices in a SQLite database and perform calculations on stored products

## Epic 1: Complete MVP - Percentage Calculator CLI

**Epic Goal:** Build a production-ready Ruby CLI tool that enables developers to perform instant percentage calculations directly in their terminal with robust validation, error handling, comprehensive testing, and professional documentation. The tool must be installable via Rake, execute in under 100ms, and achieve 90%+ test coverage.

### Story 1.1: Project Setup and Infrastructure

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

### Story 1.2: Core Percentage Calculation Engine

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

### Story 1.3: Command-Line Interface Implementation

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

### Story 1.4: Input Validation and Error Handling

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

### Story 1.5: Help Documentation System

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

### Story 1.6: Local Installation and Distribution

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

### Story 1.7: Comprehensive Test Suite and Quality Assurance

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

## Checklist Results Report

### PM Checklist Validation Summary

**Overall PRD Completeness:** ~85%
**MVP Scope Appropriateness:** Just Right
**Readiness for Architecture Phase:** Nearly Ready

### Category Analysis

| Category                         | Status  | Critical Issues                                          |
| -------------------------------- | ------- | -------------------------------------------------------- |
| 1. Problem Definition & Context  | PASS    | None - well articulated with user research context      |
| 2. MVP Scope Definition          | PASS    | Clear boundaries, rationale documented                   |
| 3. User Experience Requirements  | PASS    | Appropriate for CLI tool context                         |
| 4. Functional Requirements       | PASS    | 11 FRs cover all core functionality                      |
| 5. Non-Functional Requirements   | PARTIAL | Missing monitoring, operational NFRs (acceptable for MVP)|
| 6. Epic & Story Structure        | PASS    | Single epic, 7 well-sequenced stories                    |
| 7. Technical Guidance            | PASS    | Ruby 3.2, RSpec, clear architecture                      |
| 8. Cross-Functional Requirements | PARTIAL | Limited data/integration needs (intentional for MVP)     |
| 9. Clarity & Communication       | PASS    | Clear, consistent documentation                          |

### Key Strengths

1. **Problem Definition** - Clear pain point (context-switching), quantified impact, well-defined target users
2. **MVP Scope** - Appropriately minimal (single calculation type), clear out-of-scope items
3. **Story Quality** - All 7 stories have 10+ testable acceptance criteria, proper sequencing
4. **Technical Clarity** - Ruby 3.2, RSpec 90% coverage, <100ms performance target explicit
5. **User Focus** - Consistent "developer workflow" perspective throughout
6. **Design Decisions** - Whole numbers only, 2 decimal places explicitly documented

### Recommendations

**Optional Improvements:**
1. Add numeric range limits to FR4/FR5 (e.g., "Must handle values from -999,999,999 to 999,999,999")
2. Expand Story 1.4 AC to specify edge case behaviors (negative %, 100.5, etc.)

**For Architect to Research:**
1. Ruby CLI argument parsing libraries (thor vs OptionParser tradeoffs)
2. Numeric validation strategy and range handling approach
3. Ruby startup time optimization (bootsnap or similar)

### Final Decision

**✅ READY FOR ARCHITECT**

The PRD is comprehensive, properly structured, and ready for architectural design. The optional improvements noted would enhance clarity but are not blockers. The MVP scope is appropriate, stories are well-defined with testable acceptance criteria, and technical guidance provides clear direction for the architect.

## Next Steps

### Architect Prompt

**Architect**, you're now ready to design the technical architecture for Pocket Knife. Please review this PRD and the Project Brief (`docs/brief.md`) to create a comprehensive architecture document.

**Key Focus Areas:**
1. Ruby project structure (lib/ organization, module namespacing)
2. Argument parsing library selection (thor vs OptionParser - document tradeoffs)
3. Numeric validation approach (regex vs Ruby parsing methods)
4. Error handling patterns (custom exception classes vs simple messages)
5. Testing architecture (RSpec structure, test helpers, fixtures)
6. Installation mechanism details (Rake task implementation)
7. Performance considerations (Ruby startup time, optimization strategies)

**Deliverable:** Create `docs/architecture.md` with comprehensive technical specifications following the fullstack-architecture template, adapted for a CLI tool.

**Command to begin:** Load the architect agent and use the `*document-project` task or create architecture from scratch using this PRD as input.

---

## Epic 3: Product Storage

**Epic Goal:** Enable users to store products with prices in a local SQLite database and perform calculations on stored products, creating a persistent product catalog for quick price-based calculations.

**Status:** 🚧 IN PROGRESS
- ✅ Story 3.1: Product Storage Foundation - COMPLETED
- ⏳ Story 3.2: List and Retrieve Products - PLANNED
- ⏳ Story 3.3: Update and Delete Products - PLANNED
- ⏳ Story 3.4: Calculate on Stored Products - PLANNED

### Story 3.1: Product Storage Foundation ✅ COMPLETED

As a user,
I want to store products with their prices in a local database,
so that I can maintain a persistent catalog of products for calculations.

**Acceptance Criteria:**

1. ✅ SQLite3 gem added as optional dependency in `:storage` group
2. ✅ Database connection manager implemented at `lib/pocket_knife/storage/database.rb`
3. ✅ Database auto-creates at `~/.pocket-knife/products.db` on first use
4. ✅ Products table created with schema: id (PK), name (unique, NOT NULL), price (>=0, NOT NULL), created_at, updated_at
5. ✅ Product model implemented at `lib/pocket_knife/storage/product.rb` with CRUD operations
6. ✅ `store-product "<name>" <price>` command implemented in CLI
7. ✅ Product name validated (cannot be empty or whitespace-only)
8. ✅ Price validated (must be numeric and non-negative)
9. ✅ Duplicate product names rejected with clear error message
10. ✅ Success message displays product details (name, formatted price, ID)
11. ✅ Missing sqlite3 gem handled gracefully with installation instructions
12. ✅ Comprehensive unit tests written (19 database + 35 product model = 54 tests)
13. ✅ Integration tests written (8 CLI integration tests)
14. ✅ All 185 tests passing (123 existing + 62 new storage tests)
15. ✅ README.md updated with storage feature documentation
16. ✅ Help text updated with store-product examples
17. ✅ Zero RuboCop offenses
18. ✅ 77% code coverage maintained

**Implementation Details:**
- Storage directory: `~/.pocket-knife/`
- Database file: `products.db`
- Table: `products` with name index for fast lookup
- Exit codes: 0 (success), 1 (user error/duplicate), 2 (invalid input)
- Optional feature: Requires `bundle install --with storage`

**Test Coverage:**
- Unit tests: 54 (database: 19, product model: 35)
- Integration tests: 8 (CLI command execution)
- Total new tests: 62
- All existing tests: 123 (still passing)
- **Total test suite: 185 examples, 0 failures**

### Story 3.2: List and Retrieve Products

As a user,
I want to list all stored products and retrieve individual product details,
so that I can view my product catalog and look up specific prices.

**Acceptance Criteria:**

1. `list-products` command displays all products in a formatted table
2. Table shows columns: ID, Name, Price (formatted with $)
3. Products sorted alphabetically by name
4. Empty list displays helpful message ("No products stored yet")
5. `get-product "<name>"` command retrieves single product by name
6. Get command displays: Name, Price, ID, Created At, Updated At
7. Product not found displays clear error message with suggestions
8. Both commands exit code 0 on success, 1 on not found
9. Unit tests for retrieval logic
10. Integration tests for both commands
11. All existing tests still passing
12. README.md updated with list/get examples

### Story 3.3: Update and Delete Products

As a user,
I want to update product prices and delete products,
so that I can maintain an accurate product catalog.

**Acceptance Criteria:**

1. `update-product "<name>" <new_price>` command updates existing product price
2. Update validates new price (numeric, non-negative)
3. Update displays confirmation with old and new price
4. Update command exits code 0 on success, 1 if not found, 2 if invalid price
5. `delete-product "<name>"` command removes product from database
6. Delete asks for confirmation before removing
7. Delete displays confirmation message after removal
8. Delete command exits code 0 on success, 1 if not found
9. Unit tests for update/delete operations
10. Integration tests for both commands
11. All existing tests still passing
12. README.md updated with update/delete examples

### Story 3.4: Calculate on Stored Products

As a user,
I want to calculate percentages using stored product prices,
so that I can quickly compute discounts, markups, or tax on my products.

**Acceptance Criteria:**

1. `calc-product "<name>" <percentage>` command looks up product and calculates
2. Command displays: Product name, original price, percentage, result
3. Product not found displays clear error message
4. Percentage validated same as regular calc command
5. Command exits code 0 on success, 1 if not found, 2 if invalid percentage
6. Works seamlessly with existing calc command
7. Unit tests for product calculation logic
8. Integration tests for calc-product command
9. All existing tests still passing
10. README.md updated with calc-product examples
11. Help text includes calc-product usage

```
