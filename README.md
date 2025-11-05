# Pocket Knife

A blazingly fast command-line percentage calculator for developers who live in the terminal.

## Overview

Pocket Knife is a simple, zero-dependency Ruby CLI tool that calculates percentages without leaving your terminal. No more context-switching to a calculator app or browser!

## Features

- 🚀 **Fast**: Calculate percentages in milliseconds
- 🎯 **Simple**: Clean, intuitive command syntax
- 🔒 **Zero Dependencies**: Core calculator uses only Ruby standard library
- 🤖 **AI-Powered (Optional)**: Natural language queries with Google Gemini
- ✅ **Well-Tested**: 110+ tests with 90%+ code coverage
- 🔐 **Secure**: API keys via environment variables, no data storage
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

### Installation with Optional LLM Features

To enable natural language querying with AI models, install with the LLM dependency group:

```bash
bundle install --with llm
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
