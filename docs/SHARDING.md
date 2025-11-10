# Document Sharding Guide

## Overview

The PRD and Brief documents have been sharded into smaller, more manageable files for easier navigation and maintenance.

## Current Status

✅ **Partially Sharded** - Key sections have been manually sharded  
⏳ **Full Automation Available** - Install md-tree for complete sharding

## Sharded Documents

### PRD (Product Requirements Document)
- **Location:** `docs/prd/`
- **Index:** `docs/prd/index.md`
- **Sections Created:**
  - Goals and Background Context
  - Requirements (FR1-FR21, NFR1-NFR10)
  - _(More sections available after full sharding)_

### Brief (Project Brief)
- **Location:** `docs/brief/`
- **Status:** Index created, awaiting full sharding

## How to Complete Full Sharding

### Option 1: Automated (Recommended)

**Install the tool:**
```bash
npm install -g @kayvan/markdown-tree-parser
```

**Run the sharding script:**
```bash
./scripts/shard-documents.sh
```

This will:
- Automatically shard both PRD and Brief
- Create all section files with proper heading levels
- Maintain all formatting, code blocks, and diagrams
- Generate complete index files

### Option 2: Manual

The manual sharding process is documented in the BMad PM agent under the `shard-doc` task. However, automated sharding is strongly recommended for accuracy and speed.

## Benefits of Sharding

✅ **Easier Navigation** - Jump directly to relevant sections  
✅ **Better Maintenance** - Update specific sections without scrolling  
✅ **Clearer Organization** - Logical file structure mirrors document structure  
✅ **Version Control** - See changes to specific sections in git diff  
✅ **Collaboration** - Multiple people can work on different sections  

## Rebuilding Documents

If you need to rebuild the full documents from shards:

```bash
md-tree implode docs/prd docs/prd-rebuilt.md
md-tree implode docs/brief docs/brief-rebuilt.md
```

## Current File Structure

```
docs/
├── prd.md                          # Original (still maintained)
├── brief.md                        # Original (still maintained)
├── prd/
│   ├── index.md                    # ✅ Navigation index
│   ├── goals-and-background-context.md  # ✅ Created
│   ├── requirements.md             # ✅ Created
│   └── [other sections]            # ⏳ Pending full sharding
└── brief/
    ├── index.md                    # ⏳ Pending
    └── [sections]                  # ⏳ Pending full sharding
```

## Recommendations

**For Active Development:**
- Install md-tree and run full sharding
- Use sharded files for day-to-day work
- Keep originals as backup

**For Quick Reference:**
- Original `prd.md` and `brief.md` still work fine
- Sharded versions provide better navigation

## Next Steps

1. **Install md-tree:** `npm install -g @kayvan/markdown-tree-parser`
2. **Run script:** `./scripts/shard-documents.sh`
3. **Verify:** Check `docs/prd/` and `docs/brief/` for all sections
4. **Use:** Navigate via index.md files

---

**Created:** November 10, 2025  
**Maintained by:** PM (John)
