# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Claude Code plugin marketplace called `somepulp-agents` that provides specialized AI agents and skills for code auditing, documentation maintenance, and library/API research.

## Repository Structure

This is a **plugin marketplace** containing multiple independent plugins:

```tree
somepulp-agents/
├── .claude-plugin/marketplace.json    # Marketplace manifest
├── plugins/
│   ├── codebase-health/               # Code auditing & documentation
│   └── research-assistant/            # Library/API research with MCP
├── CLAUDE.md                          # This file
├── README.md                          # User-facing documentation
└── CHANGELOG.md                       # Version history
```

Each plugin follows the standard structure:
- **`.claude-plugin/plugin.json`** - Plugin manifest (metadata only; agents and skills are auto-discovered from their default directories, not enumerated in the manifest)
- **`agents/`** - Markdown agents with YAML frontmatter
- **`skills/`** - Skills (`skills/<name>/SKILL.md`), each of which is also the `/<name>` slash command
- **`scripts/`** - Helper shell scripts (optional)

There is no `commands/` directory. Custom commands were merged into skills — `commands/deploy.md` and `skills/deploy/SKILL.md` both create `/deploy` and behave identically — and the docs direct new plugins to `skills/`, which additionally supports a directory of bundled files, `name`, and `paths`.

## Agent and Skill Format

### Agent Files (`agents/*.md`)
```yaml
---
name: agent-name
description: One-line trigger description. Use when user asks "X", "Y", or "Z".
tools: ["Read", "Grep", "Glob", "Bash"]
model: inherit
color: blue
---

System prompt content defining agent behavior...

## Example Invocations

<example>
Context: ...
user: "..."
assistant: "..."
</example>
```

**Important**: Keep `description` to a single line. Multi-line content (especially `<example>` blocks) belongs in the body, not the frontmatter — the description is what Claude reads when deciding whether to delegate, and every non-built-in subagent's description shares a ~15,000-token budget (exceeding it produces a startup warning). Skills are capped separately: `description` + `when_to_use` are truncated at 1,536 characters in the skill listing (configurable via `skillListingMaxDescChars`).

### Skill Files (`skills/*/SKILL.md`)
```yaml
---
name: skill-name
description: What the skill does and which use cases it covers (use-case-first)
when_to_use: Trigger phrases, e.g. when the user asks to "X", "Y", or "Z"
allowed-tools: Read, Grep, Glob, Bash
---

Skill methodology and guidance...
```

Reference materials go in `skills/*/references/*.md` and are referenced from the skill body via `${CLAUDE_SKILL_DIR}` (e.g. `${CLAUDE_SKILL_DIR}/references/checklist.md`).

