---
description: Run a comprehensive deep audit by orchestrating specialist agents
argument-hint: "[aspects] [parallel]"
allowed-tools: ["Bash", "Glob", "Grep", "Read", "Write", "Task", "TodoWrite"]
---

# Deep Audit (Orchestrator)

Run a comprehensive, on-demand codebase audit by inspecting the project, deciding which specialist agents apply, launching them, and aggregating their findings into a single dated report.

This is **resource-intensive** and should only run when explicitly requested. For quick checks on recent changes, use `/codebase-health:quick-check` if installed, or just ask Claude to review the diff.

**Aspects requested (optional):** "$ARGUMENTS"

## Audit Aspects

- **security** → `security-auditor` (secrets, injection, XSS, weak crypto, CVEs)
- **perf** → `performance-analyzer` (algorithms, N+1, async, memory, bundles)
- **deps** → `library-modernizer` (custom code → mature lib, deprecated APIs, `@types` duplication)
- **quality** → `code-quality-reviewer` (smells, complexity, duplication, error handling)
- **dead** → `dead-code-cleanup` in detect-only mode (unused imports/exports/files/deps, with verification)
- **all** → run every applicable specialist (default if no aspects given)

The launch mode is **sequential by default**. Append the literal token `parallel` to the arguments to launch all selected specialists at once via a single message with multiple `Task` calls. Sequential is easier to follow in the transcript; parallel is faster.

## Workflow

### 1. Parse arguments

Split `$ARGUMENTS` on whitespace. Tokens that match an aspect (`security`, `perf`, `deps`, `quality`, `dead`, `all`) select that specialist. The token `parallel` switches launch mode. Anything else is treated as a free-form scope hint to pass into each specialist (e.g., a path, glob, or "src/api only").

If no aspects are given, treat it as `all`.

### 2. Pre-analysis (orchestrator does this directly)

Read the project skeleton so each specialist gets a useful brief:

- Tech stack: presence of `package.json`, `tsconfig.json`, `requirements.txt`, `pyproject.toml`, `go.mod`, `Cargo.toml`, etc.
- Project conventions: read `CLAUDE.md` and top-level `README.md` if present.
- Existing baselines: if a lint/typecheck script exists in `package.json`, run it once and capture errors as a baseline (don't re-flag those).
- Inventory: a Glob count of code files by extension to gauge audit size.

Build a short "project brief" that you'll include in every specialist's task input.

### 3. Decide which specialists apply

| Aspect | Applies when |
| --- | --- |
| `security-auditor` | Always (every codebase has a security surface) |
| `performance-analyzer` | Always |
| `library-modernizer` | A dependency manifest exists (`package.json`, `requirements.txt`, `go.mod`, etc.) |
| `code-quality-reviewer` | Always |
| `dead-code-cleanup` | A dependency manifest exists; otherwise note that automated tools won't run |

If the user requested specific aspects, only run those — don't override their selection.

### 4. Launch specialists

Use the `Task` tool to invoke each selected specialist. Pass each one:

- The **project brief** from step 2
- The **scope** (free-form scope hints from `$ARGUMENTS`, or "full codebase")
- An instruction to **return only the structured findings block** described in the agent's prompt — not save a file

**Sequential mode (default):** issue one `Task` call, wait for the result, capture the markdown, then issue the next.

**Parallel mode (`parallel` arg present):** issue all selected `Task` calls in a single assistant message so they run concurrently. Capture each result.

For `dead`, invoke `dead-code-cleanup` and instruct it to **detect only** (no removal). Tell it to return its verified findings as a markdown block matching the format below.

### 5. Aggregate the report

Compose `code-audit-[YYYY-MM-DD-HHmmss].md` in the project root:

```markdown
# Codebase Audit — [YYYY-MM-DD HH:mm:ss]

## Executive Summary
- Files analyzed: N
- Specialists run: [list]
- Total findings: Critical X, High Y, Medium Z
- Top 3–5 most critical issues (one line each, with file:line)

## Project Brief
[the brief built in step 2]

---

[Paste each specialist's findings block here, in this order:
  Security Findings,
  Performance Findings,
  Library Modernization Findings,
  Code Quality Findings,
  Dead Code Findings]

---

## Prioritized Action Plan
1. [Critical fixes — file:line, one-line summary, T-shirt size S/M/L/XL]
2. [High-priority fixes]
3. [Medium-priority fixes]
4. [Quick wins (< 30 min)]

## Notes
- Tools that were unavailable and what was skipped
- Findings flagged by multiple specialists (deduped or cross-referenced)
```

Use the Write tool to save the report to `code-audit-[YYYY-MM-DD-HHmmss].md` (current date/time, project root).

### 6. Console summary

After saving, print a short summary:

- Path to the report file
- Counts by severity
- Top 3 critical findings
- One line: "Run `/dead-code cleanup` to interactively remove verified dead code" (if `dead` was run and findings exist)

## Usage Examples

```
/deep-audit
# All applicable specialists, sequential

/deep-audit all parallel
# All applicable specialists, in parallel

/deep-audit security
# Just the security specialist

/deep-audit security perf parallel
# Security + perf, in parallel

/deep-audit quality src/api
# Code-quality specialist scoped to src/api
```

## Notes

- Each specialist returns a structured findings block — never a full report. The orchestrator owns aggregation, prioritization, and the final markdown.
- Specialists must not invoke each other. They are peers; you are the conductor.
- Confidence threshold is enforced inside each specialist (≥ 80). Don't second-guess their filtering — pass their output through.
- Specialist agents have descriptions that explicitly tell Claude not to invoke them directly; that's why `/deep-audit` exists as the entry point.
- The project's audit methodology reference at `${CLAUDE_PLUGIN_ROOT}/skills/code-auditing/SKILL.md` is available if a specialist wants to consult it, but specialists are written to be self-contained.
