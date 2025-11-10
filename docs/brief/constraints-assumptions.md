# Constraints & Assumptions

## Constraints

- **Budget:** $0 - Personal project with no monetary investment beyond time
- **Timeline:** 2 weeks for MVP development (part-time effort, approximately 20-30 hours total)
- **Resources:** Solo developer project - no team collaboration for MVP
- **Technical:** 
  - Must run on Ruby 3.2+ (no backwards compatibility for older Ruby versions)
  - Local installation only (no cloud hosting or distribution infrastructure)
  - Command-line interface only (no GUI or web interface)
  - No external API dependencies or network requirements

## Key Assumptions

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
