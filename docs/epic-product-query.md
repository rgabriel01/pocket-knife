# Epic: Natural Language Product Query Interface - Brownfield Enhancement

**Epic ID:** EPIC-4  
**Created:** 2025-11-10  
**Status:** Planning  
**Type:** Brownfield Enhancement

---

## Epic Goal

Enable users to query product information using natural language by adding an `ask-product` command that leverages RubyLLM to interpret queries and execute local product database operations, providing an intuitive alternative to direct CLI commands.

## Epic Description

### Existing System Context

**Current Relevant Functionality:**
- Product storage system using SQLite (CRUD operations via `store-product`, `get-product`, `list-products`, `update-product`, `delete-product` commands)
- LLM integration with Google Gemini via RubyLLM (`ask` command for percentage calculations)
- Product model with attributes: id, name, price, created_at, updated_at
- Database operations: find by name, list all, filter queries

**Technology Stack:**
- Ruby 3.2+
- SQLite3 database
- RubyLLM gem (Google Gemini integration)
- Existing CLI framework in `lib/pocket_knife/cli.rb`
- Product model in `lib/pocket_knife/storage/product.rb`

**Integration Points:**
- CLI routing in `CLI#execute` method (line 41-69 pattern for subcommands)
- LLM configuration via `LLMConfig` class
- Product model static methods (`.find_by_name`, `.all`, custom queries)
- Error handling system (`CLIError`, `InvalidInputError`, `ProductNotFoundError`)

### Enhancement Details

**What's Being Added:**
Add a new `ask-product` CLI command that accepts natural language queries about products and executes appropriate database operations:

```bash
./bin/pocket-knife ask-product "Is there a product called banana?"
./bin/pocket-knife ask-product "Get a list of products that are priced under 10.00"
./bin/pocket-knife ask-product "Show me all products"
./bin/pocket-knife ask-product "What products cost between 5 and 15 dollars?"
```

**How It Integrates:**
1. **CLI Layer:** Add new subcommand routing in `CLI#execute` (similar to existing `ask` command pattern at line 41)
2. **LLM Layer:** Create `ProductQueryTool` class (following `PercentageCalculatorTool` pattern) that defines available product operations as LLM function tools
3. **Data Layer:** Extend `Product` model with query methods for price filtering, range queries, and existence checks
4. **Processing Flow:** 
   - User query → CLI validation → LLM interpretation → Tool function selection → Database query → Formatted response

**Success Criteria:**
- ✅ Users can ask natural language questions about products
- ✅ LLM correctly interprets queries and selects appropriate database operations
- ✅ Supports existence checks ("Is there a product...?")
- ✅ Supports price filtering ("products under X", "products between X and Y")
- ✅ Supports listing operations ("show all products", "list products")
- ✅ Returns human-readable, formatted responses
- ✅ Handles errors gracefully (no API key, no products found, invalid queries)
- ✅ Follows existing CLI patterns and error handling conventions
- ✅ Maintains test coverage >80%

---

## Stories

### Story 1: Create Product Query Tool with LLM Function Definitions

**Description:** Implement `ProductQueryTool` class that defines available product query operations as RubyLLM function tools, enabling the LLM to understand and execute product database queries.

**Technical Approach:**
- Create `lib/pocket_knife/product_query_tool.rb`
- Define function tools: `find_product_by_name`, `list_all_products`, `filter_products_by_price`, `filter_products_by_price_range`
- Follow existing `PercentageCalculatorTool` pattern for function definitions
- Integrate with `Product` model for database operations

**Acceptance Criteria:**
- ProductQueryTool class exists with 4+ query function definitions
- Each function has proper JSON schema definitions
- Functions integrate with Product model methods
- Unit tests cover all function operations

---

### Story 2: Extend Product Model with Query Methods

**Description:** Add filtering and query methods to the `Product` model to support price-based filtering and range queries needed by the natural language interface.

**Technical Approach:**
- Add `Product.filter_by_max_price(max_price)` method
- Add `Product.filter_by_price_range(min_price, max_price)` method
- Add `Product.count` method for statistics
- Use parameterized SQL queries to prevent injection
- Return array of Product instances

**Acceptance Criteria:**
- New query methods exist and return proper Product instances
- SQL queries are parameterized and safe
- Methods handle edge cases (no results, invalid prices)
- Unit tests achieve >90% coverage for new methods
- Existing tests continue to pass

---

### Story 3: Implement ask-product CLI Command

**Description:** Add the `ask-product` subcommand to the CLI that accepts natural language queries, processes them through RubyLLM and ProductQueryTool, and returns formatted responses.

**Technical Approach:**
- Add routing in `CLI#execute` for `ask-product` subcommand
- Create `execute_ask_product` method (similar to `execute_ask` at line 168)
- Validate LLM availability and API key configuration
- Process query through RubyLLM with ProductQueryTool
- Format and display results in human-readable format
- Handle errors: no LLM, no API key, no results, network errors

