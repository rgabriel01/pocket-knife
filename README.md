# Pocket Knife

A blazingly fast command-line percentage calculator for developers who live in the terminal.

## Overview

Pocket Knife is a simple, zero-dependency Ruby CLI tool that calculates percentages without leaving your terminal. No more context-switching to a calculator app or browser!

## Features

- 🚀 **Fast**: Calculate percentages in milliseconds
- 🎯 **Simple**: Clean, intuitive command syntax
- 🔒 **Zero Dependencies**: Core calculator uses only Ruby standard library
- 🤖 **AI-Powered (Optional)**: Natural language queries with Google Gemini
- 💾 **Product Storage (Optional)**: Store products with prices using SQLite
- ✅ **Well-Tested**: 123+ tests with 80%+ code coverage
- 🔐 **Secure**: API keys via environment variables
- 📖 **Great Help**: Built-in documentation and comprehensive error messages

## Requirements

- Ruby 3.2 or higher
- macOS or Linux

## Installation

### Standard Installation (Calculator Only)

```bash
bundle install
bundle exec rake install
```

This installs `pocket-knife` to `/usr/local/bin/` (requires sudo password).

### Installation with Optional Features

To enable optional features (LLM and/or Storage), install with the desired dependency groups:

**LLM Only:**
```bash
bundle install --with llm
bundle exec rake install
```

**Storage Only:**
```bash
bundle install --with storage
bundle exec rake install
```

**Both LLM and Storage:**
```bash
bundle config set --local with 'llm storage'
bundle install
bundle exec rake install
```

