# Documentation Synchronization Methodology

This guide covers techniques for detecting when documentation is out of sync with code and methods for keeping them aligned.

## Documentation Freshness Analysis

### Timestamp Comparison

Compare last modification times between docs and code:

```bash
# Last CLAUDE.md update
git log -1 --format="%ci %s" -- CLAUDE.md

# Last code change (by file type)
git log -1 --format="%ci %s" -- "*.ts" "*.tsx" "*.js" "*.jsx"
git log -1 --format="%ci %s" -- "*.py"
git log -1 --format="%ci %s" -- "*.go"

# Compare: if code is newer than docs, docs may be stale
```

### Changes Since Last Doc Update

```bash
# Files changed since last CLAUDE.md update
LAST_DOC_COMMIT=$(git log -1 --format=%H -- CLAUDE.md)
git diff --name-only $LAST_DOC_COMMIT..HEAD

# Summary of changes
git diff --stat $LAST_DOC_COMMIT..HEAD

# Commits since last doc update
git log --oneline $LAST_DOC_COMMIT..HEAD
```

### Documentation File Discovery

```bash
# Find all markdown files
find . -name "*.md" -not -path "./node_modules/*" -not -path "./.git/*"

# Find documentation directories
find . -type d -name "docs" -o -name "documentation" -o -name "wiki"

# Find inline documentation
grep -r "/**" --include="*.ts" --include="*.js" -l .
grep -r '"""' --include="*.py" -l .
```

## Change Detection Patterns

### New Files and Directories

When these are added, documentation likely needs updates:

```bash
# New files since last tag/release
git diff --name-status v1.0.0..HEAD | grep "^A"

# New directories
git diff --name-status v1.0.0..HEAD | grep "^A" | cut -f2 | xargs -I{} dirname {} | sort -u
```

**Documentation triggers:**
- New `src/` subdirectories → Update project structure
- New API routes → Update API documentation
- New commands/scripts → Update command reference
- New config files → Update configuration section

### Configuration Changes

```bash
# Package manager changes
git log --oneline -- "package.json" "yarn.lock" "pnpm-lock.yaml"

# Build configuration
git log --oneline -- "*.config.js" "*.config.ts" "tsconfig.json" "vite.config.*"

# Environment
git log --oneline -- ".env*" "docker-compose*" "Dockerfile*"
```

**Documentation triggers:**
- New dependencies → May need setup instructions
- Script changes → Update commands section
- New env vars → Update environment documentation

### API and Interface Changes

```bash
# API route changes
git log --oneline -- "*/api/*" "*/routes/*" "**/route.ts" "**/route.js"

# Type definition changes
git log --oneline -- "*.d.ts" "*/types/*" "*/interfaces/*"

# Public exports
git log --oneline -- "**/index.ts" "**/index.js"
```

**Documentation triggers:**
- New endpoints → Update API reference
- Changed signatures → Update usage examples
- New types → Update type documentation

### Removed or Renamed Files

```bash
# Deleted files
git diff --name-status v1.0.0..HEAD | grep "^D"

# Renamed files
git diff --name-status v1.0.0..HEAD | grep "^R"
```

**Documentation triggers:**
- Removed features → Remove from docs
- Renamed files → Update path references
- Deprecated code → Add deprecation notices

## Cross-Document Consistency Checks

### Version Number Alignment

Check versions match across files:

```bash
# package.json version
grep '"version"' package.json

# CHANGELOG versions
grep "^## \[" CHANGELOG.md | head -5

# README badges/mentions
grep -E "v[0-9]+\.[0-9]+\.[0-9]+" README.md
```

### Path Reference Validation

