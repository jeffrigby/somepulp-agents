---
description: Run a comprehensive deep audit by orchestrating specialist agents
argument-hint: "[aspects] [sequential]"
allowed-tools: ["Bash", "Glob", "Grep", "Read", "Write", "Task", "TodoWrite"]
---

# Deep Audit (Orchestrator)

Run a comprehensive, on-demand codebase audit by inspecting the project, deciding which specialist agents apply, launching them, and aggregating their findings into a single dated report.

This is **resource-intensive** and should only run when explicitly requested. For quick checks on recent changes, just ask Claude to review the diff.

**Aspects requested (optional):** "$ARGUMENTS"

## Audit Aspects

- **security** → `security-auditor` (secrets, injection, XSS, weak crypto, CVEs)
- **perf** → `performance-analyzer` (algorithms, N+1, async, memory, bundles)
- **deps** → `library-modernizer` (custom code → mature lib, deprecated APIs, `@types` duplication)
- **quality** → `code-quality-reviewer` (smells, complexity, duplication, error handling)
- **dead** → `dead-code-cleanup` in detect-only mode (unused imports/exports/files/deps, with verification)
- **all** → run every applicable specialist (default if no aspects given)

The launch mode is **parallel by default** — `/deep-audit` produces a batch report, so there's no reason to wait. All selected specialists are launched at once via a single message with multiple `Task` calls. Append the literal token `sequential` to fall back to one-at-a-time execution (useful when debugging a specialist or when a transcript is easier to read serially).

## Workflow

### 1. Parse arguments

Split `$ARGUMENTS` on whitespace. Tokens that match an aspect (`security`, `perf`, `deps`, `quality`, `dead`, `all`) select that specialist. The token `sequential` switches launch mode to one-at-a-time. Anything else is treated as a free-form scope hint to pass into each specialist (e.g., a path, glob, or "src/api only").

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
| `dead-code-cleanup` | A dependency manifest exists. If `dead` was requested (or selected via `all`) but no manifest exists, **the Notes section must include an explicit `Dead code: skipped — no manifest` line** before the report is written — never silently omit. |

If the user requested specific aspects, only run those — don't override their selection.

### 4. Launch specialists

Use the `Task` tool to invoke each selected specialist. Pass each one:

- The **project brief** from step 2
- The **scope** (free-form scope hints from `$ARGUMENTS`, or "full codebase")
- An instruction to **return only the structured findings block** described in the agent's prompt — not save a file

**Parallel mode (default):** issue all selected `Task` calls in a single assistant message so they run concurrently. Capture each result as it returns.

**Sequential mode (`sequential` arg present):** issue one `Task` call, wait for the result, capture the markdown, then issue the next.

For `dead`, invoke `dead-code-cleanup` and instruct it to **detect only** (no removal). Tell it to return its verified findings as a markdown block matching the format below.

### 4a. Verify each specialist returned a valid findings block

Before pasting a result into the report, confirm it starts with the specialist's expected `## ` heading and contains at least one of `### Critical`, `### High`, or `### Medium`. A specialist with literally zero findings still emits the heading and severity sections (possibly empty).

| Specialist | Expected heading |
| --- | --- |
| `security-auditor` | `## Security Findings` |
| `performance-analyzer` | `## Performance Findings` |
| `library-modernizer` | `## Library Modernization Findings` |
| `code-quality-reviewer` | `## Code Quality Findings` |
| `dead-code-cleanup` | `## Dead Code Analysis Report` (or `## Dead Code Findings`) |

If a result is empty, missing the expected heading, or has no severity sections, treat the specialist as **failed**: do not paste a placeholder block. Record it under `Specialists that failed:` in the Notes section (step 5) with a one-line cause (`empty result`, `missing findings heading`, `task error: <message>`). A launched specialist must never be silently dropped from the report.

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
- Specialists that failed: list each as `<name> — <cause>` (omit this line entirely if all specialists returned valid blocks; never omit a launched specialist silently)
- Dead code: skipped — no manifest (REQUIRED line when `dead` was requested or selected via `all` and no dependency manifest exists; required regardless of whether other specialists ran)
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
# All applicable specialists, in parallel (default)

/deep-audit all sequential
# All applicable specialists, one at a time

/deep-audit security
# Just the security specialist

/deep-audit security perf
# Security + perf, in parallel

/deep-audit quality src/api
# Code-quality specialist scoped to src/api

/deep-audit security sequential
# Security only, sequential (rarely useful — only one specialist)
```

## Notes

- Each specialist returns a structured findings block — never a full report. The orchestrator owns aggregation, prioritization, and the final markdown.
- Specialists must not invoke each other. They are peers; you are the conductor.
- Confidence threshold is enforced inside each specialist (≥ 80). Don't second-guess their filtering — pass their output through.
- Specialist agents have descriptions that explicitly tell Claude not to invoke them directly; that's why `/deep-audit` exists as the entry point.
- The project's audit methodology reference at `${CLAUDE_PLUGIN_ROOT}/skills/code-auditing/SKILL.md` is available if a specialist wants to consult it, but specialists are written to be self-contained.
