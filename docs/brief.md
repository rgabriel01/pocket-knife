# Project Brief: Pocket Knife

## Executive Summary

Pocket Knife is a comprehensive Ruby CLI toolkit designed to provide quick, reliable calculations and product management directly in the terminal. Built for developers and technical users who need instant mathematical computations and product cataloging without leaving their workflow, the tool offers multiple command-line interfaces including:

- **Core Calculator:** Basic percentage calculations (`calc` command)
- **Natural Language Interface:** LLM-powered conversational calculations (`ask` command)
- **Product Storage:** SQLite-based product catalog with CRUD operations
- **Natural Language Product Queries:** Query products using natural language (`ask-product` command)

Starting with percentage calculations as its foundational feature, Pocket Knife has evolved into a comprehensive terminal toolkit that combines traditional CLI commands with modern AI-powered natural language interfaces. The optional feature architecture allows users to install only what they need (core calculator, LLM features, storage features, or all combined).

## Problem Statement

Developers and technical users frequently need to perform quick percentage calculations during their daily work—calculating discounts, tax amounts, percentage increases/decreases, or proportions. Current solutions force users to context-switch away from their terminal workflow:

- **Desktop calculators** require switching applications and breaking focus
- **Web-based calculators** necessitate opening a browser and searching
- **Built-in shell tools** like `bc` require complex syntax and formula knowledge for percentage operations
- **Scripting solutions** demand writing throwaway code for simple calculations

This constant context-switching disrupts developer flow and wastes valuable time on trivial calculations. While the impact per calculation is small (30-60 seconds), these interruptions compound throughout the day, breaking concentration and reducing productivity. The problem is particularly acute for developers working in remote terminal sessions, containerized environments, or minimal setups where GUI tools aren't readily available.

**Current pain points:**
- Loss of focus from application switching
- Time wasted on simple calculations
- Cognitive overhead of `bc` syntax for basic operations
- Lack of a purpose-built, terminal-native solution

## Proposed Solution

Pocket Knife is a Ruby-based CLI tool that provides instant percentage calculations without leaving the terminal. The MVP focuses on the single most common operation: **calculating X% of Y**.

**Core Approach:**
- **Single command** with clear syntax: `pocket-knife calc <amount> <percentage>`
- **Instant results** displayed directly in terminal
- **Zero configuration** - works immediately after installation
- **Lightweight footprint** - minimal dependencies, fast execution
- **Terminal-native** - designed for keyboard-driven workflows

**Command Syntax:**

```bash
# Calculate X% of Y
$ pocket-knife calc 100 20
20.00

# Built-in help
$ pocket-knife --help
$ pocket-knife calc --help
```

**Key Differentiators:**
- **Purpose-built for percentages** - Unlike `bc` which requires formula knowledge, Pocket Knife uses natural syntax
- **Self-documenting** - The `calc` subcommand makes the tool's purpose immediately clear
- **Developer-friendly** - Designed by developers, for developers who value speed and simplicity
- **Ruby ecosystem** - Leverages Ruby's readability and ease of distribution
- **Extensible foundation** - Clean architecture allows adding more calculation types post-MVP

**Why This Will Succeed:**
The tool succeeds by doing one thing exceptionally well: making the most common percentage calculation (X% of Y) trivial in the terminal. The subcommand structure provides clarity without complexity—`calc` makes the intent obvious while keeping the syntax simple. Rather than competing with full-featured calculators, Pocket Knife fills a specific gap—providing the fastest path from "I need to calculate X% of Y" to seeing the answer.

## Target Users

### Primary User Segment: Developers and Technical Professionals

**Profile:**
- Software developers, DevOps engineers, system administrators, and technical users who spend significant time in terminal environments
- Comfortable with command-line tools and prefer keyboard-driven workflows
- Work across various technology stacks (not Ruby-specific)
- Value efficiency and minimal context-switching during work

**Current Behaviors:**
- Live primarily in terminal/IDE environments throughout the workday
- Regularly need quick calculations for common tasks (pricing, percentages, conversions)
- Currently context-switch to calculators, web searches, or write throwaway code
- Use other CLI utilities for productivity (grep, jq, curl, etc.)

**Specific Needs:**
- Instant percentage calculations without breaking terminal flow
- Simple, memorable syntax that doesn't require documentation lookup
- Fast execution (sub-second response)
- Reliable, accurate calculations for professional use
- Tool that "just works" without configuration

**Goals They're Trying to Achieve:**
- Calculate discounts, markups, or margins during development
- Quick financial calculations (tax, tips, commission)
- Determine percentage changes or proportions
- Maintain focus and productivity in terminal-centric workflows
- Avoid the friction of opening external calculator applications

## Goals & Success Metrics

