# Pocket Knife

A blazingly fast command-line percentage calculator for developers who live in the terminal.

## Overview

Pocket Knife is a simple, zero-dependency Ruby CLI tool that calculates percentages without leaving your terminal. No more context-switching to a calculator app or browser!

## Features

- 🚀 **Fast**: Calculate percentages in milliseconds
- 🎯 **Simple**: Clean, intuitive command syntax
- 🔒 **Zero Dependencies**: Uses only Ruby standard library
- ✅ **Well-Tested**: 90%+ code coverage
- 📖 **Great Help**: Built-in documentation

## Requirements

- Ruby 3.2 or higher
- macOS or Linux

## Installation

```bash
bundle install
bundle exec rake install
```

This installs `pocket-knife` to `/usr/local/bin/` (requires sudo password).

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
