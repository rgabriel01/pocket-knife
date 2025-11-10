# Epic 3: Product Storage

**Epic Goal:** Enable users to store products with prices in a local SQLite database and perform calculations on stored products, creating a persistent product catalog for quick price-based calculations.

**Status:** 🚧 IN PROGRESS
- ✅ Story 3.1: Product Storage Foundation - COMPLETED
- ⏳ Story 3.2: List and Retrieve Products - PLANNED
- ⏳ Story 3.3: Update and Delete Products - PLANNED
- ⏳ Story 3.4: Calculate on Stored Products - PLANNED

## Story 3.1: Product Storage Foundation ✅ COMPLETED

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

## Story 3.2: List and Retrieve Products

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

## Story 3.3: Update and Delete Products

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

## Story 3.4: Calculate on Stored Products

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

---