### Business Objectives

- **Build and validate MVP within 2 weeks** - Prove concept with functional tool
- **Achieve personal productivity gain** - Use tool daily in own workflow
- **Establish foundation for toolkit expansion** - Create architecture that supports additional calculation types
- **Demonstrate Ruby CLI development skills** - Showcase clean, maintainable Ruby code

### User Success Metrics

- **Accuracy**: 100% correct calculations for valid inputs
- **Reliability**: Zero crashes or errors for well-formed inputs

### Key Performance Indicators (KPIs)

- **Personal adoption**: Use Pocket Knife for 80% of percentage calculations within first week
- **Execution speed**: < 100ms response time for calculations
- **Code quality**: Achieve 90%+ test coverage with unit tests
- **Error handling**: Graceful failures with clear messages for invalid inputs
- **Installation success**: Tool installs and runs on first attempt on clean Ruby 3.2 environment

## MVP Scope

### Core Features (Must Have)

- **Percentage Calculation Command**: `pocket-knife calc <amount> <percentage>` - Calculate X% of Y and display the result
  - *Rationale: This is the core value proposition - the one calculation that solves the primary use case*

- **Input Validation**: Validate that inputs are numeric and within reasonable ranges
  - *Rationale: Prevents crashes and provides professional user experience with clear error messages*

- **Help Documentation**: `--help` and `-h` flags for command-level documentation
  - *Rationale: Essential for discoverability and self-service learning without external docs*

- **Clean Output**: Display numeric result only (no extraneous text) for script-friendly piping
  - *Rationale: Supports both interactive and programmatic use cases*

- **Error Messages**: Clear, actionable error messages for invalid inputs
  - *Rationale: Guides users to correct usage without frustration*

- **Local Installation**: Rake-based installation to local Ruby environment
  - *Rationale: Meets the requirement for local-only distribution in MVP*

### Out of Scope for MVP

- Short command aliases (e.g., `pk`)
- Additional calculation modes (increase, decrease, percentage-of)
- Output formatting options (verbose mode, precision control, colors)
- Configuration files or user preferences
- Interactive mode or REPL
- RubyGems publication
- Shell completion scripts
- Version checking or auto-updates

### MVP Success Criteria

The MVP is considered successful when:
- ✅ A user can install the tool via `rake install`
- ✅ The tool correctly calculates X% of Y for all valid numeric inputs
- ✅ Invalid inputs produce clear error messages without crashes
- ✅ `--help` displays complete usage instructions
- ✅ Execution completes in < 100ms
- ✅ Test suite achieves 90%+ coverage and all tests pass

## Post-MVP Vision

### Phase 2 Features

Once the MVP proves valuable in daily use, the following enhancements would expand Pocket Knife's utility:

- **Additional Calculation Modes**:
  - `increase`: Calculate percentage increase (e.g., `pocket-knife increase 100 15` → 115.0)
  - `decrease`: Calculate percentage decrease (e.g., `pocket-knife decrease 200 25` → 150.0)
  - `of`: Reverse calculation - what % is X of Y (e.g., `pocket-knife of 25 200` → 12.5%)

- **Short Alias**: Introduce `pk` command for power users who use the tool dozens of times per day

- **Output Formatting**: Optional verbose mode (`-v` flag) with labeled output for clarity in interactive use

- **RubyGems Distribution**: Package and publish to RubyGems for easy `gem install pocket-knife` installation

### Long-term Vision

Pocket Knife evolves from a single-purpose percentage calculator into a comprehensive terminal-native calculation toolkit:

- **Expanded Math Operations**: Unit conversions, currency calculations, date/time arithmetic
- **Calculator Suite**: Common developer calculations (hex/binary conversions, base64, hashing)
- **Plugin Architecture**: Community-contributed calculation modules
- **Performance Optimization**: Native extension for zero-latency calculations
- **Cross-platform Support**: Pre-built binaries for systems without Ruby

### Expansion Opportunities

- **Team Adoption**: Share within development teams as a standard toolkit component
- **Language Ports**: Go or Rust versions for even faster execution and no runtime dependencies
- **Integration**: Plugins for popular terminals (iTerm2, Warp) or shells (zsh, fish)
- **Web Companion**: Simple web interface for sharing calculations or documentation

## Technical Considerations

### Platform Requirements

- **Target Platforms:** macOS, Linux (primary development and testing environments)
- **Ruby Version:** Ruby 3.2+ (required)
- **Terminal Support:** Any POSIX-compliant terminal with standard output
- **Performance Requirements:** Command execution < 100ms from invocation to output

### Technology Preferences