**Acceptance Criteria:**
- `./bin/pocket-knife ask-product "query"` command works
- Supports existence queries ("Is there a product called X?")
- Supports price filtering ("products under $10")
- Supports price range queries ("products between $5 and $15")
- Supports list all queries ("show all products")
- Returns formatted, human-readable responses
- Shows helpful errors when LLM unavailable or not configured
- Integration tests cover happy path and error scenarios
- E2E tests validate end-to-end functionality

---

## Compatibility Requirements

- [x] Existing product storage commands remain unchanged (`store-product`, `get-product`, etc.)
- [x] Existing `ask` command for percentage calculations unaffected
- [x] Product database schema unchanged (no migrations needed)
- [x] LLM configuration and error handling follows existing patterns
- [x] Optional feature: requires `--with llm` and `--with storage` bundle groups
- [x] CLI help text updated to include new command
- [x] Performance: Query responses under 2 seconds (LLM + DB)

---

## Risk Mitigation

### Primary Risk
**Risk:** LLM misinterprets queries and executes incorrect database operations, returning wrong results or failing unexpectedly.

**Mitigation:**
- Clear, specific function tool definitions with examples
- Validation of function parameters before database execution
- Comprehensive error handling for malformed queries
- Fallback messages suggesting direct CLI commands if LLM fails
- Extensive testing with various query phrasings

**Rollback Plan:**
- New command is additive; existing commands unaffected
- Remove `ask-product` routing from CLI
- Remove ProductQueryTool class
- Remove new Product query methods (existing methods preserved)
- No database changes to rollback

### Secondary Risks

**Risk:** API rate limiting or cost concerns with increased LLM usage

**Mitigation:**
- Document that this is an optional convenience feature
- Encourage direct CLI commands for scripting/automation
- Monitor usage patterns in documentation

**Risk:** Complex queries that require multiple database operations

**Mitigation:**
- Start with single-operation queries (MVP scope)
- Document supported query types clearly
- Add more complex operations in future iterations if needed

---

## Definition of Done

- [x] All 3 stories completed with acceptance criteria met
- [x] ProductQueryTool class implemented with 4+ function definitions
- [x] Product model extended with price filtering methods
- [x] `ask-product` CLI command fully functional
- [x] Test coverage >80% maintained across all new code
- [x] All existing tests pass without modification
- [x] Integration tests validate CLI → LLM → Database flow
- [x] E2E tests cover primary use cases
- [x] README.md updated with `ask-product` command examples
- [x] Help text (`--help`) includes `ask-product` documentation
- [x] Error messages are clear and actionable
- [x] Code follows RuboCop style guidelines
- [x] Manual testing validates all example queries work correctly

---

## Technical Architecture Notes

### File Structure
```
lib/pocket_knife/
  ├── cli.rb                          # Add ask-product routing
  ├── product_query_tool.rb           # NEW: LLM function tool definitions
  ├── storage/
  │   ├── product.rb                  # Extend with query methods
  │   └── database.rb                 # No changes needed

spec/
  ├── unit/
  │   └── product_query_tool_spec.rb  # NEW: Unit tests
  ├── integration/
  │   └── ask_product_cli_spec.rb     # NEW: Integration tests
  └── e2e/
      └── pocket_knife_spec.rb        # Add ask-product scenarios
```

### Dependencies
- Requires: `ruby_llm` gem (already available in `:llm` group)
- Requires: `sqlite3` gem (already available in `:storage` group)
- No new external dependencies needed

### Query Processing Flow
```
User Input → CLI Validation → LLM Query
    ↓
LLM Interpretation → Function Tool Selection
    ↓
ProductQueryTool → Product Model Methods
    ↓
Database Query → Results Formatting → User Output
```

---

## Out of Scope (Future Enhancements)

- Multi-step queries requiring multiple database operations
- Aggregation queries (sum, average, statistics)
- Product updates or deletions via natural language
- Fuzzy matching or typo tolerance in product names
- Sorting and ordering preferences
- Pagination for large result sets
- Export results to CSV/JSON formats
- Query history or saved queries

---

## Success Metrics

**User Experience:**
- Users can successfully query products without memorizing exact CLI syntax
- Natural language queries complete in <2 seconds
- Error messages guide users to successful query formulation

**Technical:**
- Test coverage remains >80%
- Zero regressions in existing functionality
- LLM query success rate >90% for documented query types

**Adoption:**
- Feature documented in README with clear examples
- Help text accessible via `--help` flag
- Query patterns validated through testing

---

## References

- **Existing LLM Integration:** See `lib/pocket_knife/cli.rb` `execute_ask` method (line 168+)
- **Existing Tool Pattern:** See `lib/pocket_knife/percentage_calculator_tool.rb`
- **Product Model:** See `lib/pocket_knife/storage/product.rb`
- **LLM Config:** See `lib/pocket_knife/llm_config.rb`
- **Original PRD:** See `docs/prd.md`
- **LLM Integration Epic:** See `docs/epic-llm-integration.md`

---

**Epic Owner:** PM (John)  
**Estimated Effort:** 2-3 days (1 day per story)  
**Priority:** Medium  
**Target Sprint:** Next available
