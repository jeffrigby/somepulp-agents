---
description: Detect and clean up dead code (unused imports, exports, files, dependencies)
argument-hint: "<detect|cleanup>"
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

1. Invoke the `dead-code-cleanup` agent to run detection and verification:
   - The agent runs the detection tool via `"${CLAUDE_PLUGIN_ROOT}"/scripts/dead-code-detect.sh`
   - It parses findings into categories and **verifies each item** (reads code, filters false positives)
   - It returns a verified report plus a proposed cleanup plan grouped by confidence (safe / needs-review)
2. Present the returned report and plan to the user
3. If cleanup mode: use AskUserQuestion to ask which groups to remove
4. Apply only the approved removals

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

If mode=cleanup, after the agent returns its report and plan:

1. Use AskUserQuestion to ask which groups to remove:
   - Safe-to-remove group only
   - Safe + needs-review groups
   - Exclude specific items
   - Cancel
2. If excluding, let user specify what to keep
3. Apply only the approved removals: re-invoke the `dead-code-cleanup` agent with the explicitly approved list, or apply them directly here (`npx knip --fix` / `deadcode --fix` only when everything was approved; otherwise remove items surgically)
4. Show summary of changes and recommend running tests

Note: the `dead-code-cleanup` agent runs as a subagent and cannot prompt the user itself — approval always happens here, in the main conversation.
