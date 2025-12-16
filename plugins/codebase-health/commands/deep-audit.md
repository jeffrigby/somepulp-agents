---
description: Run a comprehensive deep audit on the codebase
arguments:
  - name: scope
    description: Optional scope for the audit (e.g., specific directory or file pattern)
    type: string
    required: false
---

Use the deep-audit agent to perform a comprehensive, resource-intensive code quality audit on the codebase.

**Note**: This is an ON-DEMAND operation for thorough analysis. For quick checks on recent changes, use `/quick-check` instead.

The deep audit will analyze:
- Dead code and unused dependencies
- Security vulnerabilities
- Performance issues
- Code quality and best practices violations
- TypeScript type safety issues
- Opportunities to use mature libraries
- Library documentation via Context7

Generate a detailed markdown report (`code-audit-[timestamp].md`) with prioritized findings and actionable recommendations.

$ARGUMENTS
