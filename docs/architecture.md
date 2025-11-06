# Architecture Document: Pocket Knife CLI

**Project:** Pocket Knife - Command-Line Toolkit  
**Version:** 2.0  
**Date:** November 6, 2025  
**Architect:** Winston (BMad Architect Agent)  
**Status:** ✅ Evolved - MVP + LLM + Storage Foundation Complete

**Revision History:**
- v1.0 (Nov 4, 2025): Initial MVP architecture
- v1.5 (Nov 5, 2025): Added LLM Integration architecture
- v2.0 (Nov 6, 2025): Added Product Storage architecture and Story 3.2 design

---

## Table of Contents

1. [Introduction](#1-introduction)
2. [High-Level Architecture](#2-high-level-architecture)
3. [Technology Stack](#3-technology-stack)
4. [Data Models](#4-data-models)
5. [Components](#5-components)
6. [Core Workflows](#6-core-workflows)
7. [Source Tree](#7-source-tree)
8. [Infrastructure & Deployment](#8-infrastructure--deployment)
9. [Error Handling Strategy](#9-error-handling-strategy)
10. [Coding Standards](#10-coding-standards)
11. [Test Strategy and Standards](#11-test-strategy-and-standards)
12. [Security](#12-security)
13. [Checklist Results Report](#13-checklist-results-report)
14. [Next Steps](#14-next-steps)

---

## 1. Introduction

### 1.1 Purpose

This document defines the technical architecture for **Pocket Knife**, a Ruby-based command-line utility for performing percentage calculations. The architecture is designed specifically for AI-driven development, providing explicit patterns, clear component boundaries, and comprehensive implementation guidance.

### 1.2 Project Overview

**Problem Statement:** Users need a fast, reliable CLI tool for common percentage calculations, natural language interactions, and product price management without opening external applications or web browsers.

**Solution:** A Ruby CLI toolkit that provides:
1. **Instant percentage calculations** with clear output formatting
2. **Natural language interface** using Google Gemini LLM (optional)
3. **Product storage** with SQLite for price catalog management (optional)

**Target Users:**
- Developers performing quick calculations during coding
- Data analysts working in terminal environments
- System administrators calculating resource percentages
- Students learning command-line tools
- Anyone managing product catalogs and pricing

**Current Features:**
- ✅ Core calculator: `calc <amount> <percentage>`
- ✅ LLM interface: `ask "<question>"` (optional, requires API key)
- ✅ Product storage: `store-product "<name>" <price>` (optional, requires sqlite3)
- 🚧 Product listing: `list-products` (Story 3.2 - in design)
- 🚧 Product retrieval: `get-product "<name>"` (Story 3.2 - in design)

### 1.3 Key Design Principles

1. **Simplicity First** - Core has zero runtime dependencies, optional features are truly optional
2. **AI-Optimized** - Explicit patterns, no metaprogramming, clear interfaces
3. **Fail-Fast** - Input validation at boundaries, explicit error handling
4. **Test-Driven** - 75%+ coverage requirement, comprehensive test strategy
5. **User-Friendly** - Clear help text, informative error messages, intuitive syntax
6. **Optional Features** - Core calculator works standalone, LLM and Storage are opt-in
7. **Data Persistence** - SQLite for local storage, no network dependencies

### 1.4 Architectural Approach

**Design Philosophy:** This architecture has evolved from a simple calculator to a comprehensive toolkit while maintaining clean boundaries:

**Phase 1 - MVP (Epic 1):**
- Three-layer CLI design (Entry → CLI → Calculator)
- Zero runtime dependencies (stdlib only)
- Stateless calculations
- 71 tests, 90%+ coverage

**Phase 2 - LLM Integration (Epic 2):**
- Added optional LLM features (RubyLLM + Google Gemini)
- Natural language interface via `ask` command
- Custom tool implementation for function calling
- 123 total tests, maintained quality

**Phase 3 - Product Storage (Epic 3 - In Progress):**
- Added optional SQLite storage
- Product catalog management
- CRUD operations with data persistence
- 185 total tests, 77% coverage
- Clean separation: Database (connection) vs Product (model)

**Key Architectural Decisions:**
- Optional features via Bundler groups (`:llm`, `:storage`)
- Core calculator remains dependency-free
- Lazy loading of optional modules
- Consistent error handling across all features
- Test isolation for storage (tmpdir pattern)

---

## 2. High-Level Architecture

### 2.1 System Context

```
┌────────────────────────────────────────────────────────────────────────┐
│                            User                                         │
│                       (Terminal Shell)                                  │
└──────────────┬─────────────────────────────────────────────────────────┘
               │
               │ Commands:
               │ • calc <amount> <percentage>
               │ • ask "<question>"  [Optional: LLM]
               │ • store-product "<name>" <price>  [Optional: Storage]
               │ • list-products  [Optional: Storage]
               │ • get-product "<name>"  [Optional: Storage]
               ▼
┌────────────────────────────────────────────────────────────────────────┐
│                      Pocket Knife CLI                                   │
│                      (Ruby 3.2+ Binary)                                 │
│                                                                          │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │                    Core Layer (Required)                          │  │
│  │  ┌────────────┐  ┌─────────────┐  ┌──────────────┐             │  │
│  │  │Entry Point │→ │ CLI Router  │→ │  Calculator  │             │  │
│  │  │  (bin/)    │  │  (lib/cli)  │  │  (lib/calc)  │             │  │
│  │  └────────────┘  └─────────────┘  └──────────────┘             │  │
│  └──────────────────────────────────────────────────────────────────┘  │
│                                                                          │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │           Optional Layer: LLM (require API key)                  │  │
│  │  ┌─────────────┐  ┌──────────────┐  ┌────────────────┐         │  │
│  │  │ LLM Config  │→ │ RubyLLM Gem  │→ │ Google Gemini  │         │  │
│  │  │(llm_config) │  │(ruby_llm 1.9)│  │   API (Web)    │         │  │
│  │  └─────────────┘  └──────────────┘  └────────────────┘         │  │
│  └──────────────────────────────────────────────────────────────────┘  │
│                                                                          │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │      Optional Layer: Storage (require sqlite3 gem)               │  │
│  │  ┌──────────────┐  ┌──────────────┐                             │  │
│  │  │   Database   │→ │    Product   │                             │  │
│  │  │(connection)  │  │    (model)   │                             │  │
│  │  └──────┬───────┘  └──────────────┘                             │  │
│  │         │                                                         │  │
│  │         ▼                                                         │  │
│  │  ┌─────────────────────────────────────┐                        │  │
│  │  │  SQLite Database                     │                        │  │
│  │  │  ~/.pocket-knife/products.db         │                        │  │
│  │  │  • id, name, price, timestamps       │                        │  │
│  │  └─────────────────────────────────────┘                        │  │
│  └──────────────────────────────────────────────────────────────────┘  │
│                                                                          │
│  Flow: Input → Route → Validate → Execute → Format → Output            │
└────────────────────────────────────────────────────────────────────────┘
               │
               │ Output: Results/Errors
               ▼
          Terminal (STDOUT)
```

**System Characteristics:**
- **Type:** Modular command-line toolkit
- **Runtime:** Ruby 3.2+ (MRI interpreter)
- **Core Dependencies:** Zero (stdlib only)
- **Optional Dependencies:** 
  - LLM: ruby_llm ~> 1.9, dotenv ~> 2.8 (Gemini API)
  - Storage: sqlite3 ~> 1.7
- **State:** 
  - Core: Stateless calculations
  - Storage: Persistent SQLite database at ~/.pocket-knife/
- **Network:** 
  - Core: None (fully offline)
  - LLM: HTTPS to Google Gemini API (when enabled)

### 2.2 Architectural Layers

The system follows a **three-layer architecture** with optional feature modules:

#### **Layer 1: Entry Point (bin/pocket-knife)**
- **Responsibility:** Bootstrap application, route to CLI module
- **Technology:** Ruby executable script with shebang
- **Dependencies:** CLI module only
- **Size:** ~20 LOC

#### **Layer 2: CLI Router (lib/pocket_knife/cli.rb)**
- **Responsibility:** 
  - Command routing (calc, ask, store-product, list-products, get-product)
  - Argument parsing and validation
  - Output formatting (tables, JSON, plain text)
  - Help text display
  - Feature availability checks (LLM, Storage)
- **Technology:** Ruby class with OptionParser (stdlib)
- **Dependencies:** 
  - Core: Calculator, CalculationRequest, CalculationResult, Errors
  - Optional: LLMConfig (LLM feature), Database, Product (Storage feature)
- **Size:** ~400 LOC

#### **Layer 3: Business Logic Modules**

**Core Module: Calculator (lib/pocket_knife/calculator.rb)**
- **Responsibility:** Percentage calculations (basic, percentage of, percentage change)
- **Technology:** Pure Ruby class with single-purpose methods
- **Dependencies:** None (zero dependencies)
- **Size:** ~80 LOC

**Optional Module: LLM Integration (lib/pocket_knife/llm_config.rb)**
- **Responsibility:** Google Gemini API configuration and question handling
- **Technology:** Ruby with RubyLLM gem wrapper
- **Dependencies:** ruby_llm, dotenv (optional gems)
- **Size:** ~60 LOC
- **Activation:** Requires API key in .env file

**Optional Module: Storage (lib/pocket_knife/storage/)**
- **Responsibility:** Product persistence (CRUD operations)
- **Technology:** SQLite database with auto-initialization
- **Components:**
  - Database: Connection management, schema migrations
  - Product: Model with validation and queries
- **Dependencies:** sqlite3 gem (optional)
- **Size:** ~200 LOC
- **Activation:** Auto-enabled when sqlite3 gem installed

**Data Flow (Calculator):**
```
User Input: calc 200 15
  ↓
Entry Point (bin/pocket-knife)
  ↓
CLI Router (parse & validate)
  ↓
Calculator (compute: 200 * 0.15 = 30.00)
  ↓
CLI Router (format result)
  ↓
STDOUT: 30.00
```

**Data Flow (Storage):**
```
User Input: store-product "Laptop" 999.99
  ↓
Entry Point (bin/pocket-knife)
  ↓
CLI Router (parse & validate, check storage available)
  ↓
Database (ensure connection, run migrations)
  ↓
Product.create (validate, check duplicates, insert)
  ↓
CLI Router (format confirmation)
  ↓
STDOUT: ✓ Product "Laptop" stored successfully
```

**Data Flow (LLM):**
```
User Input: ask "What is 15% of 200?"
  ↓
Entry Point (bin/pocket-knife)
  ↓
CLI Router (check LLM available, load config)
  ↓
LLMConfig (load API key, call Gemini API)
  ↓
CLI Router (format response)
  ↓
STDOUT: AI-generated answer
```

### 2.3 Data Models

#### **Product Model** (Storage Feature)

**Schema:**
```sql
CREATE TABLE products (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE,
  price REAL NOT NULL CHECK (price >= 0),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_products_name ON products (name);
```

**Model Attributes:**
- `id` (Integer): Auto-incrementing primary key
- `name` (String): Product name, must be unique (case-insensitive), required
- `price` (Float): Product price in currency units, must be >= 0, required
- `created_at` (DateTime): Auto-set on creation
- `updated_at` (DateTime): Auto-set on creation and updates

**Model Methods:**
```ruby
# lib/pocket_knife/storage/product.rb
class Product
  # CRUD Operations
  def self.create(name:, price:)           # Create new product
  def self.find_by_name(name)               # Retrieve by name (case-insensitive)
  def self.all                              # Retrieve all products (ordered by created_at)
  def self.exists?(name)                    # Check if product exists (boolean)
  
  # Validation
  def self.validate_name!(name)             # Raises InvalidProductName if invalid
  def self.validate_price!(price)           # Raises InvalidProductPrice if invalid
  
  # Formatting
  def formatted_price                       # Returns "$123.45" format
end
```

**Validation Rules:**
- Name: Must be present, non-empty string (error: InvalidProductName)
- Price: Must be numeric, >= 0 (error: InvalidProductPrice)
- Uniqueness: Name must be unique (error: DuplicateProductError)

**Database Location:**
- Path: `~/.pocket-knife/products.db`
- Auto-created on first use
- Auto-migrated to latest schema version

### 2.4 Design Patterns

1. **Command Pattern** - CLI subcommands route to specific operations
2. **Strategy Pattern** - Different calculation types use consistent interface
3. **Fail-Fast Validation** - Input errors caught at boundaries before processing
4. **Single Responsibility Principle** - Each module has one clear purpose
5. **Dependency Inversion** - Calculator/Storage have no knowledge of CLI layer
6. **Active Record Pattern** - Product model combines data and behavior
7. **Lazy Loading** - Optional features loaded only when used
8. **Auto-Migration** - Database schema updates automatically on version change

---

## 3. Technology Stack

### 3.1 Core Technology

| Component | Technology | Version | Justification |
|-----------|-----------|---------|---------------|
| **Language** | Ruby (MRI) | 3.2+ | Modern Ruby features, excellent stdlib, AI-friendly syntax |
| **CLI Parsing** | OptionParser | stdlib | Zero dependencies, sufficient for simple CLI |
| **Testing** | RSpec | 3.12+ | Industry standard, excellent matchers, readable syntax |
| **Code Coverage** | SimpleCov | 0.22+ | Visual coverage reports, CI integration |
| **Linting** | RuboCop | 1.57+ | Consistent style, security cops, AI-friendly rules |
| **Build Tool** | Rake | 13.0+ | Standard Ruby task automation |

### 3.2 Runtime Dependencies

**Core:** ✅ **ZERO runtime dependencies**
- OptionParser is part of Ruby stdlib (no gem required)
- All calculations use pure Ruby (no math libraries)
- Fully functional without any gems installed

**Optional Feature Dependencies:**
```ruby
# Gemfile (optional feature groups)

# LLM Feature (AI question answering)
group :llm do
  gem 'ruby_llm', '~> 1.9'   # Google Gemini API wrapper
  gem 'dotenv', '~> 2.8'      # .env file support for API keys
end

# Storage Feature (product persistence)
group :storage do
  gem 'sqlite3', '~> 1.7'     # SQLite database driver
end
```

**Installation:**
```bash
# Core only (calculator)
bundle install

# With LLM feature
bundle install --with llm

# With Storage feature
bundle install --with storage

# With all features
bundle install --with llm storage
```

**Development/Test Dependencies:**
```ruby
# Gemfile (dev/test only)
group :development, :test do
  gem 'rspec', '~> 3.12'
  gem 'simplecov', '~> 0.22'
  gem 'rubocop', '~> 1.57'
  gem 'rake', '~> 13.0'
end
```

### 3.3 Alternative Technologies Considered

| Technology | Pros | Cons | Decision |
|------------|------|------|----------|
| **Thor CLI** | Rich features, subcommand DSL | Runtime dependency, overkill for simple CLI | ❌ Rejected |
| **Slop** | Clean API, minimal | Still a dependency | ❌ Rejected |
| **OptionParser** | Zero dependencies, sufficient | Less feature-rich | ✅ **Selected** |
| **Minitest** | Stdlib, no dependency | Less readable than RSpec | ❌ Rejected |
| **RSpec** | Readable, powerful matchers | Test-only dependency (acceptable) | ✅ **Selected** |

### 3.4 Version Requirements

**Ruby Version:**
- **Minimum:** Ruby 3.2.0
- **Recommended:** Ruby 3.2.2+ (latest stable)
- **Rationale:** Modern syntax, performance improvements, security patches

**Gem Version Locking:**
- Use `Gemfile.lock` for reproducible builds
- Run `bundle audit` monthly for security updates
- Pin major versions in Gemfile (`~>` operator)

---

## 4. Data Models

### 4.1 CalculationRequest (Input)

Represents a validated user request for percentage calculation.

```ruby
# lib/pocket_knife/calculation_request.rb
module PocketKnife
  class CalculationRequest
    attr_reader :percentage, :base, :operation

    # @param percentage [Integer] Whole number percentage (e.g., 15 for 15%)
    # @param base [Float] The base number to calculate percentage of
    # @param operation [Symbol] Type of calculation (:percent_of)
    def initialize(percentage:, base:, operation: :percent_of)
      @percentage = percentage
      @base = base
      @operation = operation
    end

    def valid?
      percentage.is_a?(Integer) &&
        base.is_a?(Numeric) &&
        percentage >= 0 &&
        base.finite?
    end
  end
end
```

**Fields:**
- `percentage` (Integer, required): Whole number 0-999, represents percentage value
- `base` (Float, required): Any finite number, the base for calculation
- `operation` (Symbol, optional): Calculation type, defaults to `:percent_of`

**Validation Rules:**
- Percentage must be whole number (no decimals)
- Percentage cannot be negative
- Base must be finite (not Infinity or NaN)
- Both values required for calculation

**Example:**
```ruby
request = CalculationRequest.new(percentage: 15, base: 200.0)
# => Calculates 15% of 200
```

### 4.2 CalculationResult (Output)

Represents the formatted result of a calculation.

```ruby
# lib/pocket_knife/calculation_result.rb
module PocketKnife
  class CalculationResult
    attr_reader :value, :formatted_value, :request

    # @param value [Float] Raw calculation result
    # @param request [CalculationRequest] Original request
    def initialize(value:, request:)
      @value = value
      @request = request
      @formatted_value = format_value(value)
    end

    def to_s
      formatted_value
    end

    private

    def format_value(val)
      format('%.2f', val)
    end
  end
end
```

**Fields:**
- `value` (Float, required): Raw calculation result (e.g., 30.0)
- `formatted_value` (String, computed): Formatted to 2 decimal places (e.g., "30.00")
- `request` (CalculationRequest, required): Reference to original request for context

**Formatting Rules:**
- Always 2 decimal places (e.g., 30.00, not 30 or 30.0)
- No thousands separators
- Negative values prefixed with minus sign
- Zero values display as "0.00"

**Example:**
```ruby
result = CalculationResult.new(value: 30.0, request: request)
puts result.to_s  # => "30.00"
```

### 4.3 Data Flow

```
Command Line Input
  ↓
["calc", "--percent", "15", "--of", "200"]
  ↓
CLI Parsing (OptionParser)
  ↓
{ percentage: "15", base: "200" }
  ↓
Validation & Type Conversion
  ↓
CalculationRequest(percentage: 15, base: 200.0)
  ↓
Calculator.calculate(request)
  ↓
CalculationResult(value: 30.0, formatted: "30.00")
  ↓
STDOUT
  ↓
"30.00"
```

---

## 5. Components

### 5.1 Entry Point: bin/pocket-knife

**Responsibility:** Application entry point, delegates to CLI module.

**Implementation:**
```ruby
#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/pocket_knife'

begin
  PocketKnife::CLI.run(ARGV)
  exit 0
rescue PocketKnife::InvalidInputError => e
  warn "Error: #{e.message}"
  exit 2
rescue PocketKnife::CLIError => e
  warn "Error: #{e.message}"
  exit 1
rescue StandardError => e
  warn "Unexpected error: #{e.message}"
  exit 1
end
```

**Responsibilities:**
- Load application code
- Invoke CLI.run with command-line arguments
- Catch exceptions and set exit codes
- Output errors to STDERR

**Exit Codes:**
- `0`: Success
- `1`: General CLI error
- `2`: Invalid input error

### 5.2 CLI Module: lib/pocket_knife/cli.rb

**Responsibility:** Parse arguments, validate input, format output, display help.

**Public Interface:**
```ruby
module PocketKnife
  class CLI
    # Main entry point for CLI
    # @param args [Array<String>] Command-line arguments
    # @return [void]
    def self.run(args)
      new(args).execute
    end

    # Parse arguments and execute command
    # @return [void]
    def execute
      parse_arguments
      validate_inputs
      result = calculate
      output(result)
    end

    private

    def parse_arguments
      # Use OptionParser to extract --percent and --of
    end

    def validate_inputs
      # Ensure percentage is integer, base is numeric
      # Raise InvalidInputError if invalid
    end

    def calculate
      # Delegate to Calculator module
    end

    def output(result)
      # Print formatted result to STDOUT
    end
  end
end
```

**Key Methods:**
- `parse_arguments`: Use OptionParser to extract `--percent` and `--of` flags
- `validate_inputs`: Type check and range validation, raises errors
- `calculate`: Creates CalculationRequest, calls Calculator
- `output`: Formats and prints result to STDOUT
- `display_help`: Shows usage text with examples

**Dependencies:**
- OptionParser (stdlib)
- PocketKnife::Calculator
- PocketKnife::InvalidInputError

### 5.3 Calculator Module: lib/pocket_knife/calculator.rb

**Responsibility:** Pure business logic for percentage calculations.

**Public Interface:**
```ruby
module PocketKnife
  class Calculator
    # Calculate percentage of a number
    # @param request [CalculationRequest] Validated calculation request
    # @return [CalculationResult] Result with formatted value
    # @raise [CalculationError] If calculation fails
    def self.calculate(request)
      validate_request(request)
      value = compute_percentage(request.percentage, request.base)
      CalculationResult.new(value: value, request: request)
    end

    private

    # @param percentage [Integer] Whole number percentage
    # @param base [Float] Base number
    # @return [Float] Calculated result
    def self.compute_percentage(percentage, base)
      (percentage / 100.0) * base
    end

    # @param request [CalculationRequest] Request to validate
    # @raise [CalculationError] If request invalid
    def self.validate_request(request)
      raise CalculationError, 'Invalid request' unless request.valid?
    end
  end
end
```

**Key Methods:**
- `calculate`: Main entry point, returns CalculationResult
- `compute_percentage`: Pure calculation logic (percentage / 100.0) * base
- `validate_request`: Ensures request is valid before calculation

**Dependencies:** ✅ **ZERO** (no external dependencies)

**Testing Focus:**
- Edge cases: zero percentage, zero base, negative numbers
- Precision: verify 2 decimal place accuracy
- Large numbers: test with big integers/floats
- Invalid requests: proper error raising

### 5.4 Error Classes: lib/pocket_knife/errors.rb

**Responsibility:** Custom exception hierarchy for domain errors.

```ruby
module PocketKnife
  # Base error class for all Pocket Knife errors
  class PocketKnifeError < StandardError; end

  # Invalid user input (exit code 2)
  class InvalidInputError < PocketKnifeError; end

  # Calculation failure (exit code 1)
  class CalculationError < PocketKnifeError; end

  # CLI usage error (exit code 1)
  class CLIError < PocketKnifeError; end

  # Configuration error (exit code 1)
  class ConfigurationError < PocketKnifeError; end
  
  # Storage feature errors
  class StorageError < PocketKnifeError; end
  class StorageNotAvailableError < StorageError; end
  class InvalidProductNameError < StorageError; end
  class InvalidProductPriceError < StorageError; end
  class DuplicateProductError < StorageError; end
  class ProductNotFoundError < StorageError; end
end
```

### 5.5 Storage Module: lib/pocket_knife/storage/database.rb

**Responsibility:** SQLite connection management, schema migrations, database lifecycle.

**Public Interface:**
```ruby
module PocketKnife
  module Storage
    class Database
      # Get SQLite database connection (lazy initialization)
      # @return [SQLite3::Database] Database connection
      def self.connection
        @connection ||= initialize_database
      end

      # Check if storage is available (sqlite3 gem installed)
      # @return [Boolean] True if storage can be used
      def self.storage_available?
        require 'sqlite3'
        true
      rescue LoadError
        false
      end

      # Reset database connection (for testing)
      # @return [void]
      def self.reset_connection!
        @connection&.close
        @connection = nil
      end

      # Get database file path
      # @return [String] Absolute path to products.db
      def self.db_path
        File.join(storage_dir, 'products.db')
      end

      # Get storage directory path
      # @return [String] Absolute path to ~/.pocket-knife/
      def self.storage_dir
        File.join(Dir.home, '.pocket-knife')
      end

      private

      # Initialize database, create directory, run migrations
      # @return [SQLite3::Database] Initialized connection
      def self.initialize_database
        FileUtils.mkdir_p(storage_dir)
        db = SQLite3::Database.new(db_path)
        run_migrations(db)
        db
      end

      # Create tables and indexes if not exist
      # @param db [SQLite3::Database] Database connection
      # @return [void]
      def self.run_migrations(db)
        db.execute <<-SQL
          CREATE TABLE IF NOT EXISTS products (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL UNIQUE COLLATE NOCASE,
            price REAL NOT NULL CHECK (price >= 0),
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
            updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
          );
        SQL
        
        db.execute <<-SQL
          CREATE INDEX IF NOT EXISTS idx_products_name 
          ON products (name COLLATE NOCASE);
        SQL
      end
    end
  end
end
```

**Key Methods:**
- `connection`: Lazy-loading singleton database connection
- `storage_available?`: Feature detection (checks for sqlite3 gem)
- `reset_connection!`: Close and reset connection (for testing)
- `db_path`: Returns `~/.pocket-knife/products.db`
- `storage_dir`: Returns `~/.pocket-knife/`
- `initialize_database`: Create directory, open database, run migrations
- `run_migrations`: Execute schema creation DDL

**Dependencies:**
- sqlite3 gem (optional, detected at runtime)
- FileUtils (stdlib)

### 5.6 Storage Module: lib/pocket_knife/storage/product.rb

**Responsibility:** Product model with CRUD operations, validation, formatting.

**Public Interface:**
```ruby
module PocketKnife
  module Storage
    class Product
      attr_reader :id, :name, :price, :created_at, :updated_at

      # Create new product in database
      # @param name [String] Product name (required, unique)
      # @param price [Float] Product price (required, >= 0)
      # @return [Product] Created product instance
      # @raise [InvalidProductNameError] If name invalid
      # @raise [InvalidProductPriceError] If price invalid
      # @raise [DuplicateProductError] If name exists
      def self.create(name:, price:)
        validate_name!(name)
        validate_price!(price)
        
        if exists?(name)
          raise DuplicateProductError, "Product '#{name}' already exists"
        end
        
        db = Database.connection
        db.execute(
          'INSERT INTO products (name, price) VALUES (?, ?)',
          [name, price.to_f]
        )
        
        find_by_name(name)
      end

      # Find product by name (case-insensitive)
      # @param name [String] Product name
      # @return [Product, nil] Product instance or nil if not found
      def self.find_by_name(name)
        db = Database.connection
        row = db.get_first_row(
          'SELECT * FROM products WHERE name = ? COLLATE NOCASE',
          [name]
        )
        
        return nil unless row
        
        new(
          id: row[0],
          name: row[1],
          price: row[2],
          created_at: row[3],
          updated_at: row[4]
        )
      end

      # Retrieve all products ordered by created_at
      # @return [Array<Product>] All products (empty array if none)
      def self.all
        db = Database.connection
        rows = db.execute('SELECT * FROM products ORDER BY created_at ASC')
        
        rows.map do |row|
          new(
            id: row[0],
            name: row[1],
            price: row[2],
            created_at: row[3],
            updated_at: row[4]
          )
        end
      end

      # Check if product exists (case-insensitive)
      # @param name [String] Product name
      # @return [Boolean] True if exists
      def self.exists?(name)
        !find_by_name(name).nil?
      end

      # Validate product name
      # @param name [String] Product name
      # @raise [InvalidProductNameError] If name invalid
      def self.validate_name!(name)
        if name.nil? || name.to_s.strip.empty?
          raise InvalidProductNameError, 'Product name cannot be empty'
        end
      end

      # Validate product price
      # @param price [Float] Product price
      # @raise [InvalidProductPriceError] If price invalid
      def self.validate_price!(price)
        numeric_price = Float(price)
        if numeric_price.negative?
          raise InvalidProductPriceError, 'Price cannot be negative'
        end
      rescue ArgumentError, TypeError
        raise InvalidProductPriceError, 'Price must be a valid number'
      end

      # Initialize product instance (private)
      def initialize(id:, name:, price:, created_at:, updated_at:)
        @id = id
        @name = name
        @price = price.to_f
        @created_at = created_at
        @updated_at = updated_at
      end

      # Format price as currency string
      # @return [String] Price formatted as "$123.45"
      def formatted_price
        format('$%.2f', price)
      end
    end
  end
end
```

**Key Methods:**
- `create(name:, price:)`: Insert new product with validation
- `find_by_name(name)`: Case-insensitive lookup
- `all`: Return all products ordered by created_at
- `exists?(name)`: Check presence without loading full record
- `validate_name!(name)`: Raise error if name invalid
- `validate_price!(price)`: Raise error if price invalid
- `formatted_price`: Return "$123.45" format

**Dependencies:**
- Database class (connection management)
- Custom error classes

---

## 6. Core Workflows

### 6.1 Successful Calculation Flow

```
User: $ pocket-knife calc --percent 15 --of 200

┌─────────┐
│  User   │
└────┬────┘
     │ CLI args
     ▼
┌─────────────────┐
│  Entry Point    │  Load libs, call CLI.run(ARGV)
└────┬────────────┘
     │
     ▼
┌─────────────────┐
│   CLI Module    │  Parse: percentage=15, base=200
│   (OptionParser)│
└────┬────────────┘
     │
     ▼
┌─────────────────┐
│  Validation     │  Integer(15) ✓, Float(200) ✓
└────┬────────────┘
     │ CalculationRequest(15, 200.0)
     ▼
┌─────────────────┐
│   Calculator    │  (15 / 100.0) * 200 = 30.0
└────┬────────────┘
     │ CalculationResult(30.0)
     ▼
┌─────────────────┐
│   CLI Format    │  format("%.2f", 30.0) = "30.00"
└────┬────────────┘
     │
     ▼
┌─────────────────┐
│    STDOUT       │  Output: 30.00
└─────────────────┘
     │
     ▼
   Exit 0
```

### 6.2 Invalid Input Flow

```
User: $ pocket-knife calc --percent abc --of 200

┌─────────┐
│  User   │
└────┬────┘
     │ CLI args
     ▼
┌─────────────────┐
│  Entry Point    │
└────┬────────────┘
     │
     ▼
┌─────────────────┐
│   CLI Module    │  Parse: percentage="abc", base=200
└────┬────────────┘
     │
     ▼
┌─────────────────┐
│  Validation     │  Integer("abc") ✗
│                 │  Raise InvalidInputError
└────┬────────────┘
     │ InvalidInputError("Percentage must be a whole number")
     ▼
┌─────────────────┐
│  Entry Point    │  Catch InvalidInputError
│  (rescue)       │
└────┬────────────┘
     │
     ▼
┌─────────────────┐
│    STDERR       │  Output: Error: Percentage must be a whole number
└─────────────────┘
     │
     ▼
   Exit 2
```

### 6.3 Missing Arguments Flow

```
User: $ pocket-knife calc --percent 15

┌─────────┐
│  User   │
└────┬────┘
     │ CLI args (missing --of)
     ▼
┌─────────────────┐
│  Entry Point    │
└────┬────────────┘
     │
     ▼
┌─────────────────┐
│   CLI Module    │  Parse: percentage=15, base=nil
│   (OptionParser)│
└────┬────────────┘
     │
     ▼
┌─────────────────┐
│  Validation     │  base.nil? ✗
│                 │  Raise CLIError("Missing required argument: --of")
└────┬────────────┘
     │ CLIError
     ▼
┌─────────────────┐
│  Entry Point    │  Catch CLIError
│  (rescue)       │
└────┬────────────┘
     │
     ▼
┌─────────────────┐
│    STDERR       │  Error: Missing required argument: --of
└─────────────────┘
     │
     ▼
   Exit 1
```

### 6.4 Help Display Flow

```
User: $ pocket-knife --help

┌─────────┐
│  User   │
└────┬────┘
     │ --help flag
     ▼
┌─────────────────┐
│  Entry Point    │
└────┬────────────┘
     │
     ▼
┌─────────────────┐
│   CLI Module    │  Detect --help flag
│   (OptionParser)│  Call display_help
└────┬────────────┘
     │
     ▼
┌─────────────────┐
│    STDOUT       │  Usage: pocket-knife calc --percent N --of M
│                 │
│                 │  Examples:
│                 │    pocket-knife calc --percent 15 --of 200
│                 │    # => 30.00
└─────────────────┘
     │
     ▼
   Exit 0
```

### 6.5 Calculation Error Flow

```
User: $ pocket-knife calc --percent 15 --of Infinity

┌─────────┐
│  User   │
└────┬────┘
     │ CLI args
     ▼
┌─────────────────┐
│  Entry Point    │
└────┬────────────┘
     │
     ▼
┌─────────────────┐
│   CLI Module    │  Parse & validate
└────┬────────────┘
     │ CalculationRequest(15, Infinity)
     ▼
┌─────────────────┐
│   Calculator    │  request.valid? = false (Infinity not finite)
│                 │  Raise CalculationError("Invalid base number")
└────┬────────────┘
     │ CalculationError
     ▼
┌─────────────────┐
│  Entry Point    │  Catch CalculationError
└────┬────────────┘
     │
     ▼
┌─────────────────┐
│    STDERR       │  Error: Invalid base number
└─────────────────┘
     │
     ▼
   Exit 1
```

### 6.6 Storage Product Creation Flow (Story 3.1)

```
User: $ pocket-knife store-product "Laptop" 999.99

┌─────────┐
│  User   │
└────┬────┘
     │ CLI args
     ▼
┌─────────────────────┐
│    Entry Point      │
└────┬────────────────┘
     │
     ▼
┌─────────────────────┐
│   CLI Router        │  Parse: command="store-product", name="Laptop", price="999.99"
└────┬────────────────┘
     │
     ▼
┌─────────────────────┐
│  Storage Available? │  Database.storage_available? (check sqlite3 gem)
└────┬────────────────┘
     │ Yes
     ▼
┌─────────────────────┐
│   Database.init     │  1. Create ~/.pocket-knife/ directory
│                     │  2. Open SQLite connection
│                     │  3. Run migrations (CREATE TABLE IF NOT EXISTS)
└────┬────────────────┘
     │
     ▼
┌─────────────────────┐
│  Product.create     │  1. Validate name (not empty)
│                     │  2. Validate price (>= 0, numeric)
│                     │  3. Check duplicates (case-insensitive)
│                     │  4. INSERT INTO products
└────┬────────────────┘
     │ Product instance
     ▼
┌─────────────────────┐
│   CLI Format        │  Format: "✓ Product 'Laptop' stored successfully ($999.99)"
└────┬────────────────┘
     │
     ▼
┌─────────────────────┐
│      STDOUT         │  ✓ Product 'Laptop' stored successfully ($999.99)
└─────────────────────┘
     │
     ▼
   Exit 0
```

### 6.7 Storage Duplicate Product Flow (Story 3.1)

```
User: $ pocket-knife store-product "Laptop" 1299.99
(when "Laptop" already exists)

┌─────────┐
│  User   │
└────┬────┘
     │
     ▼
┌─────────────────────┐
│   CLI Router        │
└────┬────────────────┘
     │
     ▼
┌─────────────────────┐
│  Product.create     │  1. Validate name ✓
│                     │  2. Validate price ✓
│                     │  3. Product.exists?("Laptop") = true
│                     │  4. Raise DuplicateProductError
└────┬────────────────┘
     │ DuplicateProductError("Product 'Laptop' already exists")
     ▼
┌─────────────────────┐
│   Entry Point       │  Catch DuplicateProductError
│     (rescue)        │
└────┬────────────────┘
     │
     ▼
┌─────────────────────┐
│      STDERR         │  Error: Product 'Laptop' already exists
│                     │  Hint: Product names must be unique
└─────────────────────┘
     │
     ▼
   Exit 1
```

**Key Storage Behaviors:**
- Database auto-created on first storage command
- Duplicate names rejected (case-insensitive)
- Price validation (must be >= 0, numeric)
- Name validation (must be non-empty)
- Graceful fallback if sqlite3 gem not installed
- Original product preserved on duplicate attempt

---

## 7. Source Tree

### 7.1 Directory Structure

```
pocket-knife/
├── bin/
│   └── pocket-knife              # Executable entry point (chmod +x)
├── lib/
│   ├── pocket_knife.rb            # Main module loader
│   └── pocket_knife/
│       ├── calculator.rb          # Core: Percentage calculations
│       ├── calculation_request.rb # Core: Input data model
│       ├── calculation_result.rb  # Core: Output data model
│       ├── cli.rb                 # Core: CLI router & command handler
│       ├── errors.rb              # Core: Exception hierarchy
│       ├── llm_config.rb          # Optional: LLM integration (Gemini API)
│       └── storage/               # Optional: Product persistence
│           ├── database.rb        # Connection & migrations
│           └── product.rb         # Product CRUD model
├── spec/
│   ├── spec_helper.rb             # RSpec & SimpleCov configuration
│   ├── unit/
│   │   ├── calculator_spec.rb     # Calculator unit tests (28 examples)
│   │   ├── calculation_request_spec.rb # (21 examples)
│   │   ├── calculation_result_spec.rb  # (22 examples)
│   │   └── storage/
│   │       ├── database_spec.rb   # Database unit tests (19 examples)
│   │       └── product_spec.rb    # Product model tests (35 examples)
│   ├── integration/
│   │   ├── cli_spec.rb            # CLI integration tests (50 examples)
│   │   └── storage_cli_spec.rb    # Storage CLI tests (8 examples)
│   └── e2e/
│       └── pocket_knife_spec.rb   # End-to-end tests (2 examples)
├── coverage/                      # SimpleCov HTML reports (gitignored)
│   └── index.html
├── .rubocop.yml                   # RuboCop linting rules
├── .ruby-version                  # Ruby version: 3.2.2
├── Gemfile                        # Dependencies with optional groups
├── Gemfile.lock                   # Locked versions
├── Rakefile                       # Build and install tasks
├── README.md                      # User documentation
└── docs/
    ├── brief.md                   # Project brief & status
    ├── prd.md                     # Product requirements (Epic 1-3)
    ├── architecture.md            # This document (v2.0)
    ├── EPIC1_COMPLETION.md        # Epic 1 summary
    ├── TEST_SUMMARY.md            # Testing strategy
    └── stories/                   # User story specifications
        ├── 1.1.story.md
        ├── 1.2.story.md
        └── ... (7 stories)
```

**Runtime Database:**
```
~/.pocket-knife/                   # User's home directory
└── products.db                    # SQLite database (auto-created)
```

### 7.2 File Responsibilities

**bin/pocket-knife:**
- Shebang line: `#!/usr/bin/env ruby`
- Load main module: `require_relative '../lib/pocket_knife'`
- Exception handling and exit codes
- ~20 LOC

**lib/pocket_knife.rb:**
- Module definition: `module PocketKnife`
- Require core modules (calculator, cli, errors)
- Conditional require for optional features (llm_config, storage)
- ~25 LOC

**lib/pocket_knife/cli.rb:**
- Command router (calc, ask, store-product, list-products, get-product)
- Argument parsing with OptionParser
- Feature availability checks (LLM, Storage)
- Output formatting (tables, plain text, JSON)
- Help text display
- ~400 LOC

**lib/pocket_knife/calculator.rb:**
- Pure calculation logic (stateless)
- Methods: basic percentage, percentage of, percentage change
- No external dependencies
- ~80 LOC

**lib/pocket_knife/calculation_request.rb:**
- Input validation wrapper
- Immutable request object
- ~50 LOC

**lib/pocket_knife/calculation_result.rb:**
- Output formatting wrapper
- Result object with metadata
- ~50 LOC

**lib/pocket_knife/errors.rb:**
- Custom exception hierarchy
- 11 error classes (core + storage + LLM)
- ~40 LOC

**lib/pocket_knife/llm_config.rb:**
- Google Gemini API configuration
- API key loading from .env
- Question handling via RubyLLM gem
- ~60 LOC

**lib/pocket_knife/storage/database.rb:**
- SQLite connection singleton
- Auto-initialization (directory, database, schema)
- Migration execution
- Feature detection (sqlite3 gem check)
- ~80 LOC

**lib/pocket_knife/storage/product.rb:**
- Product CRUD operations
- Validation (name, price)
- Case-insensitive lookups
- Formatted price output
- ~120 LOC

**spec/spec_helper.rb:**
- SimpleCov configuration (75% threshold)
- RSpec settings
- Test isolation helpers
- ~40 LOC

**Current LOC Summary:**
- Core: ~320 LOC
- Optional Features: ~260 LOC
- Total Implementation: ~580 LOC
- Tests: ~1,200 LOC
- Test Coverage: 77.29%

### 7.3 Naming Conventions

**Files:**
- Snake case: `calculation_request.rb`, `calculator_spec.rb`
- Spec suffix: `_spec.rb` for all test files
- Match class name: `Calculator` class in `calculator.rb`

**Classes/Modules:**
- Pascal case: `PocketKnife`, `Calculator`, `CalculationRequest`
- Namespace: All classes under `PocketKnife` module

**Methods:**
- Snake case: `calculate`, `parse_arguments`, `format_value`
- Predicates end in `?`: `valid?`, `finite?`
- Mutators end in `!`: (none in this project)

**Constants:**
- Screaming snake case: `VERSION`, `DEFAULT_OPERATION`
- Defined at module level

---

## 8. Infrastructure & Deployment

### 8.1 Deployment Strategy

**Target Environment:** Local user system (no cloud infrastructure)

**Installation Method:** Manual installation via Rake task

**Requirements:**
- Ruby 3.2+ installed on user system
- Bundler gem installed (`gem install bundler`)
- Write access to local gem bin directory

### 8.2 Installation Process

**Step 1: Clone/Download**
```bash
git clone https://github.com/user/pocket-knife.git
cd pocket-knife
```

**Step 2: Install Dependencies**
```bash
bundle install
```

**Step 3: Run Tests (Optional)**
```bash
bundle exec rspec
```

**Step 4: Install Locally**
```bash
bundle exec rake install
```

**Step 5: Verify Installation**
```bash
pocket-knife --help
pocket-knife calc --percent 15 --of 200
```

### 8.3 Rake Tasks

**Rakefile:**
```ruby
# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new

desc 'Install pocket-knife locally'
task :install do
  sh 'mkdir -p ~/bin'
  sh 'cp bin/pocket-knife ~/bin/pocket-knife'
  sh 'chmod +x ~/bin/pocket-knife'
  puts 'Installed to ~/bin/pocket-knife'
  puts 'Ensure ~/bin is in your PATH'
end

desc 'Run all tests'
task test: [:spec, :rubocop]

task default: :test
```

**Available Tasks:**
- `rake install` - Copy binary to ~/bin
- `rake spec` - Run RSpec tests
- `rake rubocop` - Run linting
- `rake test` - Run all checks
- `rake -T` - List all tasks

### 8.4 Environment Configuration

**No configuration files required.** Application is stateless with no user preferences.

**Environment Variables:** None used.

**Ruby Version Management:**
- `.ruby-version` file specifies `3.2.2`
- Works with rbenv, rvm, chruby

### 8.5 CI/CD (Future Enhancement)

**Not in MVP scope**, but architecture supports:

**GitHub Actions Workflow:**
```yaml
name: CI

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: 3.2.2
          bundler-cache: true
      - run: bundle exec rspec
      - run: bundle exec rubocop
      - run: bundle exec rake install
```

**Distribution (Future):**
- Package as RubyGem: `gem build pocket-knife.gemspec`
- Publish to RubyGems.org: `gem push pocket-knife-1.0.0.gem`
- Homebrew formula for macOS users

---

## 9. Error Handling Strategy

### 9.1 Exception Hierarchy

```
StandardError
  └── PocketKnifeError (base for all app errors)
       ├── InvalidInputError (user input validation failures)
       ├── CalculationError (calculation failures)
       ├── CLIError (CLI usage errors)
       └── ConfigurationError (setup/config errors)
```

### 9.2 Error Types and Exit Codes

| Error Class | Exit Code | Usage | Example |
|-------------|-----------|-------|---------|
| **InvalidInputError** | 2 | Invalid user input | Non-numeric percentage, negative base |
| **CalculationError** | 1 | Calculation failure | Infinity, NaN, invalid operation |
| **CLIError** | 1 | CLI usage error | Missing required argument |
| **ConfigurationError** | 1 | Setup error | Ruby version too old |
| **StandardError** | 1 | Unexpected error | Unhandled exceptions |
| **(No error)** | 0 | Success | Valid calculation completes |

### 9.3 Error Handling Patterns

**At Entry Point (bin/pocket-knife):**
```ruby
begin
  PocketKnife::CLI.run(ARGV)
  exit 0
rescue PocketKnife::InvalidInputError => e
  warn "Error: #{e.message}"
  warn "Run 'pocket-knife --help' for usage information"
  exit 2
rescue PocketKnife::CLIError => e
  warn "Error: #{e.message}"
  warn "Run 'pocket-knife --help' for usage information"
  exit 1
rescue StandardError => e
  warn "Unexpected error: #{e.message}"
  warn "Please report this issue to: https://github.com/user/pocket-knife/issues"
  exit 1
end
```

**In CLI Module:**
```ruby
def validate_inputs
  raise InvalidInputError, 'Percentage must be a whole number' unless percentage_valid?
  raise InvalidInputError, 'Base must be a valid number' unless base_valid?
  raise CLIError, 'Missing required argument: --of' if base.nil?
end
```

**In Calculator Module:**
```ruby
def self.validate_request(request)
  unless request.valid?
    raise CalculationError, 'Invalid calculation request'
  end
end
```

### 9.4 Error Messages

**User-Friendly Messages:**
- ✅ "Percentage must be a whole number" (not "ArgumentError: invalid value for Integer()")
- ✅ "Missing required argument: --of" (not "NoMethodError: undefined method 'to_f' for nil")
- ✅ "Base must be a valid number" (not "FloatDomainError: Infinity")

**Error Message Template:**
```
Error: [Clear description of what went wrong]

Example:
  pocket-knife calc --percent 15 --of 200

Run 'pocket-knife --help' for more information.
```

### 9.5 Logging Strategy

**STDOUT:** Successful results only
```bash
$ pocket-knife calc --percent 15 --of 200
30.00
```

**STDERR:** All errors and warnings
```bash
$ pocket-knife calc --percent abc --of 200
Error: Percentage must be a whole number
Run 'pocket-knife --help' for usage information.
```

**No Log Files:** Application is stateless, no persistent logging required.

**Debugging:** Use `--verbose` flag (future enhancement) for detailed output.

---

## 10. Coding Standards

### 10.1 AI Agent Development Rules

These rules are **mandatory** for all AI agents implementing this architecture:

#### **Rule 1: No Metaprogramming**
```ruby
# ❌ AVOID: Dynamic method definitions
define_method("calculate_#{operation}") do
  # ...
end

# ✅ PREFER: Explicit method definitions
def calculate_percent_of(percentage, base)
  (percentage / 100.0) * base
end
```

#### **Rule 2: Explicit Over Clever**
```ruby
# ❌ AVOID: Clever one-liners
result = (->{ (p.to_i / 100.0) * b.to_f }).call

# ✅ PREFER: Clear, multi-step code
percentage_decimal = percentage / 100.0
result = percentage_decimal * base
```

#### **Rule 3: Single Responsibility**
```ruby
# ❌ AVOID: Methods doing multiple things
def parse_and_calculate_and_format(args)
  # parsing logic
  # calculation logic
  # formatting logic
end

# ✅ PREFER: Separate concerns
def parse_arguments(args); end
def calculate(request); end
def format_result(result); end
```

#### **Rule 4: Fail-Fast Validation**
```ruby
# ❌ AVOID: Late error detection
def calculate(percentage, base)
  result = (percentage / 100.0) * base
  raise if result.nan? # Too late!
end

# ✅ PREFER: Early validation
def calculate(percentage, base)
  raise InvalidInputError unless valid_input?(percentage, base)
  (percentage / 100.0) * base
end
```

#### **Rule 5: No Global State**
```ruby
# ❌ AVOID: Global variables or class variables
@@last_result = nil

def calculate(request)
  @@last_result = compute(request)
end

# ✅ PREFER: Return values, no side effects
def calculate(request)
  compute(request) # Pure function
end
```

#### **Rule 6: Explicit Dependencies**
```ruby
# ❌ AVOID: Hidden dependencies
require 'active_support/all' # Massive dependency

# ✅ PREFER: Minimal, explicit requires
require 'optparse' # Stdlib only
```

#### **Rule 7: Informative Error Messages**
```ruby
# ❌ AVOID: Technical jargon
raise ArgumentError, "Float::DomainError in compute"

# ✅ PREFER: User-friendly messages
raise InvalidInputError, "Base must be a valid number (not Infinity or NaN)"
```

### 10.2 Ruby Style Guidelines

Follow **RuboCop** default configuration with these adjustments:

```yaml
# .rubocop.yml
AllCops:
  NewCops: enable
  TargetRubyVersion: 3.2

Style/Documentation:
  Enabled: false # Allow missing class docs for small project

Metrics/MethodLength:
  Max: 20 # Keep methods focused

Metrics/ClassLength:
  Max: 150 # CLI class may approach this limit

Security/Eval:
  Enabled: true # Never use eval

Security/Open:
  Enabled: true # Prevent shell injection
```

### 10.3 Testing Standards

**Test Organization:**
- One test file per class: `calculator_spec.rb` for `Calculator`
- Group related tests in `describe` blocks
- Use `context` for different scenarios
- One assertion per test when possible

**RSpec Style:**
```ruby
RSpec.describe PocketKnife::Calculator do
  describe '.calculate' do
    context 'with valid input' do
      it 'calculates percentage correctly' do
        request = CalculationRequest.new(percentage: 15, base: 200)
        result = described_class.calculate(request)
        expect(result.value).to eq(30.0)
      end
    end

    context 'with invalid input' do
      it 'raises CalculationError' do
        request = CalculationRequest.new(percentage: -1, base: 200)
        expect { described_class.calculate(request) }
          .to raise_error(PocketKnife::CalculationError)
      end
    end
  end
end
```

---

## 11. Test Strategy and Standards

### 11.1 Testing Philosophy

- **Approach:** Test-Driven Development (write tests before implementation)
- **Coverage Goals:** Minimum 75% line coverage (enforced by SimpleCov)
  - Initial goal was 90%, adjusted to 75% due to optional feature groups
  - Core features maintain 80%+ coverage
  - Optional features (LLM, Storage) have comprehensive unit + integration tests
- **Test Pyramid:** 70% unit tests, 25% integration tests, 5% E2E tests
- **Current Status:** 185 examples, 0 failures, 1 pending, 77.29% coverage

### 11.2 Test Organization

#### **Unit Tests (spec/unit/)**

**Purpose:** Test individual classes/methods in isolation

**Framework:** RSpec 3.12+
**File Convention:** `*_spec.rb` matching source file name
**Location:** `spec/unit/`
**Mocking Library:** RSpec mocks (built-in)
**Coverage Requirement:** 95%+ for business logic

**AI Agent Requirements:**
- Generate tests for all public methods
- Cover edge cases and error conditions
- Follow AAA pattern (Arrange, Act, Assert)
- Mock all external dependencies

**Example:**
```ruby
# spec/unit/calculator_spec.rb
RSpec.describe PocketKnife::Calculator do
  describe '.calculate' do
    it 'calculates 15% of 200' do
      request = CalculationRequest.new(percentage: 15, base: 200)
      result = described_class.calculate(request)
      expect(result.value).to eq(30.0)
    end

    it 'handles zero percentage' do
      request = CalculationRequest.new(percentage: 0, base: 200)
      result = described_class.calculate(request)
      expect(result.value).to eq(0.0)
    end

    it 'raises error for invalid request' do
      request = instance_double(CalculationRequest, valid?: false)
      expect { described_class.calculate(request) }
        .to raise_error(PocketKnife::CalculationError)
    end
  end
end
```

#### **Integration Tests (spec/integration/)**

**Scope:** Test interaction between CLI and business logic modules (Calculator, Storage)

**Location:** `spec/integration/`
**Test Infrastructure:**
- No mocking of core logic (test real object collaboration)
- Isolated test databases for storage tests (tmpdir)
- Clean state between tests

**Current Integration Tests:**
- `cli_spec.rb` (50 examples): Calculator CLI commands
- `storage_cli_spec.rb` (8 examples): Storage CLI commands

**Storage Test Pattern:**
```ruby
# spec/integration/storage_cli_spec.rb
RSpec.describe 'Storage CLI Integration' do
  around do |example|
    Dir.mktmpdir do |dir|
      allow(Dir).to receive(:home).and_return(dir)
      example.run
      # Automatic cleanup after test
    end
  end

  it 'stores product and persists to database' do
    output = capture_output { described_class.run(['store-product', 'Laptop', '999.99']) }
    expect(output).to include('✓ Product')
    
    # Verify persistence
    db_path = File.join(Dir.home, '.pocket-knife', 'products.db')
    expect(File.exist?(db_path)).to be true
  end

  it 'rejects duplicate products' do
    described_class.run(['store-product', 'Laptop', '999.99'])
    
    expect { described_class.run(['store-product', 'Laptop', '1299.99']) }
      .to raise_error(PocketKnife::DuplicateProductError)
  end
end
```

**Calculator Integration Test:**
```ruby
# spec/integration/cli_spec.rb
RSpec.describe PocketKnife::CLI do
  describe '.run' do
    it 'calculates and outputs result' do
      expect { described_class.run(['calc', '--percent', '15', '--of', '200']) }
        .to output("30.00\n").to_stdout
    end

    it 'outputs error for invalid input' do
      expect { described_class.run(['calc', '--percent', 'abc', '--of', '200']) }
        .to raise_error(PocketKnife::InvalidInputError)
    end
  end
end
```

#### **End-to-End Tests (spec/e2e/)**

**Purpose:** Test executable binary with real command-line arguments

**Framework:** RSpec with system calls
**Scope:** Full application flow from CLI input to output
**Environment:** Execute actual `bin/pocket-knife` script
**Test Data:** Real-world usage scenarios

**Example:**
```ruby
# spec/e2e/pocket_knife_spec.rb
RSpec.describe 'pocket-knife executable' do
  let(:bin_path) { File.expand_path('../../bin/pocket-knife', __dir__) }

  it 'calculates percentage correctly' do
    output = `#{bin_path} calc --percent 15 --of 200`
    expect(output.strip).to eq('30.00')
    expect($?.exitstatus).to eq(0)
  end

  it 'exits with code 2 for invalid input' do
    `#{bin_path} calc --percent abc --of 200 2>/dev/null`
    expect($?.exitstatus).to eq(2)
  end

  it 'displays help text' do
    output = `#{bin_path} --help`
    expect(output).to include('Usage:')
    expect(output).to include('Examples:')
  end
end
```

### 11.3 Coverage Configuration

**SimpleCov Setup (spec/spec_helper.rb):**
```ruby
require 'simplecov'

SimpleCov.start do
  add_filter '/spec/'
  add_filter '/vendor/'
  add_filter '/bin/'
  
  add_group 'Core', 'lib/pocket_knife'
  add_group 'Calculator', 'lib/pocket_knife/calculator'
  add_group 'CLI', 'lib/pocket_knife/cli.rb'
  add_group 'Storage', 'lib/pocket_knife/storage'
  add_group 'LLM', 'lib/pocket_knife/llm_config.rb'
  
  minimum_coverage 75  # Adjusted for optional features
  # refuse_coverage_drop removed (optional features have different patterns)
end

require 'pocket_knife'
```

**Coverage Reports:**
- HTML report: `coverage/index.html`
- Console output: Shows % covered after each test run
- Current coverage: 77.29% (185 examples)
- Coverage breakdown:
  - Core calculator: 80%+ (well-tested)
  - CLI router: 75%+ (comprehensive integration tests)
  - Storage module: 77%+ (54 unit + 8 integration tests)
  - LLM module: Not included in coverage (optional, API-dependent)

### 11.4 Test Data Management

**Strategy:** Factory methods for test data (no external gems)

**Fixtures:** None required (simple data models)

**Factory Pattern:**
```ruby
# spec/support/factories.rb
module TestFactories
  def build_calculation_request(percentage: 15, base: 200.0)
    PocketKnife::CalculationRequest.new(
      percentage: percentage,
      base: base
    )
  end

  def build_calculation_result(value: 30.0, request: nil)
    request ||= build_calculation_request
    PocketKnife::CalculationResult.new(
      value: value,
      request: request
    )
  end
end

RSpec.configure do |config|
  config.include TestFactories
end
```

**Cleanup:** No cleanup needed (stateless application, no persistence)

### 11.5 Test Execution

**Run all tests:**
```bash
bundle exec rspec
```

**Run specific test file:**
```bash
bundle exec rspec spec/unit/calculator_spec.rb
```

**Run with coverage:**
```bash
COVERAGE=true bundle exec rspec
open coverage/index.html
```

**Run with documentation format:**
```bash
bundle exec rspec --format documentation
```

**Watch mode (with guard - future):**
```bash
bundle exec guard
```

---

## 12. Security

For the Pocket Knife CLI tool, security considerations are simplified since it's a local command-line utility with no network communication, authentication, or data persistence. However, we still enforce critical security practices:

### 12.1 Input Validation

- **Validation Library:** Ruby built-in validation (Integer, Float parsing with rescue)
- **Validation Location:** CLI module immediately after argument parsing
- **Required Rules:**
  - All command-line arguments MUST be validated before processing
  - Numeric inputs validated via safe parsing (`Integer()`, `Float()`)
  - Invalid inputs trigger `ArgumentError` with clear message
  - No user input reaches Calculator without validation
  - Exit code 2 for all validation failures

**AI Agent Implementation:**
```ruby
# CLI MUST validate inputs before passing to Calculator
def parse_percentage(value)
  Integer(value)
rescue ArgumentError
  raise PocketKnife::InvalidInputError, "Percentage must be a whole number"
end

def parse_base(value)
  Float(value)
rescue ArgumentError
  raise PocketKnife::InvalidInputError, "Base must be a valid number"
end
```

### 12.2 Authentication & Authorization

- **Status:** N/A - Local CLI tool requires no authentication
- **Rationale:** No multi-user functionality, network access, or protected resources

### 12.3 Secrets Management

- **Status:** N/A - No secrets, API keys, or credentials required
- **Code Requirements:**
  - No hardcoded secrets (none needed)
  - No configuration files with sensitive data
  - No network calls requiring authentication

### 12.4 API Security

- **Status:** N/A - No API endpoints or network communication
- **Rationale:** Standalone CLI tool with no external dependencies or network operations

### 12.5 Data Protection

- **Encryption at Rest:** N/A - No data persistence
- **Encryption in Transit:** N/A - No network communication
- **PII Handling:** N/A - No personal data collected or processed
- **Logging Restrictions:**
  - Error messages contain only operation context (percentage, base value)
  - No sensitive data in logs (none exists)
  - Exit codes provide machine-readable status without exposing internals

**AI Agent Requirements:**
- Error messages MUST NOT expose Ruby internals or stack traces to end users
- Use custom exception messages with user-friendly language
- Log technical details to STDERR, user messages to STDOUT

### 12.6 Dependency Security

- **Scanning Tool:** Bundler Audit (development dependency)
- **Update Policy:** Check dependencies monthly or when CVEs announced
- **Approval Process:** 
  - Zero runtime dependencies by design (OptionParser is stdlib)
  - New test/dev dependencies require manual review
  - Run `bundle audit` before each release
  - Use `bundle outdated` to track available updates

**Commands:**
```bash
# Add to development workflow
gem install bundler-audit
bundle audit check --update
bundle outdated
```

### 12.7 Security Testing

- **SAST Tool:** RuboCop with Security cops enabled
- **Configuration:** Enable `Security` department in `.rubocop.yml`
- **CI Integration:** Run RuboCop on every commit/PR
- **Manual Review:** Code review focuses on input validation completeness

**RuboCop Security Cops:**
```yaml
# .rubocop.yml
Security/Eval:
  Enabled: true
Security/Open:
  Enabled: true
Security/JSONLoad:
  Enabled: true
```

**AI Agent Testing Requirements:**
- Include security test cases in RSpec suite
- Test malicious inputs: SQL-like strings, script tags, path traversal attempts
- Verify all inputs rejected safely with proper exit codes
- Ensure error messages don't leak sensitive information

**Example Security Test:**
```ruby
describe "Input Security" do
  it "rejects SQL injection attempts" do
    expect { CLI.run(["calc", "--percent", "'; DROP TABLE--", "--of", "100"]) }
      .to raise_error(PocketKnife::InvalidInputError)
  end

  it "rejects script injection attempts" do
    expect { CLI.run(["calc", "--percent", "<script>alert(1)</script>", "--of", "100"]) }
      .to raise_error(PocketKnife::InvalidInputError)
  end
end
```

---

## 13. Story 3.2 Technical Design: List and Retrieve Products

**Status:** Design Complete - Ready for Implementation  
**Story Reference:** docs/prd.md (Epic 3, Story 3.2)  
**Acceptance Criteria:** 12 total

### 13.1 Command Specifications

#### **Command: list-products**

**Syntax:**
```bash
pocket-knife list-products
```

**Behavior:**
- Display all products in a formatted table
- Columns: ID, Name, Price
- Order: By created_at (oldest first)
- Empty state: "No products stored yet."
- Exit code: 0 (always successful)

**Output Format:**
```
ID  Name      Price
--  -----     ------
1   Laptop    $999.99
2   Mouse     $29.99
3   Keyboard  $79.99
```

**Implementation:**
```ruby
def execute_list_products
  unless Database.storage_available?
    warn "Storage feature not available. Install with: bundle install --with storage"
    exit 1
  end
  
  products = Product.all
  
  if products.empty?
    puts "No products stored yet."
    return
  end
  
  # Table formatting
  puts format('%-4s %-20s %s', 'ID', 'Name', 'Price')
  puts format('%-4s %-20s %s', '--', '----', '-----')
  
  products.each do |product|
    puts format('%-4d %-20s %s', product.id, product.name, product.formatted_price)
  end
end
```

#### **Command: get-product "<name>"**

**Syntax:**
```bash
pocket-knife get-product "Laptop"
```

**Behavior:**
- Retrieve and display single product by name (case-insensitive)
- Display: Name, Price, ID, Created At
- Exit code: 0 if found, 1 if not found
- Error message if product doesn't exist

**Output Format (Success):**
```
Product: Laptop
Price: $999.99
ID: 1
Created: 2025-11-06 14:30:22
```

**Output Format (Not Found):**
```
Error: Product 'NonExistent' not found
```

**Implementation:**
```ruby
def execute_get_product
  unless Database.storage_available?
    warn "Storage feature not available. Install with: bundle install --with storage"
    exit 1
  end
  
  name = ARGV[1]
  
  if name.nil? || name.strip.empty?
    warn "Error: Product name required"
    warn "Usage: pocket-knife get-product \"<name>\""
    exit 1
  end
  
  product = Product.find_by_name(name)
  
  if product.nil?
    warn "Error: Product '#{name}' not found"
    exit 1
  end
  
  puts "Product: #{product.name}"
  puts "Price: #{product.formatted_price}"
  puts "ID: #{product.id}"
  puts "Created: #{product.created_at}"
end
```

### 13.2 CLI Routing Updates

**Add to CLI.run method:**
```ruby
def self.run(args)
  command = args.first
  
  case command
  when 'calc'
    # existing calculator logic
  when 'ask'
    # existing LLM logic
  when 'store-product'
    # existing storage logic
  when 'list-products'
    new(args).execute_list_products
  when 'get-product'
    new(args).execute_get_product
  when '--help', '-h', nil
    display_help
  else
    warn "Unknown command: #{command}"
    display_help
    exit 1
  end
end
```

### 13.3 Integration Test Specifications

**File:** spec/integration/storage_cli_spec.rb (add to existing file)

**New Tests (8+ examples):**

1. **list-products with empty database**
   - Expect: "No products stored yet."
   - Exit code: 0

2. **list-products with single product**
   - Setup: Store one product
   - Verify: Table header + 1 row
   - Verify: Correct ID, name, formatted price

3. **list-products with multiple products**
   - Setup: Store 3 products
   - Verify: 3 rows in correct order (oldest first)

4. **list-products ordering**
   - Setup: Store products in random order
   - Verify: Listed by created_at (oldest first)

5. **get-product with existing product**
   - Setup: Store "Laptop" at $999.99
   - Verify: Output contains name, price, ID, created time
   - Exit code: 0

6. **get-product with non-existent product**
   - Verify: Error message "Product 'XYZ' not found"
   - Exit code: 1

7. **get-product case-insensitive lookup**
   - Setup: Store "Laptop"
   - Test: get-product "LAPTOP"
   - Verify: Product found

8. **get-product without name argument**
   - Verify: Usage error message
   - Exit code: 1

**Test Pattern:**
```ruby
RSpec.describe 'Storage CLI Integration' do
  around do |example|
    Dir.mktmpdir do |dir|
      allow(Dir).to receive(:home).and_return(dir)
      example.run
    end
  end
  
  describe 'list-products command' do
    it 'shows empty message when no products' do
      output = capture_output { described_class.run(['list-products']) }
      expect(output).to include('No products stored yet')
    end
    
    it 'displays products in table format' do
      described_class.run(['store-product', 'Laptop', '999.99'])
      described_class.run(['store-product', 'Mouse', '29.99'])
      
      output = capture_output { described_class.run(['list-products']) }
      expect(output).to include('ID')
      expect(output).to include('Name')
      expect(output).to include('Price')
      expect(output).to include('Laptop')
      expect(output).to include('$999.99')
      expect(output).to include('Mouse')
      expect(output).to include('$29.99')
    end
  end
  
  describe 'get-product command' do
    it 'displays product details when found' do
      described_class.run(['store-product', 'Laptop', '999.99'])
      
      output = capture_output { described_class.run(['get-product', 'Laptop']) }
      expect(output).to include('Product: Laptop')
      expect(output).to include('Price: $999.99')
      expect(output).to include('ID:')
      expect(output).to include('Created:')
    end
    
    it 'shows error when product not found' do
      expect { described_class.run(['get-product', 'NonExistent']) }
        .to raise_error(SystemExit) do |error|
          expect(error.status).to eq(1)
        end
    end
  end
end
```

### 13.4 Documentation Updates

**README.md additions:**

```markdown
### List All Products

```bash
pocket-knife list-products
```

**Output:**
```
ID  Name      Price
--  -----     ------
1   Laptop    $999.99
2   Mouse     $29.99
3   Keyboard  $79.99
```

### Get Product Details

```bash
pocket-knife get-product "Laptop"
```

**Output:**
```
Product: Laptop
Price: $999.99
ID: 1
Created: 2025-11-06 14:30:22
```

**Note:** Product lookup is case-insensitive.
```

**Help Text Update:**
```ruby
def self.display_help
  puts <<~HELP
    Pocket Knife - Multi-purpose CLI toolkit
    
    Usage:
      pocket-knife calc <amount> <percentage>
      pocket-knife ask "<question>"
      pocket-knife store-product "<name>" <price>
      pocket-knife list-products
      pocket-knife get-product "<name>"
    
    Storage Commands:
      store-product  Store a product with name and price
      list-products  List all stored products in a table
      get-product    Get details of a specific product (case-insensitive)
    
    Examples:
      pocket-knife list-products
      pocket-knife get-product "Laptop"
  HELP
end
```

### 13.5 Implementation Checklist

- [ ] Implement `execute_list_products` method in CLI
- [ ] Implement `execute_get_product` method in CLI
- [ ] Update CLI routing (add 2 new cases)
- [ ] Write 8+ integration tests
- [ ] Update README.md with new commands
- [ ] Update help text display
- [ ] Run full test suite (expect ~193 examples)
- [ ] Run RuboCop (maintain 0 offenses)
- [ ] Manual testing of both commands
- [ ] Update brief.md with Story 3.2 completion status

### 13.6 Expected Outcomes

- **Test Count:** ~193 examples (185 current + 8 new integration tests)
- **Coverage:** 78-80% (slight increase from current 77.29%)
- **RuboCop:** 0 offenses (maintain standard)
- **LOC:** +~60 lines (2 CLI methods + 8 tests)
- **Documentation:** README, help text, brief updated

---

## 14. Checklist Results Report

I've completed a comprehensive validation of the Pocket Knife CLI architecture against the BMad Architect Checklist. Here are the results:

### 14.1 Executive Summary

- **Overall Architecture Readiness:** ✅ **HIGH** (92% pass rate)
- **Project Type:** Backend CLI Tool (Frontend sections skipped as N/A)
- **Critical Risks:** None identified
- **Development Ready:** Yes - Architecture is complete and ready for implementation

**Key Strengths:**
- Crystal-clear three-layer architecture optimized for simplicity
- Zero runtime dependencies reduce attack surface and maintenance burden
- Comprehensive error handling with explicit exit codes
- Strong testing strategy with 90% coverage requirement
- Excellent AI agent implementation guidance with concrete examples

### 13.2 Section-by-Section Results

| Section | Pass Rate | Status | Notes |
|---------|-----------|--------|-------|
| **1. Requirements Alignment** | 100% (5/5) | ✅ GREEN | All FR/NFR addressed, stories supported |
| **2. Architecture Fundamentals** | 100% (4/4) | ✅ GREEN | Clear diagrams, separation of concerns |
| **3. Technical Stack** | 100% (4/4) | ✅ GREEN | Specific versions, justified choices |
| **4. Frontend Design** | N/A | ⊘ SKIPPED | CLI tool, no UI component |
| **5. Resilience & Operations** | 100% (4/4) | ✅ GREEN | Comprehensive error handling, deployment |
| **6. Security & Compliance** | 90% (9/10) | ✅ GREEN | Minor gap: OWASP review (low risk) |
| **7. Implementation Guidance** | 100% (5/5) | ✅ GREEN | Clear standards, test strategy |
| **8. Dependency Management** | 100% (3/3) | ✅ GREEN | Zero runtime deps, versioning defined |
| **9. AI Agent Suitability** | 100% (4/4) | ✅ GREEN | Excellent modularity and clarity |
| **10. Accessibility** | N/A | ⊘ SKIPPED | CLI tool, terminal-only interface |

**Overall Score:** 92% (47/51 applicable criteria passed)

### 13.3 Risk Assessment

**No critical or high-severity risks identified.**

| Risk | Severity | Mitigation |
|------|----------|------------|
| Ruby version compatibility | Low | Document Ruby version check in install script |
| Dependency vulnerabilities | Low | Bundler Audit monthly + CI integration |
| Incomplete test coverage | Low | SimpleCov enforces 90% minimum |
| User CLI syntax confusion | Low | Comprehensive help + error messages |

### 13.4 Recommendations

**Must-Fix Before Development:** ✅ None - Architecture is development-ready

**Should-Fix for Better Quality:**
1. Add Ruby version check to installation Rake task (5 min)
2. Document bundler-audit CI integration explicitly

**Nice-to-Have Improvements:**
1. Add `--version` flag support
2. Performance benchmarks for large numbers
3. Shell completion scripts (bash/zsh)

### 13.5 AI Implementation Readiness

**Rating:** ✅ **EXCELLENT**

The architecture is exceptionally well-suited for AI agent implementation:

**Strengths:**
- ✅ Explicit component boundaries with clear interfaces
- ✅ Concrete code examples throughout
- ✅ Predictable patterns (no metaprogramming)
- ✅ Single Responsibility enforced
- ✅ Comprehensive test strategy
- ✅ Clear file structure with naming conventions

**No AI-specific concerns identified.**

### 13.6 Final Validation

**Readiness Level:** ✅ **GREEN - PROCEED TO DEVELOPMENT**

The Pocket Knife CLI architecture is complete, comprehensive, and ready for AI-driven development. The architecture document provides all necessary guidance for the Dev agent to implement stories successfully.

---

## 15. Next Steps

The Pocket Knife CLI architecture is updated to v2.0, reflecting the current system state (Epic 1-3.1 complete). Here's how to proceed with Story 3.2 implementation:

### 15.1 Architecture Handoff

**Document Status:** ✅ **COMPLETE & VALIDATED**
- Architecture checklist: 92% pass rate (47/51 applicable criteria)
- Readiness level: GREEN - Ready for development
- All critical sections complete: Tech Stack, Components, Workflows, Error Handling, Testing, Security

**Output Location:** `docs/architecture.md` ✅ (this document)

### 15.2 Immediate Next Actions

**Current Status:** ✅ **Epic 1 + 2 Complete, Story 3.1 Complete**
- Epic 1 (MVP Calculator): 71 tests ✅
- Epic 2 (LLM Integration): 123 total tests ✅
- Story 3.1 (Product Storage Foundation): 185 total tests ✅
  - Database connection management implemented
  - Product CRUD model implemented
  - `store-product` CLI command functional
  - 54 unit tests + 8 integration tests
  - Zero RuboCop offenses, 77% coverage

**1. Implement Story 3.2: List and Retrieve Products** ✅ **RECOMMENDED NEXT STEP**
- **Status**: Design complete (architectural guidance provided)
- **Developer**: Activate Dev agent (James)
- **Scope**: 12 acceptance criteria
- **Commands**: `list-products`, `get-product "<name>"`
- **Expected Outcome**: ~8 new integration tests, ~193 total tests
- **Story Reference**: `docs/prd.md` (Story 3.2)

**Implementation Tasks for Story 3.2:**
1. Implement `execute_list_products` in CLI (table formatting)
2. Implement `execute_get_product` in CLI (single product display)
3. Add CLI routing for new commands
4. Write 8+ integration tests (empty list, single product, multiple products, not found)
5. Update README.md with new commands and examples
6. Update help text in CLI
7. Verify all tests pass (expect ~193 examples)
8. Run RuboCop (maintain 0 offenses)

**2. Continue Epic 3: Product Storage (Stories 3.3-3.4)**
- **Story 3.3**: Update and Delete Products (12 ACs)
  - Commands: `update-product`, `delete-product`
  - Confirmation prompts
  - Validation
- **Story 3.4**: Calculate on Stored Products (11 ACs)
  - Command: `calc-product "<name>" <percentage>`
  - Integration with existing calculator
  - Price-based calculations

**3. Post-Epic 3 Enhancements (Future)**
- Export products to CSV/JSON
- Bulk import from CSV
- Search/filter products by price range
- Product categories/tags

### 15.3 Dev Agent Activation Prompt (Story 3.2)

Use this prompt to activate the Dev agent and begin Story 3.2 implementation:

```
/bmad-dev

Ready to implement Story 3.2: List and Retrieve Products

Context:
- Current Status: Story 3.1 complete (185 tests passing, 77% coverage)
- Story 3.2 Design: Complete architectural guidance provided by Architect
- PRD: docs/prd.md (Story 3.2, 12 acceptance criteria)
- Architecture: docs/architecture.md (v2.0, updated with storage layer)

Implementation Plan:
1. Add execute_list_products method to CLI (table formatting)
2. Add execute_get_product method to CLI (single product display)
3. Update CLI routing for list-products and get-product commands
4. Write 8+ integration tests (spec/integration/storage_cli_spec.rb)
5. Update README.md with new commands
6. Update help text

Expected Outcome: ~193 total tests, 0 RuboCop offenses, 78%+ coverage
```

### 15.4 Quality Gates

Before completing each story, ensure:

- ✅ All acceptance criteria met (11-18 per story in Epic 3)
- ✅ Unit tests passing with 75%+ coverage (77%+ target for Epic 3)
- ✅ RuboCop passes with zero offenses
- ✅ Integration tests pass (8+ tests per storage story)
- ✅ Manual CLI testing performed
- ✅ Documentation updated (README, help text, architecture)
- ✅ Code review by QA agent (Quinn) if desired

**Story 3.1 Quality Gate Results:**
- ✅ 18/18 acceptance criteria met
- ✅ 62 new tests (54 unit + 8 integration)
- ✅ 185 total tests, 0 failures
- ✅ 0 RuboCop offenses (25 files inspected)
- ✅ 77.29% coverage (exceeds 75% threshold)
- ✅ Manual testing: store-product, duplicates, validation
- ✅ Documentation: README, brief, PRD, architecture updated

### 15.5 Architecture Maintenance

As development progresses:

**When to Update Architecture:**
- New components added beyond three-layer design
- Significant pattern changes (e.g., switching from OptionParser)
- Additional dependencies introduced
- Security vulnerabilities discovered requiring architectural changes

**Version Control:**
- Tag architecture.md as v1.0 in Git
- Update version number for significant revisions
- Maintain changelog section at top of document

### 15.6 Post-MVP Considerations

After completing Epic 1 (MVP), consider these enhancements:

**1. Additional Operations** (Beyond MVP scope)
   - Reverse percentage: "What % is 25 of 100?"
   - Percentage increase/decrease
   - Compound percentage calculations

**2. UX Improvements**
   - Shell completion scripts (bash/zsh)
   - Colored output for errors/success
   - Interactive mode for multiple calculations

**3. Distribution**
   - Package as RubyGem for `gem install pocket-knife`
   - Homebrew formula for macOS users
   - Debian/RPM packages for Linux

**4. Advanced Features**
   - Configuration file support (~/.pocket-knife.yml)
   - Calculation history/logging
   - Plugin system for custom operations

### 15.7 Success Metrics

Track these metrics to validate architecture decisions:

| Metric | Target | How to Measure |
|--------|--------|----------------|
| Test Coverage | ≥90% | SimpleCov report |
| RuboCop Compliance | 100% (zero offenses) | `bundle exec rubocop` |
| Story Completion | 7/7 stories | PRD checklist |
| Implementation Time | ≤2 weeks | Sprint tracking |
| LOC per Component | <200 LOC | `cloc lib/` |
| CI Build Time | <2 minutes | GitHub Actions |

### 15.8 Support & References

**Documentation:**
- BMad Method User Guide: `.bmad-core/user-guide.md`
- Dev Agent Guide: `.bmad-core/agents/dev.md`
- Story DoD Checklist: `.bmad-core/checklists/story-dod-checklist.md`

**Technical References:**
- Ruby 3.2 Docs: https://docs.ruby-lang.org/en/3.2/
- RSpec Documentation: https://rspec.info/
- RuboCop Style Guide: https://rubocop.org/

**BMad Workflow:**
```
PM (Brief + PRD) → Architect (This Doc) → Dev (Stories) → QA (Testing) → PO (Acceptance)
```

---

## Architecture Complete! 🎉

The Pocket Knife CLI architecture is fully documented, validated, and ready for AI-driven development. All technical decisions are finalized, patterns are established, and implementation guidance is comprehensive.

**Recommended Action:** Activate the Dev agent to begin story implementation starting with STORY-001 (Project Setup).

---

**Document Metadata:**
- **Created:** November 4, 2025
- **Last Updated:** November 4, 2025
- **Version:** 1.0
- **Validation Status:** ✅ Complete (92% checklist pass rate)
- **Next Review:** After MVP completion or significant architecture changes
