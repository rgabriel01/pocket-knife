# Post-MVP Vision

## Phase 2 Features

Once the MVP proves valuable in daily use, the following enhancements would expand Pocket Knife's utility:

- **Additional Calculation Modes**:
  - `increase`: Calculate percentage increase (e.g., `pocket-knife increase 100 15` → 115.0)
  - `decrease`: Calculate percentage decrease (e.g., `pocket-knife decrease 200 25` → 150.0)
  - `of`: Reverse calculation - what % is X of Y (e.g., `pocket-knife of 25 200` → 12.5%)

- **Short Alias**: Introduce `pk` command for power users who use the tool dozens of times per day

- **Output Formatting**: Optional verbose mode (`-v` flag) with labeled output for clarity in interactive use

- **RubyGems Distribution**: Package and publish to RubyGems for easy `gem install pocket-knife` installation

## Long-term Vision

Pocket Knife evolves from a single-purpose percentage calculator into a comprehensive terminal-native calculation toolkit:

- **Expanded Math Operations**: Unit conversions, currency calculations, date/time arithmetic
- **Calculator Suite**: Common developer calculations (hex/binary conversions, base64, hashing)
- **Plugin Architecture**: Community-contributed calculation modules
- **Performance Optimization**: Native extension for zero-latency calculations
- **Cross-platform Support**: Pre-built binaries for systems without Ruby

## Expansion Opportunities

- **Team Adoption**: Share within development teams as a standard toolkit component
- **Language Ports**: Go or Rust versions for even faster execution and no runtime dependencies
- **Integration**: Plugins for popular terminals (iTerm2, Warp) or shells (zsh, fish)
- **Web Companion**: Simple web interface for sharing calculations or documentation
