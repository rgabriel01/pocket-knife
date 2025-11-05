# Pocket Knife Troubleshooting Guide

This guide covers common issues and solutions for the Pocket Knife CLI tool.

## Table of Contents

- [Installation Issues](#installation-issues)
- [Calculator (`calc`) Command Issues](#calculator-calc-command-issues)
- [LLM (`ask`) Command Issues](#llm-ask-command-issues)
- [API Key Issues](#api-key-issues)
- [Network & Connection Issues](#network--connection-issues)
- [General Debugging](#general-debugging)

---

## Installation Issues

### Problem: Bundle install fails

**Error:**
```
Could not find gem 'pocket_knife' in any of the sources
```

**Solution:**
```bash
# Ensure you're in the project directory
cd /path/to/pocket-knife

# Update bundler
gem install bundler

# Try installing again
bundle install
```

### Problem: Permission denied during installation

**Error:**
```
Permission denied @ dir_s_mkdir - /usr/local/bin
```

**Solution:**
```bash
# Run with sudo
sudo bundle exec rake install

# Or install to a user directory
bundle install --path vendor/bundle
```

### Problem: Ruby version too old

**Error:**
```
Your Ruby version is 3.1.0, but the application requires >= 3.2.0
```

**Solution:**
```bash
# Install Ruby 3.2+ using rbenv
rbenv install 3.2.9
rbenv local 3.2.9

# Or using rvm
rvm install 3.2.9
rvm use 3.2.9
```

---

## Calculator (`calc`) Command Issues

### Problem: "Missing subcommand" error

**Error:**
```
Error: Missing subcommand. Use: pocket-knife calc <amount> <percentage>
```

**Solution:**
```bash
# Correct usage - must include 'calc' subcommand
pocket-knife calc 100 20

# NOT: pocket-knife 100 20
```

### Problem: "Invalid percentage" error

**Error:**
```
Error: Invalid percentage. Please provide a whole number without the % symbol.
```

**Solution:**
```bash
# Correct - no % symbol
pocket-knife calc 100 20

# NOT: pocket-knife calc 100 20%
```

### Problem: Decimal percentage error

**Error:**
```
Error: Invalid percentage. Please provide a whole number.
```

**Context:** The calculator expects integer percentages for consistency.

**Solution:**
```bash
# For 7.5%, convert to decimal form or use 'ask' command
pocket-knife calc 100 7.5  # This works! Base can be decimal
pocket-knife ask "What is 7.5% of 100?"  # Alternative with LLM
```

**Note:** In recent versions, decimal bases are supported, but percentages should be whole numbers for the `calc` command.

### Problem: Result seems wrong

**Example:**
```bash
pocket-knife calc 100 20
# Output: 20.00 (expected)
```

**Verification:**
- Calculator computes: `(base * percentage) / 100`
- `100 * 20 / 100 = 20.00` ✓

**If result is unexpected:**
- Check that you're passing arguments in correct order: `<base> <percentage>`
- Verify base is not already a percentage (e.g., don't pass 0.20 for 20%)

---

## LLM (`ask`) Command Issues

### Problem: "LLM features not available" error

**Error:**
```
Error: LLM features not available. Install with: bundle install --with llm
  For direct calculations, use: pocket-knife calc <amount> <percentage>
```

**Solution:**
```bash
# Install LLM dependencies
bundle install --with llm

# Verify installation
bundle info ruby_llm

# If still failing, try redownloading
bundle install --redownload --with llm
```

### Problem: "No API key configured" error

**Error:**
```
Error: No API key configured. Set GEMINI_API_KEY in .env file or environment variable.
  Get a free key at: https://makersuite.google.com/app/apikey
  For direct calculations, use: pocket-knife calc <amount> <percentage>
```

**Solution - Method 1 (.env file - Recommended):**
```bash
# Copy the example file
cp .env.example .env

# Edit .env and add your API key
echo "GEMINI_API_KEY=your-actual-api-key-here" > .env

# Verify the file
cat .env
```

**Solution - Method 2 (Environment variable):**
```bash
# Temporary (current session only)
export GEMINI_API_KEY="your-actual-api-key-here"

# Permanent (add to ~/.zshrc or ~/.bashrc)
echo 'export GEMINI_API_KEY="your-actual-api-key-here"' >> ~/.zshrc
source ~/.zshrc
```

**Verify API key is set:**
```bash
# Should output your key (or be empty if not set)
echo $GEMINI_API_KEY
```

### Problem: "Missing query" error

**Error:**
```
Error: Missing query. Usage: pocket-knife ask "What is 20% of 100?"
  For direct calculations, use: pocket-knife calc <amount> <percentage>
```

**Solution:**
```bash
# Correct - query in quotes
pocket-knife ask "What is 20% of 100?"

# Also works - shell handles quoting
pocket-knife ask 'What is 20% of 100?'

# NOT: pocket-knife ask What is 20% of 100?
```

---

## API Key Issues

### Problem: "Invalid API key format" error

**Error:**
```
Error: Invalid API key format. Remove quotes and ensure no extra spaces.
  For direct calculations, use: pocket-knife calc <amount> <percentage>
```

**Common Causes:**

1. **Quotes in .env file:**
   ```bash
   # WRONG
   GEMINI_API_KEY="abc123xyz"
   
   # CORRECT
   GEMINI_API_KEY=abc123xyz
   ```

2. **Spaces around equals:**
   ```bash
   # WRONG
   GEMINI_API_KEY = abc123xyz
   
   # CORRECT
   GEMINI_API_KEY=abc123xyz
   ```

3. **Trailing newlines or spaces:**
   ```bash
   # Edit .env and ensure no extra whitespace
   vim .env
   # Should be: GEMINI_API_KEY=abc123xyz (no spaces/newlines after)
   ```

4. **Special characters:**
   - Gemini API keys should only contain: `A-Z`, `a-z`, `0-9`, `-`, `_`
   - If your key has other characters, regenerate it

**Verification:**
```bash
# Check the key format
echo "$GEMINI_API_KEY" | cat -A
# Should show: abc123xyz$ (with $ at end, nothing else)
```

### Problem: "Authentication failed" error

**Error:**
```
Error: Authentication failed: Invalid or expired API key.
  Please verify your GEMINI_API_KEY is correct.
  Get a new key at: https://makersuite.google.com/app/apikey
  For direct calculations, use: pocket-knife calc <amount> <percentage>
```

**Solution:**

1. **Verify key is correct:**
   ```bash
   # Check current key
   echo $GEMINI_API_KEY
   ```

2. **Generate new API key:**
   - Visit [Google AI Studio](https://makersuite.google.com/app/apikey)
   - Create new API key
   - Copy the full key (usually starts with "AIza...")

3. **Update your configuration:**
   ```bash
   # Update .env file
   echo "GEMINI_API_KEY=your-new-key-here" > .env
   
   # Or update environment variable
   export GEMINI_API_KEY="your-new-key-here"
   ```

4. **Test the new key:**
   ```bash
   pocket-knife ask "What is 20% of 100?"
   ```

### Problem: Where do I get an API key?

**Solution:**

1. Visit [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Sign in with your Google account
3. Click "Get API Key" or "Create API Key"
4. Copy the generated key (starts with "AIza...")
5. Add to your `.env` file or environment

**Note:** The free tier is generous and sufficient for personal use.

---

## Network & Connection Issues

### Problem: "Network error: Unable to connect to Gemini API"

**Error:**
```
Error: Network error: Unable to connect to Gemini API.
  Please check your internet connection and try again.
  For offline calculations, use: pocket-knife calc <amount> <percentage>
```

**Solution:**

1. **Check internet connection:**
   ```bash
   # Test connectivity
   ping -c 3 google.com
   ```

2. **Check DNS resolution:**
   ```bash
   # Verify you can resolve Google domains
   nslookup generativelanguage.googleapis.com
   ```

3. **Check firewall settings:**
   - Ensure outbound HTTPS (port 443) is allowed
   - Verify no VPN/proxy is blocking Google APIs

4. **Try again:**
   ```bash
   # Wait a moment and retry
   pocket-knife ask "What is 20% of 100?"
   ```

5. **Use offline alternative:**
   ```bash
   # Calculator works offline
   pocket-knife calc 100 20
   ```

### Problem: "Request timeout: The API took too long to respond"

**Error:**
```
Error: Request timeout: The API took too long to respond.
  Please try again later.
  For immediate results, use: pocket-knife calc <amount> <percentage>
```

**Solution:**

1. **Retry the request:**
   ```bash
   # API may be temporarily slow
   pocket-knife ask "What is 20% of 100?"
   ```

2. **Check Google Cloud Status:**
   - Visit [Google Cloud Status Dashboard](https://status.cloud.google.com/)
   - Look for issues with Vertex AI or Gemini API

3. **Use offline alternative:**
   ```bash
   # Get immediate results
   pocket-knife calc 100 20
   ```

### Problem: "Rate limit exceeded" error

**Error:**
```
Error: Rate limit exceeded: Too many requests to Gemini API.
  Please wait a moment and try again, or upgrade your API plan.
  For immediate results, use: pocket-knife calc <amount> <percentage>
```

**Solution:**

1. **Wait before retrying:**
   ```bash
   # Wait 60 seconds (free tier: 60 requests/minute)
   sleep 60
   pocket-knife ask "What is 20% of 100?"
   ```

2. **Check your usage:**
   - Visit [Google Cloud Console](https://console.cloud.google.com/)
   - Navigate to "APIs & Services" > "Dashboard"
   - Review Gemini API usage

3. **Use calc for immediate results:**
   ```bash
   # No rate limits on calc
   pocket-knife calc 100 20
   ```

4. **Upgrade your plan (if needed):**
   - Visit [Google Cloud Console](https://console.cloud.google.com/)
   - Upgrade to paid tier for higher limits

---

## General Debugging

### Enable verbose output

```bash
# Ruby debug mode
ruby -d bin/pocket-knife calc 100 20

# Check environment
env | grep GEMINI
```

### Check installation

```bash
# Verify executable exists
which pocket-knife

# Check version
pocket-knife --version  # (if implemented)

# Verify dependencies
bundle check

# Check Ruby version
ruby -v
```

### Test calculator without installation

```bash
# Run directly from source
bundle exec ruby -Ilib bin/pocket-knife calc 100 20

# Run tests
bundle exec rake test
```

### Common exit codes

- **0**: Success
- **1**: User error (wrong arguments, missing config, invalid input)
- **2**: System error (calculation failure, API error, network issue)

### Get more help

```bash
# Display help text
pocket-knife --help
pocket-knife calc --help
pocket-knife ask --help  # (if help is available for subcommands)
```

### Still having issues?

1. **Check the README:**
   - Review [README.md](../README.md) for setup instructions

2. **Search existing issues:**
   - Visit the GitHub repository
   - Search Issues for similar problems

3. **Create a new issue:**
   - Include error messages
   - Include steps to reproduce
   - Include system information (Ruby version, OS, etc.)

4. **Contact support:**
   - Open a GitHub issue with the "help wanted" label

---

## Quick Reference

### Most Common Solutions

| Problem | Quick Fix |
|---------|-----------|
| Missing gem | `bundle install --with llm` |
| No API key | `echo "GEMINI_API_KEY=your-key" > .env` |
| Invalid key format | Remove quotes from .env file |
| Network error | Check internet, try again |
| Rate limit | Wait 60 seconds or use `calc` |
| Missing subcommand | Use `calc` or `ask` before arguments |

### Support Commands

```bash
# Install/Update
bundle install --with llm
bundle exec rake install

# Verify installation
which pocket-knife
bundle info ruby_llm

# Check configuration
cat .env
echo $GEMINI_API_KEY

# Test commands
pocket-knife --help
pocket-knife calc 100 20
pocket-knife ask "What is 20% of 100?"

# Run tests
bundle exec rake test

# Uninstall
bundle exec rake uninstall
```

---

## FAQ

**Q: Do I need an API key to use the calculator?**  
A: No! The `calc` command works without any API key or internet connection. API keys are only needed for the optional `ask` command.

**Q: Is my data stored anywhere?**  
A: No. Pocket Knife doesn't store any data locally. When using the `ask` command, queries are sent to Google's Gemini API for processing, but Pocket Knife itself stores nothing.

**Q: How much does the Gemini API cost?**  
A: Google offers a generous free tier (60 requests/minute) which is sufficient for personal use. Check [Google AI Studio pricing](https://ai.google.dev/pricing) for details.

**Q: Can I use a different LLM provider?**  
A: Currently, only Google Gemini is supported. However, the architecture uses RubyLLM which supports multiple providers, so future versions could add support for OpenAI, Anthropic, etc.

**Q: Why does `calc` require integer percentages?**  
A: For consistency and clarity. However, the base amount can be a decimal. For decimal percentages, use the `ask` command.

**Q: Is the `ask` command slower than `calc`?**  
A: Yes, significantly. `ask` makes an API call to Gemini which takes 1-3 seconds. `calc` runs locally in milliseconds. Use `calc` for speed.

**Q: Can I use this in scripts?**  
A: Yes! The `calc` command is perfect for scripts as it's fast, offline, and has predictable output. The `ask` command can also be scripted but requires internet and an API key.

**Q: What if I get an error I don't understand?**  
A: All error messages include suggestions for next steps. If you're stuck, consult this guide or open a GitHub issue with the error message.

---

**Last Updated:** November 2025  
**Version:** 0.1.0
