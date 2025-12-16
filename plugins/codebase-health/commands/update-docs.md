---
description: Update and synchronize project documentation with recent code changes
arguments:
  - name: scope
    description: "Optional scope: 'claude-md', 'readme', 'changelog', 'all' (default: all)"
    type: string
    required: false
  - name: since
    description: "Analyze changes since date/commit (e.g., 'HEAD~10', '2024-01-01', 'v1.0.0')"
    type: string
    required: false
---

Use the update-docs agent to analyze recent code changes and update project documentation accordingly.

This will:
- Analyze git history for undocumented changes
- Update CLAUDE.md to reflect current patterns and conventions
- Sync README with current project state
- Add CHANGELOG entries for recent changes
- Optimize documentation for AI agent consumption

$ARGUMENTS
