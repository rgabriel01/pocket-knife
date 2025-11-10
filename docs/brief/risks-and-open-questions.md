# Risks & Open Questions

## Key Risks

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

## Open Questions

- How should the tool handle edge cases like negative percentages, zero values, or extremely large numbers?
- Should there be a maximum input value to prevent overflow or performance issues?
- Is `calc` the best subcommand name, or would `percent`, `of`, or something else be clearer?
- Should help text include examples, or just syntax reference?

## Design Decisions Made

- ✅ **Percentage input format:** Accept only whole numbers without `%` symbol (e.g., `pocket-knife calc 100 20` not `100 20%`)
  - *Rationale:* Simpler parsing, cleaner syntax, fewer potential input errors

- ✅ **Result precision display:** Always show two decimal places (e.g., `20.00` not `20.0` or `20`)
  - *Rationale:* Consistent formatting, professional appearance, clear for financial calculations, matches calculator conventions

## Areas Needing Further Research

- **Ruby CLI best practices:** Research thor vs OptionParser vs other argument parsing libraries for best DX
- **Testing CLI applications:** Investigate RSpec patterns for testing command-line output and error handling
- **Performance optimization:** Research Ruby startup time and potential optimizations (bootsnap, etc.)
- **Input validation patterns:** Study how other CLI tools handle numeric input validation and error messages
- **Distribution methods:** Understand Rake install vs Gems vs other Ruby tool distribution approaches
