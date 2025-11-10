# MVP Scope

## Core Features (Must Have)

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

## Out of Scope for MVP

- Short command aliases (e.g., `pk`)
- Additional calculation modes (increase, decrease, percentage-of)
- Output formatting options (verbose mode, precision control, colors)
- Configuration files or user preferences
- Interactive mode or REPL
- RubyGems publication
- Shell completion scripts
- Version checking or auto-updates

## MVP Success Criteria

The MVP is considered successful when:
- ✅ A user can install the tool via `rake install`
- ✅ The tool correctly calculates X% of Y for all valid numeric inputs
- ✅ Invalid inputs produce clear error messages without crashes
- ✅ `--help` displays complete usage instructions
- ✅ Execution completes in < 100ms
- ✅ Test suite achieves 90%+ coverage and all tests pass
