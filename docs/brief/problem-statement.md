# Problem Statement

Developers and technical users frequently need to perform quick percentage calculations during their daily work—calculating discounts, tax amounts, percentage increases/decreases, or proportions. Current solutions force users to context-switch away from their terminal workflow:

- **Desktop calculators** require switching applications and breaking focus
- **Web-based calculators** necessitate opening a browser and searching
- **Built-in shell tools** like `bc` require complex syntax and formula knowledge for percentage operations
- **Scripting solutions** demand writing throwaway code for simple calculations

This constant context-switching disrupts developer flow and wastes valuable time on trivial calculations. While the impact per calculation is small (30-60 seconds), these interruptions compound throughout the day, breaking concentration and reducing productivity. The problem is particularly acute for developers working in remote terminal sessions, containerized environments, or minimal setups where GUI tools aren't readily available.

**Current pain points:**
- Loss of focus from application switching
- Time wasted on simple calculations
- Cognitive overhead of `bc` syntax for basic operations
- Lack of a purpose-built, terminal-native solution
