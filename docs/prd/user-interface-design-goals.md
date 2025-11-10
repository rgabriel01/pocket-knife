# User Interface Design Goals

## Overall UX Vision

The command-line interface should feel natural and invisible—users should be able to invoke the tool from muscle memory without consulting documentation after initial use. The interaction should be so fast and frictionless that it becomes the default choice for percentage calculations over any alternative.

## Key Interaction Paradigms

- **Command-line only** - No GUI, web interface, or interactive modes
- **Single-purpose invocation** - One command, immediate result, exit
- **Self-documenting** - Command structure makes purpose clear (`calc` subcommand)
- **Terminal-standard** - Follows POSIX conventions for flags, help, and exit codes

## Core Interaction Flow

1. User types `pocket-knife calc <amount> <percentage>`
2. Tool validates input
3. Tool displays result (or error) to stdout
4. Tool exits

**Example Successful Interaction:**
```bash
$ pocket-knife calc 100 20
20.00
```

**Example Error Interaction:**
```bash
$ pocket-knife calc 100 abc
Error: Invalid percentage. Please provide a whole number.
```

## Accessibility

- **Terminal accessibility** - Compatible with screen readers via standard terminal output
- **Colorblind-friendly** - No reliance on color for information (text-only output)
- **Keyboard-only** - No mouse/pointing device required

## Target Platforms

- **macOS Terminal / iTerm2**
- **Linux terminal emulators** (bash, zsh, fish shells)
- **Remote SSH sessions**
- **CI/CD environments** (for scripted use)
