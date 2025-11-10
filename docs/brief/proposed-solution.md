# Proposed Solution

Pocket Knife is a Ruby-based CLI tool that provides instant percentage calculations without leaving the terminal. The MVP focuses on the single most common operation: **calculating X% of Y**.

**Core Approach:**
- **Single command** with clear syntax: `pocket-knife calc <amount> <percentage>`
- **Instant results** displayed directly in terminal
- **Zero configuration** - works immediately after installation
- **Lightweight footprint** - minimal dependencies, fast execution
- **Terminal-native** - designed for keyboard-driven workflows

**Command Syntax:**

```bash
# Calculate X% of Y
$ pocket-knife calc 100 20
20.00

# Built-in help
$ pocket-knife --help
$ pocket-knife calc --help
```

**Key Differentiators:**
- **Purpose-built for percentages** - Unlike `bc` which requires formula knowledge, Pocket Knife uses natural syntax
- **Self-documenting** - The `calc` subcommand makes the tool's purpose immediately clear
- **Developer-friendly** - Designed by developers, for developers who value speed and simplicity
- **Ruby ecosystem** - Leverages Ruby's readability and ease of distribution
- **Extensible foundation** - Clean architecture allows adding more calculation types post-MVP

**Why This Will Succeed:**
The tool succeeds by doing one thing exceptionally well: making the most common percentage calculation (X% of Y) trivial in the terminal. The subcommand structure provides clarity without complexity—`calc` makes the intent obvious while keeping the syntax simple. Rather than competing with full-featured calculators, Pocket Knife fills a specific gap—providing the fastest path from "I need to calculate X% of Y" to seeing the answer.