Then configure your API key (see [Optional LLM Features](#optional-llm-features) section below).

## Usage

### Calculate Percentage

```bash
pocket-knife calc <base> <percentage>
```

**Examples:**

```bash
# Calculate 15% of 200
pocket-knife calc 200 15
# Output: 30.00

# Calculate 20% tip on $45.50
pocket-knife calc 45.50 20
# Output: 9.10

# Calculate 7.5% sales tax
pocket-knife calc 100 7.5
# Output: 7.50
```

### Get Help

```bash
pocket-knife --help
pocket-knife calc --help
```

## Optional LLM Features

Pocket Knife includes optional AI-powered natural language querying using the RubyLLM gem with Google Gemini. This feature is completely optional and requires separate installation.

### Setup

1. **Install with LLM dependencies:**

```bash
bundle install --with llm
```

2. **Configure API Key:**

You can set the Gemini API key using either method:

**Option A: Using .env file (recommended)**

```bash
# Copy the example file
cp .env.example .env

# Edit .env and add your API key
GEMINI_API_KEY=your-gemini-api-key
```

**Option B: Using environment variable**

```bash
export GEMINI_API_KEY="your-gemini-api-key"
```

**Get your Gemini API key:** Visit [Google AI Studio](https://makersuite.google.com/app/apikey) to create a free API key.

3. **Verify setup:**

```bash
pocket-knife ask "What is 20% of 100?"
```

### Usage Examples

```bash
# Natural language queries
pocket-knife ask "What is 20% of 100?"
# Output: 20.00

pocket-knife ask "Calculate 15 percent of 200"
# Output: 30.00

pocket-knife ask "I need to know 7.5% of 1000"
# Output: 75.00
```

### Notes

- The `calc` command works independently and never loads LLM code
- LLM features require an active internet connection
- Gemini API has a generous free tier for testing and personal use
- The tool uses the existing Calculator logic - AI only handles natural language understanding

### When to Use `ask` vs `calc`

| Scenario | Use `calc` | Use `ask` |
|----------|------------|-----------|
| Quick, offline calculation | ✅ | ❌ |
| Scripting/automation | ✅ | ❌ |
| Natural language query | ❌ | ✅ |
| Exploratory calculation | ❌ | ✅ |
| No internet connection | ✅ | ❌ |
| Exact numbers known | ✅ | Either |

**Recommendation:** Use `calc` for speed and reliability. Use `ask` when you want natural language interaction or are exploring calculations.

### More Examples

```bash
# Different ways to ask the same question
pocket-knife ask "What's 20 percent of 100?"
pocket-knife ask "Calculate 20% of 100"
pocket-knife ask "I need 20 percent of 100"
pocket-knife ask "How much is a 20% tip on $100?"
pocket-knife ask "What is a 20% discount on $100?"

# Complex queries
pocket-knife ask "What is 15 percent of 200 dollars?"
pocket-knife ask "Calculate 7.5 percent of 1000"
pocket-knife ask "I'm calculating a 20% tip on $45.50, how much?"
```

### Security & Privacy

- **API Keys:** Never commit your `.env` file or share your API key publicly
- **Data Privacy:** Your queries are sent to Google's Gemini API for processing
- **No Storage:** Pocket Knife does not store queries or results locally
- **HTTPS:** All API communication is encrypted via HTTPS
- **Audit:** Review the open-source code to verify security practices

**Best Practices:**
- Use `.env` file instead of hardcoding keys
- Rotate API keys periodically
- Use separate API keys for development and production
- Monitor API usage in Google Cloud Console

### API Costs & Limits

**Gemini Free Tier (as of 2024):**
- 60 requests per minute
- Generous free monthly quota
- Sufficient for personal use

**Rate Limiting:**
If you hit rate limits, the tool will display:
```
Error: Rate limit exceeded: Too many requests to Gemini API.
  Please wait a moment and try again, or upgrade your API plan.
  For immediate results, use: pocket-knife calc <amount> <percentage>
```

**Solution:** Wait a moment or use `pocket-knife calc` for immediate results.

### Troubleshooting

**"No API key configured" error:**
- Ensure you've set the `GEMINI_API_KEY` environment variable
- Check that the key is not empty or whitespace-only
- For `.env` method: verify `.env` file exists and contains `GEMINI_API_KEY=your-key`
- For export method: verify with `echo $GEMINI_API_KEY`
- Get a free API key at [Google AI Studio](https://makersuite.google.com/app/apikey)

**"Invalid API key format" error:**
- Remove quotes from your API key (should be `GEMINI_API_KEY=abc123`, not `GEMINI_API_KEY="abc123"`)
- Ensure no extra spaces or newlines in the key
- API keys should contain only alphanumeric characters, dashes, and underscores

**"LLM features not available" error:**
- Install LLM dependencies: `bundle install --with llm`
- Verify installation: `bundle info ruby_llm`
- If still failing, try: `bundle install --redownload --with llm`

**"Network error" or timeout:**
- Check your internet connection
- Verify firewall settings allow HTTPS to Google APIs
- Try again in a moment (temporary service issue)
- Use `pocket-knife calc` as an offline alternative

**"Authentication failed" error:**
- Your API key may be invalid or expired
- Generate a new key at [Google AI Studio](https://makersuite.google.com/app/apikey)
- Update your `.env` file or environment variable with the new key

For more detailed troubleshooting, see [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md).

## Optional Product Storage

Pocket Knife includes optional product storage functionality using SQLite. Store products with names and prices for quick reference and calculations.

### Setup

1. **Install with Storage dependencies:**

```bash
bundle install --with storage
```

2. **Database location:**

Products are stored in: `~/.pocket-knife/products.db`

The database and table are created automatically on first use.

### Store a Product

```bash
pocket-knife store-product "<name>" <price>
```

**Examples:**

```bash
# Store a product with name and price
pocket-knife store-product "Coffee" 12.99
# Output:
# ✓ Product stored successfully
#   Name:  Coffee
#   Price: $12.99
#   ID:    1

# Store another product
pocket-knife store-product "Banana" 200.00
# Output:
# ✓ Product stored successfully
#   Name:  Banana
#   Price: $200.00
#   ID:    2

# Product names can contain spaces
pocket-knife store-product "Organic Milk" 3.50
```

### Error Handling

```bash
# Duplicate product name
pocket-knife store-product "Coffee" 15.99
# Error: Product "Coffee" already exists
#   Use a different name or update the existing product.

# Invalid price (negative)
pocket-knife store-product "Tea" -5.00
# Error: Price must be a positive number

# Missing arguments
pocket-knife store-product "Tea"
# Error: Missing price argument
# Usage: pocket-knife store-product "<name>" <price>
```

### Notes

- Product names must be unique
- Prices must be positive numbers (zero or greater)
- Product names are case-sensitive
- The database is created in your home directory: `~/.pocket-knife/`
- Products persist across sessions

### Troubleshooting

**"Storage features are not available" error:**
- Install storage dependencies: `bundle install --with storage`
- Verify installation: `bundle info sqlite3`
- If still failing, try: `bundle install --redownload --with storage`

**Database permission errors:**
- Ensure you have write permissions to `~/.pocket-knife/` directory
- Check disk space: `df -h ~`
- Verify the directory exists: `ls -la ~/.pocket-knife/`

**SQLite errors:**
- Your SQLite database may be corrupted
- Backup and remove: `mv ~/.pocket-knife/products.db ~/.pocket-knife/products.db.backup`
- Try your command again (database will be recreated)

## Development

### Setup

```bash
bundle install
```

### Run Tests

```bash
# Run all tests
bundle exec rake test

# Run only RSpec
bundle exec rspec

# Run with coverage report
COVERAGE=true bundle exec rspec
open coverage/index.html

# Run linting
bundle exec rubocop
```

### Directory Structure

```
pocket-knife/
├── bin/
│   └── pocket-knife          # Executable entry point
├── lib/
│   └── pocket_knife/
│       ├── calculator.rb     # Core calculation logic
│       ├── calculation_request.rb
│       ├── calculation_result.rb
│       ├── cli.rb           # Command-line interface
│       ├── errors.rb        # Custom error classes
│       └── version.rb       # Version constant
├── spec/
│   ├── unit/                # Unit tests
│   ├── integration/         # Integration tests
│   └── e2e/                 # End-to-end tests
├── docs/                    # Project documentation
├── Gemfile                  # Dependencies
├── Rakefile                 # Build tasks
└── README.md
```

## Testing

The project maintains 90%+ code coverage with a comprehensive test suite:

- **Unit Tests**: Test individual classes in isolation
- **Integration Tests**: Test component interactions
- **E2E Tests**: Test the full executable

Run tests with:

```bash
bundle exec rake test
```

## Uninstallation

```bash
bundle exec rake uninstall
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests: `bundle exec rake test`
5. Submit a pull request

## License

MIT License - see LICENSE file for details

## Project Status

**Current Version:** 0.1.0 (MVP)  
**Status:** In Development

This project follows the BMad Method for AI-driven development.

## Support

For issues or questions, please open a GitHub issue.
