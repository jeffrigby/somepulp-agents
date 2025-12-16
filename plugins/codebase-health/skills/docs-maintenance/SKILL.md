---
name: docs-maintenance
description: Keep project documentation current and optimized for AI agents. Use when user asks to "update docs", "sync documentation", "update CLAUDE.md", "update README", "check documentation freshness", "document recent changes", or "optimize docs for AI".
allowed-tools: Read, Write, Edit, Grep, Glob, Bash, TodoWrite
---

# Documentation Maintenance Skill

Comprehensive methodology for keeping project documentation current, consistent, and optimized for AI coding agents.

## When to Use

- Synchronizing documentation with recent code changes
- Optimizing CLAUDE.md for AI agent effectiveness
- Updating README to reflect current project state
- Adding CHANGELOG entries for undocumented changes
- Auditing documentation freshness and accuracy
- Ensuring cross-document consistency

## Documentation Update Phases

### Phase 1: Documentation Inventory

1. Find all documentation files in the project:
   - `CLAUDE.md` - AI agent instructions
   - `README.md` - Project overview
   - `CHANGELOG.md` - Version history
   - `/docs/` directory - Extended documentation
   - Inline documentation (JSDoc, docstrings, comments)
2. Record last modified dates for each doc
3. Identify documentation types and their purposes
4. Note any missing essential documentation

### Phase 2: Git History Analysis

1. Get commits since last documentation update:
   ```bash
   git log --oneline --since="$(git log -1 --format=%ci -- CLAUDE.md)"
   ```
2. Identify changes that need documentation:
   - New files or directories added
   - Configuration changes (package.json, tsconfig.json, etc.)
   - New commands, scripts, or entry points
   - API changes (new endpoints, modified signatures)
   - Dependency updates
   - Removed or deprecated features
3. Flag commits with keywords: "add", "remove", "breaking", "fix", "feat"
4. Check for removed features still documented

### Phase 3: CLAUDE.md Optimization

Verify CLAUDE.md includes essential sections:

**Required Sections:**
- [ ] Project Overview - What the project does
- [ ] Build/Test Commands - Exact commands to run
- [ ] Key File Locations - Important directories and files
- [ ] Architecture Overview - How components connect
- [ ] Coding Conventions - Naming patterns, style preferences
- [ ] Common Pitfalls - Things AI agents often get wrong
- [ ] Tool/Dependency Notes - Special requirements

**AI-Friendly Patterns:**
- Use imperative language ("Run `npm test`" not "You can run tests")
- Provide exact file paths, not vague references
- Include concrete code examples
- Be explicit about constraints and requirements
- List things NOT to do (anti-patterns)
- Keep instructions actionable and specific

**Anti-Patterns to Fix:**
- Vague descriptions ("the main file")
- Outdated commands or paths
- Missing error handling guidance
- Assumed context or tribal knowledge
- Inconsistent naming in instructions

### Phase 4: README Synchronization

1. Verify project description matches current state
2. Check installation instructions work
3. Validate usage examples are current
4. Ensure links and references are valid
5. Update badges and status indicators
6. Sync feature list with actual capabilities

### Phase 5: CHANGELOG Updates

Follow Keep a Changelog format:

**Categories:**
- **Added** - New features
- **Changed** - Changes in existing functionality
- **Deprecated** - Features to be removed
- **Removed** - Features removed
- **Fixed** - Bug fixes
- **Security** - Vulnerability fixes

**Best Practices:**
- Write for users, not developers
- Link to relevant issues/PRs
- Use semantic versioning alignment
- Date entries in ISO format (YYYY-MM-DD)
- Most recent changes at top

### Phase 6: Cross-Documentation Consistency

1. Check for contradictions between documents
2. Verify version numbers align across files
3. Validate code examples still work
4. Ensure terminology is consistent
5. Check that paths and references are accurate
6. Verify feature claims match implementation

### Phase 7: Apply Updates

1. **Before editing:**
   - Show proposed changes to user for significant updates
   - Use AskUserQuestion for ambiguous decisions
2. **When editing:**
   - Preserve existing structure and formatting
   - Match the document's existing tone
   - Add clear section headers for new content
   - Include timestamps where appropriate
3. **After editing:**
   - Generate summary of all changes made
   - List files modified with brief descriptions
   - Note any items requiring manual follow-up

## Documentation Freshness Indicators

**Stale Documentation Signs:**
- Code file newer than related docs
- Referenced files no longer exist
- Commands that fail when run
- Version mismatches
- Features documented but not implemented
- Implemented features not documented

**Freshness Commands:**
```bash
# Last doc update vs last code change
git log -1 --format=%ci -- CLAUDE.md
git log -1 --format=%ci -- "*.ts" "*.js" "*.py"

# Files changed since last CLAUDE.md update
git diff --name-only $(git log -1 --format=%H -- CLAUDE.md)..HEAD
```

## Resources

See the reference documents for detailed guidance:

- `references/claude-md-guide.md` - CLAUDE.md optimization patterns and section templates
- `references/changelog-patterns.md` - Keep a Changelog format and git extraction techniques
- `references/doc-sync-methodology.md` - Git commands, pattern detection, and automation

## Quick Reference

### Before Starting
- [ ] Find all documentation files
- [ ] Check git history for recent changes
- [ ] Identify documentation gaps
- [ ] Create update tracking list

### During Update
- [ ] Work through phases systematically
- [ ] Mark items as in-progress
- [ ] Ask user about ambiguous changes
- [ ] Preserve existing formatting and tone
- [ ] Mark items as completed

### After Update
- [ ] Verify all changes are consistent
- [ ] Test any commands or examples
- [ ] Generate change summary
- [ ] Note items for manual follow-up
