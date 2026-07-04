---
description: Update and synchronize project documentation with recent code changes
argument-hint: "<scope> <since>"
disable-model-invocation: true
---

Use the update-docs agent to analyze recent code changes and propose documentation updates.

Workflow:
1. Launch the update-docs agent to analyze git history, apply routine low-risk fixes, and return a proposed-updates plan for any significant changes
2. Review the returned plan and confirm significant changes with the user (via AskUserQuestion) before applying them
3. Apply the approved updates

This will:
- Analyze git history for undocumented changes
- Update CLAUDE.md to reflect current patterns and conventions
- Sync README with current project state
- Add CHANGELOG entries for recent changes
- Optimize documentation for AI agent consumption

Scope and time range: $ARGUMENTS
