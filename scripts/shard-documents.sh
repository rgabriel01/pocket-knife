#!/bin/bash

# Document Sharding Script for Pocket Knife
# This script will automatically shard the PRD and Brief documents

echo "📋 Pocket Knife Document Sharding Script"
echo "=========================================="
echo ""

# Check if md-tree is installed
if ! command -v md-tree &> /dev/null; then
    echo "❌ md-tree is not installed"
    echo ""
    echo "To install, run:"
    echo "  npm install -g @kayvan/markdown-tree-parser"
    echo ""
    echo "After installation, run this script again."
    exit 1
fi

echo "✅ md-tree found"
echo ""

# Shard PRD
echo "📄 Sharding PRD document..."
cd /Users/teamified/Documents/BMad
md-tree explode docs/prd.md docs/prd

if [ $? -eq 0 ]; then
    echo "✅ PRD sharded successfully to docs/prd/"
else
    echo "❌ PRD sharding failed"
    exit 1
fi

echo ""

# Shard Brief
echo "📄 Sharding Brief document..."
md-tree explode docs/brief.md docs/brief

if [ $? -eq 0 ]; then
    echo "✅ Brief sharded successfully to docs/brief/"
else
    echo "❌ Brief sharding failed"
    exit 1
fi

echo ""
echo "🎉 Document sharding complete!"
echo ""
echo "Sharded files are in:"
echo "  - docs/prd/"
echo "  - docs/brief/"
echo ""
echo "To rebuild, run:"
echo "  md-tree implode docs/prd docs/prd.md"
echo "  md-tree implode docs/brief docs/brief.md"
