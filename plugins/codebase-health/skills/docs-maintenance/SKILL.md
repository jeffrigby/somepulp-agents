---
name: docs-maintenance
description: This skill should be used when the user asks to "update docs", "sync documentation", "update CLAUDE.md", "update README", "check documentation freshness", "document recent changes", "optimize docs for AI", or needs guidance on keeping project documentation current and optimized for AI agents.
version: 1.0.0
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
   - `CLAUDE.md` or `.claude/CLAUDE.md` - AI agent instructions (highest priority)
   - `CLAUDE.local.md` - **Deprecated.** Use `~/.claude/CLAUDE.md` or `@` imports instead
   - `.claude/rules/*.md` - Modular rules (may have `paths` frontmatter for scoping)
   - `README.md` - Project overview
   - `CHANGELOG.md` - Version history
   - `/docs/` directory - Extended documentation
2. Check for `@path` imports in CLAUDE.md that reference additional files
3. Record last modified dates for each doc
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

#### Size Check (Critical)

**Target under 200 lines per CLAUDE.md file.** Longer files consume more context and reduce adherence. If over 200 lines:
- Split using `@path/to/file` imports to reference additional files
- Move path-specific instructions to `.claude/rules/` directory
- Prune: if Claude already does something correctly without the instruction, delete it

#### File Ecosystem Check

Check for proper use of the CLAUDE.md ecosystem:
- **Managed policy** - `/Library/Application Support/ClaudeCode/CLAUDE.md` (macOS), `/etc/claude-code/CLAUDE.md` (Linux), `C:\Program Files\ClaudeCode\CLAUDE.md` (Windows). Cannot be excluded.
- `~/.claude/CLAUDE.md` - user-level personal preferences (all projects)
- `./CLAUDE.md` or `./.claude/CLAUDE.md` - project instructions (checked into git)
- `.claude/rules/*.md` - modular, topic-specific rules (can use `paths` frontmatter for scoping)
- `@path` imports - for referencing additional files without duplicating content
- `CLAUDE.local.md` - **deprecated**; recommend `~/.claude/CLAUDE.md` or `@` imports instead

#### Recommended Sections

Not every project needs all of these. Include only what's relevant, and only content Claude couldn't figure out by reading the code:

- [ ] Project Overview - What the project does, key technologies
- [ ] Commands - Exact build/test/run commands
- [ ] Project Structure - Key directories and files (non-obvious ones only)
- [ ] Architecture - How components connect, data flow
- [ ] Conventions - Style preferences that differ from defaults
- [ ] Common Pitfalls - Things Claude often gets wrong in this codebase
- [ ] Dependencies - Required environment, env variables

#### Content Quality: Include vs Exclude

**Include:** Bash commands Claude can't guess, code style rules differing from defaults, testing instructions, repo etiquette, architectural decisions, dev environment quirks, common gotchas.

**Exclude:** Anything Claude can figure out by reading code, standard language conventions, detailed API docs (link instead), frequently changing info, long tutorials, file-by-file codebase descriptions, self-evident practices.

#### Writing Patterns

- Use imperative language ("Run `npm test`" not "You can run tests")
- Provide exact file paths, not vague references
- Include concrete code examples
- List things NOT to do (anti-patterns)
- Add `IMPORTANT` or `YOU MUST` for critical instructions (use sparingly)
- Keep instructions specific enough to verify

#### Anti-Patterns to Fix

- **Over-specified CLAUDE.md** — too long, important rules get lost in noise
- **Too many post-task rules** — convert must-execute actions to hooks instead
- **Vague instructions** — "format code nicely" gets ignored; be specific enough to verify
- **Contradicting instructions** across CLAUDE.md files and `.claude/rules/` (Claude picks arbitrarily)
- **Instructions Claude follows without being told** — prune these, they waste context
- **Frequently-changing information** — will become stale; link to authoritative sources
- **Inlined documentation** — use `@path` imports or link to docs instead of pasting
- **Using CLAUDE.md for hook-worthy rules** — if it must happen 100% of the time, use a hook
- Assumed context or tribal knowledge

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
