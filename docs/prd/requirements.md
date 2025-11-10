# Requirements

## Functional

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

**FR12:** (Epic 4) The system shall accept a command in the format `pocket-knife ask-product "<query>"` where query is a natural language question about products

**FR13:** (Epic 4) The system shall interpret natural language queries and execute appropriate product database operations using LLM

**FR14:** (Epic 4) The system shall support product existence queries (e.g., "Is there a product called banana?")

**FR15:** (Epic 4) The system shall support product listing queries (e.g., "Show me all products")

**FR16:** (Epic 4) The system shall support price filtering queries (e.g., "Products under $10")

**FR17:** (Epic 4) The system shall support price range queries (e.g., "Products between $5 and $15")

**FR18:** (Epic 4) The system shall validate that both LLM and Storage features are installed before executing ask-product command

**FR19:** (Epic 4) The system shall validate that GEMINI_API_KEY is configured before executing ask-product command

**FR20:** (Epic 4) The system shall return formatted, human-readable responses for all product queries

**FR21:** (Epic 4) The system shall execute product queries in under 2 seconds (including LLM API call time)

## Non Functional

**NFR1:** The tool must be installable via Rake on systems with Ruby 3.2+ installed

**NFR2:** The codebase shall maintain 80% or greater test coverage with RSpec (adjusted from 90% due to optional features)

**NFR3:** All tests must pass before any release

**NFR4:** Error messages shall be clear, actionable, and guide users toward correct usage

**NFR5:** The tool core shall have zero external gem dependencies; optional features (LLM, Storage) may require additional gems in separate bundle groups

**NFR6:** Code shall follow Ruby community style guidelines as enforced by RuboCop

**NFR7:** The tool shall run on macOS and Linux without modification

**NFR8:** Input validation shall prevent code injection or unsafe operations

**NFR9:** (Epic 4) All SQL queries in Product model extensions shall use parameterized statements to prevent SQL injection

**NFR10:** (Epic 4) The ask-product feature shall degrade gracefully when dependencies are missing, providing clear installation instructions
