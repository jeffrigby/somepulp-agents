---
description: Run a comprehensive code audit on the project
arguments:
  - name: scope
    description: Optional scope for the audit (e.g., specific directory or file pattern)
    type: string
    required: false
---

Use the code-auditor agent to perform a comprehensive code quality audit on the codebase.

The audit will analyze:
- Dead code and unused dependencies
- Security vulnerabilities
- Performance issues
- Code quality and best practices violations
- TypeScript type safety issues
- Opportunities to use mature libraries

Generate a detailed markdown report (`code-audit-[timestamp].md`) with prioritized findings and actionable recommendations.

$ARGUMENTS
