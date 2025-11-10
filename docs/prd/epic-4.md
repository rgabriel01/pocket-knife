# Epic 4: Natural Language Product Query Interface

**Epic Goal:** Enable users to query product information using natural language by adding an `ask-product` command that leverages RubyLLM to interpret queries and execute local product database operations, providing an intuitive alternative to direct CLI commands.

**Status:** 📋 PLANNED
- ⏳ Story 4.1: Product Query Tool with LLM Function Definitions - PLANNED
- ⏳ Story 4.2: Extend Product Model with Query Methods - PLANNED
- ⏳ Story 4.3: Implement ask-product CLI Command - PLANNED

**Epic Details:** See `docs/epic-product-query.md` for complete epic documentation.

**User Stories:** See `docs/stories/4.1.story.md`, `docs/stories/4.2.story.md`, `docs/stories/4.3.story.md` for detailed specifications.

## Story 4.1: Product Query Tool with LLM Function Definitions

As a developer,
I want a ProductQueryTool that defines product database operations as RubyLLM function tools,
so that the LLM can interpret natural language queries and execute appropriate product database operations.

**Acceptance Criteria:**

1. ProductQueryTool class created inheriting from RubyLLM::Tool
2. Function tool: `find_product_by_name` - Search by exact name
3. Function tool: `list_all_products` - Get all products
4. Function tool: `filter_products_by_max_price` - Products under a price
5. Function tool: `filter_products_by_price_range` - Products between two prices
6. Response formatting is consistent and user-friendly
7. Input validation prevents invalid queries
8. Comprehensive error handling
9. 100% test coverage for ProductQueryTool
10. All existing tests pass
11. Code follows existing patterns

**Estimate:** 4-5 hours  
**Details:** See `docs/stories/4.1.story.md`

## Story 4.2: Extend Product Model with Query Methods

As a developer,
I want Product model extended with price filtering and query methods,
so that the ProductQueryTool can execute sophisticated product searches from natural language queries.

**Acceptance Criteria:**

1. `Product.filter_by_max_price(max_price)` method implemented
2. `Product.filter_by_price_range(min_price, max_price)` method implemented
3. `Product.count` method implemented
4. All SQL queries use parameterized statements (security)
5. Results ordered by price ascending, then name ascending
6. Input validation prevents invalid queries
7. 25+ new unit tests added
8. All existing tests pass
9. Test coverage >80% maintained
10. RuboCop passes
11. No database schema changes required

**Estimate:** 3-4 hours  
**Details:** See `docs/stories/4.2.story.md`

## Story 4.3: Implement ask-product CLI Command

As a user,
I want to query my product database using natural language via the ask-product command,
so that I can find products without memorizing exact CLI syntax or product names.

**Acceptance Criteria:**

1. `ask-product "<query>"` command routing added to CLI
2. Dependency validation (LLM + Storage availability)
3. API key configuration validation
4. Query extraction and validation
5. LLM integration processes queries correctly
6. Supported queries:
   - Existence: "Is there a product called banana?"
   - List all: "Show me all products"
   - Price filter: "Products under $10"
   - Price range: "Products between $5 and $15"
7. Comprehensive error handling (network, API, validation)
8. Help text updated with examples
9. README.md updated with documentation
10. 10+ integration tests created
11. 3+ E2E tests created
12. All existing tests pass
13. Manual testing validates all query types

**Estimate:** 4-5 hours  
**Details:** See `docs/stories/4.3.story.md`

**Command Examples:**
```bash
# Check if product exists
pocket-knife ask-product "Is there a product called banana?"

# List all products
pocket-knife ask-product "Show me all products"

# Filter by price
pocket-knife ask-product "What products cost less than $10?"

# Filter by price range
pocket-knife ask-product "Products between $5 and $15"
```

**Dependencies:**
- Requires: `bundle install --with llm storage`
- Requires: GEMINI_API_KEY environment variable
- Builds on: Epic 2 (LLM Integration) and Epic 3 (Product Storage)

**Total Epic Estimate:** 11-14 hours (2-3 days)
