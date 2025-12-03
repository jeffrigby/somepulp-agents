---
description: Run a quick quality check on recent changes or specific files
arguments:
  - name: scope
    description: Files, directories, or patterns to check (e.g., "src/auth.ts", "src/**/*.ts", or leave empty for recent changes)
    type: string
    required: false
---

# Quick Quality Check

Perform a fast, focused code quality check on the specified files or scope.

**Note**: This is a lightweight check for routine use. For comprehensive full-codebase audits, use `/deep-audit` instead.

## What to Analyze

$ARGUMENTS

If no specific files are provided, analyze recently modified files (check `git status` and `git diff`).

## Audit Focus Areas

1. **Dead Code** - Unused imports, functions, variables, and code paths
2. **Comment Quality** - Obvious comments, outdated comments, commented-out code
3. **DRY Violations** - Duplicated code that should be abstracted
4. **Security Issues** - Hardcoded secrets, injection risks, missing validation
5. **Performance** - Inefficient algorithms, blocking operations, missing caching
6. **Linting/Types** - ESLint errors, TypeScript issues, formatting problems

## Output

Provide findings organized by priority:
- **Critical**: Security vulnerabilities, type errors, breaking bugs
- **High**: Dead code, significant DRY violations, performance issues
- **Medium**: Minor duplication, suboptimal patterns
- **Low**: Comment cleanup, minor style issues

Include specific file paths and line numbers for each finding.