**Target**: this marketplace is Claude-Code-only. `when_to_use` and `argument-hint` are Claude Code extensions, not Agent Skills spec fields — do not strip them for spec portability (`package_skill.py` would reject them, but we don't package for claude.ai upload or the Skills API).

The directory name is the slash command: `skills/deep-audit/SKILL.md` → `/deep-audit`. Keep `name` equal to the directory name.

Optional frontmatter used in this repo:
- `argument-hint` - autocomplete hint for expected arguments
- `disable-model-invocation: true` - user-invoked only, never auto-triggered (set on `/deep-audit`, `/update-docs`, and `/update-deps` — the first two have their auto-routing handled by the `code-auditing` and `docs-maintenance` methodology skills instead; `/update-deps` mutates `package.json`)
- `allowed-tools` - tools usable without a permission prompt while the skill is active (`/deep-audit`, `/update-deps`)
- `hooks` - lifecycle hooks registered while the skill is active. Use `type: agent` (not `type: prompt`) when the hook must inspect files or run commands; a prompt hook sees only the hook's JSON input. Both return `{"ok": true}` or `{"ok": false, "reason": "..."}`. Agent hooks are experimental.
- `context: fork` + `agent: <agent-name>` - run the skill in a forked subagent context as the named agent (`/research`, `/official-docs`)

Argument substitution: `$ARGUMENTS` for everything, `$ARGUMENTS[N]` / `$N` for a positional argument.

## Tool Naming Conventions

### MCP Tools
MCP tool names take the form `mcp__<server>__<tool>` (plugin-bundled servers: `mcp__plugin_<plugin>_<server>__<tool>`). This repo additionally requires the **lowercase** server segment as a house convention — the docs specify the shape but not the casing. Examples:
- `mcp__context7__resolve-library-id` (correct)
- `mcp__context7__query-docs` (correct)
- `mcp__fetch__fetch` (correct)
- ~~`mcp__Context7__resolve-library-id`~~ (incorrect - wrong casing)

### Valid Claude Code Tools
Standard tools: `Read`, `Write`, `Edit`, `Grep`, `Glob`, `Bash`, `WebSearch`, `WebFetch`, `TodoWrite`, `AskUserQuestion`

**Tools filtered in subagent context** (applies to `agents/*.md` only — not to skills, which run in the main conversation unless they set `context: fork`):
- `Agent` (renamed from `Task` in Claude Code v2.1.63; `Task` remains an alias) - Stripped only when the subagent is at the nesting depth limit. Subagent `tools` supports `Agent(type)` syntax to restrict which subagent types may be spawned. This repo's specialists are spawned by `/deep-audit`, so they are at the limit in practice — don't list `Agent` in them.
- `AskUserQuestion` - Unavailable inside subagents even when listed in `tools`. Valid in a skill's `allowed-tools` when the skill runs in the main conversation.
- `LS` - Not a standard Claude Code tool; use `Glob` for file discovery or `Bash` with `ls`

## External Tool Integration

### Research Assistant
- Prioritizes Context7 MCP for official documentation
- Uses `gh` CLI for GitHub operations and code examples
- Falls back to WebSearch/WebFetch if MCP tools unavailable

**Recommended MCP Servers** (not bundled - install separately if not already configured):
```bash
# Context7 - Official library documentation
claude mcp add context7 -- npx -y @upstash/context7-mcp@latest

# Fetch - Web content fetching (optional)
claude mcp add fetch -- uvx mcp-server-fetch
```

**Two commands available:**
- `/research <topic>` - Comprehensive research including community sources
- `/official-docs <topic>` - Pre-task documentation from official sources only

### Official Docs Agent (`/official-docs`)
- **Purpose**: Quick pre-task lookup of official documentation
- **Strict sources only**: Context7, official docs sites (*.dev, docs.*), official GitHub repos
- **Never uses**: Stack Overflow, Medium, Dev.to, blogs, tutorials, forums
- **Honest reporting**: Explicitly states what couldn't be found
- **Output format**: Reference summary (overview, quick start, key APIs, example, sources)

## Key Patterns

### Codebase Health Workflow
`/deep-audit` is an orchestrator command (not a single agent). It inspects the project, decides which specialists apply, launches them via `Agent`, and aggregates their findings into `code-audit-[timestamp].md`.

Specialists (peers; the command is the conductor):
- `security-auditor` — secrets, injection, XSS, weak crypto, CVEs
- `performance-analyzer` — algorithms, N+1, async/memory, bundle bloat
- `library-modernizer` — custom code → mature library, deprecated APIs, `@types/*` duplication (uses Context7)
- `code-quality-reviewer` — smells, complexity, duplication, weak error handling
- `dead-code-cleanup` — reused in detect-only mode (knip/deadcode + verification)

`major-upgrade-analyzer` is a peer specialist too, but it belongs to `/update-deps`, not `/deep-audit`.

Parallel by default (it's a batch report — no reason to wait). Pass `sequential` in `$ARGUMENTS` to fall back to one-at-a-time execution.

Each specialist's `description` says "Used by the deep-audit orchestrator. Do not invoke directly." so they don't auto-trigger in normal conversations. `major-upgrade-analyzer` uses the same pattern, naming the update-deps orchestrator.

### Dependency Updates
`/update-deps` is an orchestrator skill for **JavaScript/TypeScript only** (npm, pnpm, yarn classic and berry). Two passes:

1. Each pending major is analyzed by a parallel `major-upgrade-analyzer` subagent, which returns `safe` / `safe-with-edits` / `wait` for *that package against this codebase*.
2. Coupled families (exact mutual peer pins, e.g. `vitest` + `@vitest/coverage-v8` + `@vitest/browser-playwright`) are collapsed into one group before the plan is built, and the group verdict is re-derived with the mutual-pin gate discounted — otherwise a locked family reports as N separate hold-backs that all say "can't move alone."
3. In-range minor/patch updates via the detected manager's bulk command.

The outdated snapshot is taken **before** anything is written, so the plan and the report can name exact `from → to` versions; both passes then go behind a single approval gate.

One `AskUserQuestion` approval gate before anything is written; then apply, run `typecheck`/`build`/`test`, and **report failures without reverting** (the skill never commits and never rolls back — the user owns the dirty tree).

`scripts/dep-outdated.sh` normalizes package-manager differences into one JSON shape. Two fields carry the decision and **they are independent, not a partition**:
- `upgrade` — gap from installed to `latest` (`major` when the major differs, *or* when the major is 0 and the minor differs, since 0.x minors are breaking)
- `inRangeUpdate` — whether the declared range already permits a move

A package can be both, so `counts.inRangeUpdate + counts.major != counts.total`.

Package-manager quirks the script absorbs:
- **yarn** (classic and berry) — `yarn outdated` emits NDJSON on classic and doesn't exist on berry, so the script runs read-only `npm outdated --json` against the installed `node_modules` tree and reports `outdatedSource: "npm-fallback"`.
- **yarn berry** — `updateCommand` is `null` because `yarn up '*'` resolves to latest and crosses majors. Use `updateCommandTemplate` (`yarn up '{name}@{range}'`) per package instead.
- Consumers should use `updateCommand` / `updateCommandTemplate` / `majorInstallTemplate` from the script rather than hardcoding a manager's syntax.

Monorepos are handled, not skipped. `npm outdated` at a workspace root reports the union across every workspace and names the owner in `dependent`, so the script reads every workspace manifest and resolves each finding back to the package that declared it. Each finding carries `dependents[]` (workspace + that workspace's range + section); `type` is the strictest section across consumers and `range` is null when workspaces disagree.

Two traps this closes, both of which shipped as bugs before a real monorepo caught them:
- Reading only the root manifest reports a workspace devDependency as a prod dependency.
- A bare `npm install <pkg>@<ver>` at a workspace root adds the package to the **root** manifest as a new `dependencies` entry and leaves the owning workspace untouched. Use `workspaceFlagTemplate` (npm `-w {workspace}`, pnpm `--filter {workspace}`, yarn berry the `prefix:yarn workspace {workspace}` command prefix).

### Dead Code Detection
- Uses `scripts/dead-code-detect.sh` helper for auto-detection
- **JavaScript/TypeScript**: Uses knip (`npx knip --reporter json`)
- **Python**: Uses deadcode (`deadcode .`)
- **Critical**: Always verify tool findings before reporting (filter false positives)
- Invocation: `"${CLAUDE_PLUGIN_ROOT}"/scripts/dead-code-detect.sh --format json`

**False Positive Verification:**
Before reporting dead code findings, check for:
- Dynamic imports (`import(variable)`, `require(variable)`)
- Framework patterns (React components, decorators)
- Re-exports for public API in index files
- Entry points (CLI scripts, serverless handlers)

### Output Formatting
- Use `file_path:line_number` format for code references
- Structure reports with priority levels: Critical > High > Medium > Low
- Include before/after code examples for fixes

## Plugin Variables

Use `${CLAUDE_PLUGIN_ROOT}` to reference paths within this plugin directory (e.g., for script invocations). Within a skill, reference its bundled files (e.g. `references/*.md`) via `${CLAUDE_SKILL_DIR}` instead.