```bash
# Extract paths from CLAUDE.md
grep -oE '`[^`]+\.(ts|js|tsx|jsx|py|go|rs|md)`' CLAUDE.md | tr -d '`' | sort -u

# Check if referenced files exist
grep -oE '`[^`]+\.(ts|js|tsx|jsx|py|go|rs|md)`' CLAUDE.md | tr -d '`' | while read f; do
  if [ ! -f "$f" ]; then
    echo "Missing: $f"
  fi
done
```

### Command Validation

```bash
# Extract commands from CLAUDE.md
grep -oE '`(npm|yarn|pnpm|python|go|cargo) [^`]+`' CLAUDE.md

# Verify npm scripts exist
grep -oE '`npm run [^`]+`' CLAUDE.md | sed 's/`npm run //' | sed 's/`//' | while read script; do
  if ! grep -q "\"$script\":" package.json; then
    echo "Missing script: $script"
  fi
done
```

### Link Validation

```bash
# Extract markdown links
grep -oE '\[([^\]]+)\]\(([^\)]+)\)' README.md CLAUDE.md

# Check internal links
grep -oE '\]\(\.\/[^\)]+\)' README.md | sed 's/](\.\///' | sed 's/)//' | while read link; do
  if [ ! -e "$link" ]; then
    echo "Broken link: $link"
  fi
done
```

## Documentation Update Triggers

### Automatic Triggers (Always Update)

| Change Type | Documentation Action |
|-------------|---------------------|
| New public API | Add to API reference |
| Removed feature | Remove from all docs |
| New dependency | Add setup instructions |
| New command/script | Add to commands section |
| Breaking change | Add migration guide |
| Security fix | Add to changelog, consider advisory |

### Conditional Triggers (Review Needed)

| Change Type | Documentation Action |
|-------------|---------------------|
| Refactored code | Update if architecture changed |
| Performance improvement | Update if user-visible |
| Internal reorganization | Update project structure if significant |
| Test changes | Usually no doc update needed |
| CI/CD changes | Update if affects contributors |

### Never Document

- Code formatting changes
- Internal variable renames
- Comment updates
- Non-user-facing refactors
- Temporary debug code

## Documentation Sync Workflow

### Step 1: Gather Change Information

```bash
# Create change report
echo "# Documentation Sync Report" > doc-sync-report.md
echo "" >> doc-sync-report.md
echo "## Changes Since Last Doc Update" >> doc-sync-report.md
echo "" >> doc-sync-report.md

LAST_DOC=$(git log -1 --format=%H -- CLAUDE.md)
git log --oneline $LAST_DOC..HEAD >> doc-sync-report.md
```

### Step 2: Categorize Changes

Review each commit and categorize:
1. **Document** - User-visible changes
2. **Verify** - May need documentation
3. **Skip** - Internal changes

### Step 3: Update Documents in Order

1. **CLAUDE.md first** - Most important for AI agents
2. **README.md** - User-facing overview
3. **CHANGELOG.md** - Version history
4. **/docs/** - Extended documentation
5. **Inline docs** - Only if critically outdated

### Step 4: Verify Updates

```bash
# Check all paths still valid
# Check all commands work
# Check examples compile/run
# Check cross-doc consistency
```

## Freshness Report Template

```markdown
# Documentation Freshness Report

Generated: [DATE]

## Summary

| Document | Last Updated | Code Changes Since | Status |
|----------|--------------|-------------------|--------|
| CLAUDE.md | 2024-01-10 | 15 commits | ⚠️ Review |
| README.md | 2024-01-15 | 8 commits | ✅ Current |
| CHANGELOG.md | 2024-01-05 | 20 commits | ❌ Stale |

## Changes Requiring Documentation

### New Features
- [ ] Feature X added in commit abc123
- [ ] Feature Y added in commit def456

### Breaking Changes
- [ ] API change in commit ghi789

### Removed Features
- [ ] Deprecated function removed in commit jkl012

## Verification Results

### Path References
- ✅ All paths in CLAUDE.md valid
- ⚠️ README references deleted file: `old-file.ts`

### Commands
- ✅ All npm scripts exist
- ⚠️ Command `npm run legacy` no longer works

### Links
- ✅ All internal links valid
- ❌ External link broken: https://example.com/old-docs
```

## Automation Opportunities

### Git Hooks

Pre-commit hook to warn about doc staleness:

```bash
#!/bin/bash
# .git/hooks/pre-commit

# Check if code changed but not docs
CODE_CHANGED=$(git diff --cached --name-only | grep -E '\.(ts|js|py|go)$' | wc -l)
DOCS_CHANGED=$(git diff --cached --name-only | grep -E '\.(md)$' | wc -l)

if [ "$CODE_CHANGED" -gt 5 ] && [ "$DOCS_CHANGED" -eq 0 ]; then
  echo "⚠️  Significant code changes without documentation updates"
  echo "   Consider updating CLAUDE.md or README.md"
fi
```

### CI/CD Checks

```yaml
# .github/workflows/docs-check.yml
- name: Check documentation freshness
  run: |
    LAST_CODE=$(git log -1 --format=%ct -- "*.ts")
    LAST_DOCS=$(git log -1 --format=%ct -- "CLAUDE.md")
    DIFF=$((LAST_CODE - LAST_DOCS))
    if [ $DIFF -gt 604800 ]; then  # 7 days in seconds
      echo "::warning::CLAUDE.md may be outdated"
    fi
```

### Scheduled Reviews

Set calendar reminders:
- Weekly: Quick scan for obvious staleness
- Monthly: Full documentation audit
- Per release: Comprehensive review
