---
description: Detect and clean up dead code (unused imports, exports, files, dependencies)
arguments:
  - name: mode
    description: "'detect' (default) shows findings, 'cleanup' allows removal after approval"
    type: string
    required: false
---

# Dead Code Detection

Analyze the project for dead code using automated tools with agent verification.

## Mode

$ARGUMENTS

- **detect** (default): Find and report dead code, no modifications
- **cleanup**: Find dead code, then offer to remove after user approval

## Tools Used

- **JavaScript/TypeScript**: knip (`npx knip`)
- **Python**: deadcode (`pip install deadcode`)

Project type is auto-detected from package.json, tsconfig.json, requirements.txt, or pyproject.toml.

## IMPORTANT: False Positive Handling

Dead code tools return many false positives. The agent MUST verify each finding before reporting:

### Verify Before Reporting
For each flagged item:
1. **Read the flagged code** to understand its context
2. **Check for dynamic references**: `import(variable)`, `require(variable)`, reflection
3. **Check framework patterns**: React components, decorators, middleware
4. **Check re-exports**: Is this in an index.ts barrel file for public API?
5. **Check entry points**: CLI scripts, serverless handlers, workers

### Common False Positives to Filter
- Dynamic imports: `import(modulePath)`, `require(variableName)`
- React/Vue components used in JSX/templates
- Decorated classes (Angular, NestJS, Python decorators)
- Re-exports for public API in index files
- Entry points configured outside standard patterns
- Test utilities only used in test files
- CLI scripts or serverless handlers

## Workflow

1. Run detection tool via `${CLAUDE_PLUGIN_ROOT}/scripts/dead-code-detect.sh`
2. Parse findings into categories
3. **Verify each item** - read code, filter false positives
4. Present verified report to user
5. If cleanup mode: ask user to approve/exclude/cancel
6. Apply approved fixes

## Report Format

Present findings as:

```
## Dead Code Analysis Report

### Summary
- Unused exports: X (verified)
- Unused imports: Y (verified)
- Unused dependencies: Z (verified)

### Unused Exports
| File | Export | Line |
|------|--------|------|
| src/utils.ts | formatDate | 42 |

### Filtered (False Positives)
- ComponentName - React component (JSX usage)
- dynamicLoader - dynamic import pattern
```

## Cleanup Flow

If mode=cleanup, after showing report:

1. Ask: "Does this look correct? Would you like to proceed with cleanup?"
2. Options: Apply all / Exclude specific items / Cancel
3. If excluding, let user specify what to keep
4. Run `npx knip --fix` or `deadcode --fix` for approved items
5. Show summary of changes

Use the `dead-code-cleanup` agent for the cleanup workflow.