- **Frontend:** N/A (CLI-only tool)
- **Backend:** Ruby 3.2 with standard library (minimal external dependencies)
- **Core Libraries:**
  - Ruby standard library for argument parsing and math operations
  - Potentially `thor` or native OptionParser for command-line interface
  - **RSpec** - Primary testing framework for unit and integration tests
- **Build Tools:** Rake for installation tasks and test automation
- **Hosting/Infrastructure:** N/A (local installation only for MVP)

### Architecture Considerations

- **Repository Structure:** Single repository (monorepo not applicable for single-tool project)
- **Service Architecture:** Standalone CLI executable, no services or daemons
- **Code Organization:**
  - `bin/pocket-knife` - Executable entry point
  - `lib/pocket_knife/` - Core logic modules
  - `lib/pocket_knife/calculator.rb` - Calculation engine
  - `lib/pocket_knife/cli.rb` - Command-line interface
  - `spec/` - RSpec test suite
  - `spec/spec_helper.rb` - RSpec configuration
  - `spec/calculator_spec.rb` - Calculator unit tests
  - `spec/cli_spec.rb` - CLI integration tests
- **Integration Requirements:** None for MVP (no external APIs or services)
- **Security/Compliance:** 
  - Input validation to prevent code injection
  - No data persistence or network communication
  - Safe math operations without eval or dynamic code execution

### Development Environment

- **Version Control:** Git
- **Testing:** RSpec with 90%+ code coverage target
- **Documentation:** README.md with installation and usage instructions
- **Code Quality:** RuboCop or similar linter for style consistency

## Constraints & Assumptions

### Constraints

- **Budget:** $0 - Personal project with no monetary investment beyond time
- **Timeline:** 2 weeks for MVP development (part-time effort, approximately 20-30 hours total)
- **Resources:** Solo developer project - no team collaboration for MVP
- **Technical:** 
  - Must run on Ruby 3.2+ (no backwards compatibility for older Ruby versions)
  - Local installation only (no cloud hosting or distribution infrastructure)
  - Command-line interface only (no GUI or web interface)
  - No external API dependencies or network requirements

### Key Assumptions

- Users have Ruby 3.2+ installed and available in their environment
- Target users are comfortable with command-line tools and basic terminal usage
- The percentage calculation format (X% of Y) is universally understood
- Clean numeric output is preferable to verbose labeled output for most use cases
- 100ms execution time is fast enough to feel "instant" to users
- Local installation via Rake is acceptable for MVP distribution
- Test-driven development will reduce bugs and support future maintenance
- The tool will be used primarily by the developer (you) initially, providing immediate feedback
- RSpec and standard Ruby tooling are sufficient for testing and quality assurance
- GitHub or similar VCS is available for version control (even if private repository)

## Risks & Open Questions

### Key Risks

- **Ruby Version Availability:** Users may not have Ruby 3.2+ installed, limiting adoption even in target developer audience
  - *Impact:* Medium - Reduces potential user base, but target audience likely has modern Ruby or can install it
  - *Mitigation:* Document Ruby version requirement clearly; consider future binary distribution to eliminate runtime dependency

- **Limited Utility:** Single calculation type may prove too narrow - users might need more operations to justify adding another CLI tool
  - *Impact:* High - Could result in low adoption and abandonment after initial trial
  - *Mitigation:* Validate through personal use over first week; have Phase 2 features ready to implement if needed

- **Discoverability:** Without RubyGems distribution or promotion, tool remains personal utility rather than reaching wider audience
  - *Impact:* Low for MVP - Project goal is personal productivity, not mass adoption
  - *Mitigation:* Accept as intentional constraint; plan Gems distribution for post-MVP if value is proven

- **Performance Expectations:** If execution takes >100ms due to Ruby startup time, may not feel "instant" enough
  - *Impact:* Medium - Could negate primary value proposition of staying in flow
  - *Mitigation:* Benchmark early; optimize or consider preloading/daemon approach if needed

### Open Questions

- How should the tool handle edge cases like negative percentages, zero values, or extremely large numbers?
- Should there be a maximum input value to prevent overflow or performance issues?
- Is `calc` the best subcommand name, or would `percent`, `of`, or something else be clearer?
- Should help text include examples, or just syntax reference?

### Design Decisions Made

- ✅ **Percentage input format:** Accept only whole numbers without `%` symbol (e.g., `pocket-knife calc 100 20` not `100 20%`)
  - *Rationale:* Simpler parsing, cleaner syntax, fewer potential input errors

- ✅ **Result precision display:** Always show two decimal places (e.g., `20.00` not `20.0` or `20`)
  - *Rationale:* Consistent formatting, professional appearance, clear for financial calculations, matches calculator conventions

### Areas Needing Further Research

