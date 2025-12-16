# Changelog Patterns Guide

This guide covers the Keep a Changelog format and techniques for extracting changes from git history.

## Keep a Changelog Format

The standard format from [keepachangelog.com](https://keepachangelog.com):

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- New feature description

### Changed
- Change description

## [1.0.0] - 2024-01-15

### Added
- Initial release features

[Unreleased]: https://github.com/user/repo/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/user/repo/releases/tag/v1.0.0
```

## Change Categories

### Added
New features or capabilities.

**Examples:**
- New user authentication system
- Support for dark mode
- API endpoint for bulk operations
- Export to PDF functionality

### Changed
Changes to existing functionality.

**Examples:**
- Improved search performance
- Updated dashboard layout
- Changed default sorting order
- Migrated from REST to GraphQL

### Deprecated
Features that will be removed in future versions.

**Examples:**
- Legacy API v1 endpoints (use v2 instead)
- `oldFunction()` - use `newFunction()` instead
- Support for Node.js 16

### Removed
Features removed in this release.

**Examples:**
- Dropped support for IE11
- Removed deprecated `legacyMethod()`
- Removed unused admin panel

### Fixed
Bug fixes.

**Examples:**
- Fixed memory leak in image processing
- Resolved race condition in checkout flow
- Fixed incorrect date formatting in reports

### Security
Security-related changes.

**Examples:**
- Updated dependencies to patch CVE-2024-1234
- Fixed XSS vulnerability in comment system
- Added rate limiting to authentication endpoints

## Writing Good Changelog Entries

### Write for Users, Not Developers

**Good:** "Added ability to export reports as PDF"
**Bad:** "Implemented PDFGenerator class with streaming support"

### Be Specific About Impact

**Good:** "Fixed bug where checkout would fail for orders over $10,000"
**Bad:** "Fixed checkout bug"

### Link to Issues/PRs When Helpful

**Good:** "Added dark mode support (#234)"
**Bad:** "Added dark mode"

### Group Related Changes

**Good:**
```markdown
### Added
- User profile page with avatar upload
- Profile editing capabilities
- Public profile URLs
```

**Bad:**
```markdown
### Added
- Profile avatar upload
### Added
- Profile page
### Added
- Profile URLs
```

## Extracting Changes from Git

### Find Commits Since Last Release

```bash
# Since last tag
git log v1.0.0..HEAD --oneline

# Since specific date
git log --since="2024-01-01" --oneline

# Since last CHANGELOG update
git log $(git log -1 --format=%H -- CHANGELOG.md)..HEAD --oneline
```

### Categorize by Commit Message

Conventional Commits mapping:
- `feat:` → Added
- `fix:` → Fixed
- `refactor:` → Changed
- `docs:` → (usually not in changelog)
- `chore:` → (usually not in changelog)
- `BREAKING CHANGE:` → Changed (with migration note)
- `security:` or `sec:` → Security
- `deprecate:` → Deprecated
- `remove:` or `revert:` → Removed

```bash
# Find feature commits
git log --oneline --grep="^feat"

# Find fix commits
git log --oneline --grep="^fix"

# Find breaking changes
git log --oneline --grep="BREAKING"
```

### Identify Significant File Changes

```bash
# New files added
git diff --name-status v1.0.0..HEAD | grep "^A"

# Files deleted
git diff --name-status v1.0.0..HEAD | grep "^D"

# Configuration changes
git log --oneline -- "package.json" "*.config.*" ".env*"

# API changes
git log --oneline -- "*/api/*" "*/routes/*"
```

### Generate Change Summary

```bash
# Commits grouped by author
git shortlog v1.0.0..HEAD

# Files with most changes
git diff --stat v1.0.0..HEAD | sort -k3 -rn | head -20

# Merge commits (for PR-based workflows)
git log v1.0.0..HEAD --merges --oneline
```

## Semantic Versioning Alignment

### MAJOR (X.0.0)
Increment for breaking changes:
- Removed public APIs
- Changed function signatures
- Incompatible data format changes
- Dropped platform/version support

### MINOR (0.X.0)
Increment for new features:
- New functionality (backwards compatible)
- New API endpoints
- New optional parameters

### PATCH (0.0.X)
Increment for fixes:
- Bug fixes
- Security patches
- Documentation fixes
- Performance improvements (no API change)

## Changelog Entry Templates

### Feature Addition
```markdown
### Added
- **[Feature Name]**: Brief description of what users can now do. Configure in `path/to/config`. (#issue)
```

### Bug Fix
```markdown
### Fixed
- Fixed issue where [problem description] when [trigger condition]. (#issue)
```

### Breaking Change
```markdown
### Changed
- **BREAKING**: [What changed]. Migration: [steps to update]. See [link] for details.
```

### Security Fix
```markdown
### Security
- Fixed [vulnerability type] in [component]. Users should update immediately. (CVE-XXXX-XXXX)
```

### Deprecation Notice
```markdown
### Deprecated
- `oldFunction()` is deprecated and will be removed in v3.0. Use `newFunction()` instead.
```

## Automating Changelog Updates

### From Conventional Commits

If using conventional commits, changes map automatically:

| Commit Type | Changelog Section |
|-------------|-------------------|
| `feat:` | Added |
| `fix:` | Fixed |
| `perf:` | Changed |
| `refactor:` | Changed (if user-visible) |
| `security:` | Security |
| `revert:` | Removed or Fixed |

### Script to Extract Unreleased Changes

```bash
#!/bin/bash
# extract-changes.sh

LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")

if [ -z "$LAST_TAG" ]; then
  RANGE="HEAD"
else
  RANGE="$LAST_TAG..HEAD"
fi

echo "## [Unreleased]"
echo ""

echo "### Added"
git log $RANGE --oneline --grep="^feat" --format="- %s" | sed 's/^feat[:(]//' | sed 's/):/:/g'
echo ""

echo "### Fixed"
git log $RANGE --oneline --grep="^fix" --format="- %s" | sed 's/^fix[:(]//' | sed 's/):/:/g'
echo ""

echo "### Changed"
git log $RANGE --oneline --grep="^refactor\|^perf" --format="- %s"
```

## Common Mistakes to Avoid

### Missing User Impact
```markdown
# Bad
- Refactored UserService

# Good
- Improved user profile loading speed by 40%
```

### Internal-Only Changes
Don't include:
- Code refactoring (unless user-visible)
- Test additions
- Documentation typos
- Dependency updates (unless security-related)

### Inconsistent Formatting
Keep consistent:
- Sentence capitalization
- Period usage (use them or don't)
- Link formatting
- Date format (ISO: YYYY-MM-DD)

### Forgetting Unreleased Section
Always maintain an `[Unreleased]` section for work in progress.

## Verification Checklist

Before finalizing changelog entries:

- [ ] All user-visible changes documented
- [ ] Breaking changes clearly marked
- [ ] Security fixes highlighted
- [ ] Version number follows semver rules
- [ ] Date is in ISO format (YYYY-MM-DD)
- [ ] Links to issues/PRs work
- [ ] No internal/developer-only changes
- [ ] Entries are user-focused, not code-focused
