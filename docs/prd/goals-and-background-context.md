# Goals and Background Context

## Goals

- Enable developers to perform instant percentage calculations without leaving their terminal workflow
- Eliminate context-switching friction caused by opening external calculator applications
- Provide a simple, memorable command syntax that becomes second nature after minimal use
- Establish a foundation for a comprehensive terminal calculation toolkit
- Deliver production-ready Ruby CLI tool within 2-week timeframe

## Background Context

Developers frequently interrupt their workflow to perform basic percentage calculations—discounts, tax amounts, markups, or proportions. Current solutions require context-switching to GUI calculators, web searches, or writing throwaway code. Tools like `bc` exist but require memorizing complex formula syntax for simple operations.

This constant context-switching, while brief (30-60 seconds per instance), compounds throughout the day, disrupting flow state and reducing productivity. The problem is especially pronounced in remote terminal sessions, containerized environments, or minimal development setups where GUI tools aren't readily available.

Pocket Knife addresses this gap by providing a purpose-built, terminal-native percentage calculator that prioritizes speed, simplicity, and developer ergonomics.

## Change Log

| Date | Version | Description | Author |
|------|---------|-------------|--------|
| 2025-11-04 | 0.1 | Initial PRD creation from Project Brief | PM (John) |
| 2025-11-05 | 0.2 | Added LLM Integration Epic (Epic 2) - Natural language interface | PM (John) |
| 2025-11-06 | 0.3 | Added Product Storage Epic (Epic 3) - SQLite-based product storage | PM (John) |
| 2025-11-10 | 0.4 | Added Natural Language Product Query Epic (Epic 4) - ask-product command | PM (John) |