- **Ruby CLI best practices:** Research thor vs OptionParser vs other argument parsing libraries for best DX
- **Testing CLI applications:** Investigate RSpec patterns for testing command-line output and error handling
- **Performance optimization:** Research Ruby startup time and potential optimizations (bootsnap, etc.)
- **Input validation patterns:** Study how other CLI tools handle numeric input validation and error messages
- **Distribution methods:** Understand Rake install vs Gems vs other Ruby tool distribution approaches

## Next Steps

### Immediate Actions

1. **Create project repository** - Initialize Git repository with standard Ruby project structure
2. **Set up development environment** - Configure RSpec, RuboCop, and Rake tasks
3. **Create basic project files** - Gemfile, Rakefile, README.md with installation instructions
4. **Implement core calculator logic** - Build percentage calculation engine with input validation
5. **Build CLI interface** - Create command-line parser and output formatter
6. **Write comprehensive tests** - Achieve 90%+ coverage with RSpec test suite
7. **Validate MVP success criteria** - Test all acceptance criteria are met
8. **Use tool in daily workflow** - Personal validation over one week of real usage

### PM Handoff

This Project Brief provides the complete context for **Pocket Knife**. 

**Summary:**
- **What:** Ruby 3.2 CLI tool for quick percentage calculations in the terminal
- **Core Command:** `pocket-knife calc <amount> <percentage>` → outputs result with 2 decimal places
- **Target:** Developers who need instant calculations without breaking terminal flow
- **Timeline:** 2-week MVP development
- **Key Decisions:** 
  - Whole numbers only for percentage input (no `%` symbol)
  - Results always display with 2 decimal places (e.g., `20.00`)
  - Single calculation type for MVP (X% of Y)
  - Local installation via Rake
  - RSpec for testing

**For PRD Creation:**
Please review this brief thoroughly and proceed to create the PRD. The PRD should translate this vision into detailed functional requirements, epics, and user stories that guide the development of Pocket Knife. Focus on:
- Clear acceptance criteria for the single calculation command
- Input validation requirements (numeric validation, range checking)
- Error handling specifications
- Help documentation requirements
- Testing strategy and coverage expectations

---

## Project Status Update (November 6, 2025)

### Completed Work

**Epic 1: MVP Calculator** ✅ COMPLETED
- 7 stories completed, all acceptance criteria met
- 71 tests passing for core calculator functionality
- Full CLI implementation with help system
- Comprehensive error handling and validation

**Epic 2: LLM Integration** ✅ COMPLETED  
- Natural language interface using RubyLLM + Google Gemini
- `ask` command for conversational calculations
- Custom percentage calculator tool for LLM function calling
- 52 additional tests (123 total passing)
- Optional feature (requires API key)

**Epic 3: Product Storage** 🚧 IN PROGRESS
- **Story 3.1: Product Storage Foundation** ✅ COMPLETED
  - SQLite database integration
  - Product CRUD model
  - `store-product` command fully functional
  - 62 new tests (185 total passing)
  - 77% code coverage maintained
  - Zero RuboCop offenses

### Current State

**Test Suite:**
- 185 examples passing
- 1 pending (LLM unavailable scenario)
- 0 failures
- Coverage: 77.29%

**Code Quality:**
- 25 files inspected
- 0 RuboCop offenses
- All style guidelines met

**Features Available:**
1. `calc <amount> <percentage>` - Basic percentage calculations
2. `ask "<question>"` - Natural language calculations (optional, requires GEMINI_API_KEY)
3. `store-product "<name>" <price>` - Store products in local database (optional, requires sqlite3)

### Next Steps

**Epic 4: Natural Language Product Query Interface** - PLANNED
- **Story 4.1:** Product Query Tool with LLM function definitions (4-5 hours)
- **Story 4.2:** Extend Product Model with query methods (3-4 hours)
- **Story 4.3:** Implement ask-product CLI command (4-5 hours)
- Total: 11-14 hours (2-3 days)
- See `docs/epic-product-query.md` for full details

**Story 3.2: List and Retrieve Products** - COMPLETED
- `list-products` command (formatted table display)
- `get-product "<name>"` command (detailed product view)

**Story 3.3: Update and Delete Products** - COMPLETED  
- `update-product` and `delete-product` commands
- Confirmation prompts for destructive actions

**Story 3.4: Calculate on Stored Products** - DEFERRED
- `calc-product "<name>" <percentage>` command
- Integration with existing calc logic
- Deferred in favor of more powerful natural language interface (Epic 4)

### Key Achievements

- Evolved from simple calculator to comprehensive terminal toolkit
- Maintained high code quality throughout (0 offenses, 77% coverage)
- Zero regressions (all existing tests passing with each feature addition)
- Optional features pattern working well (LLM and Storage groups)
- Strong foundation for future expansion
