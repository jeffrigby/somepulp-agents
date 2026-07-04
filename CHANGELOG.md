# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [3.2.0] - 2026-07-04

### Added
- **Marketplace**: Replaced the dead `$schema` URL in `marketplace.json` with the SchemaStore marketplace schema, and added a top-level `renames` map recording the plugin lineage (`code-auditor` → `codebase-health`, `codex-consultant`/`gemini-consultant` → `second-opinion`, `second-opinion` → retired).
- **All plugins**: Added `$schema` (SchemaStore plugin-manifest schema) as the first key in each `plugin.json`.
- **codebase-health 2.2.0**: `disable-model-invocation: true` on `/deep-audit` and `/update-docs` so these resource-intensive commands only run when the user invokes them.
- **research-assistant 1.4.0**: `/research` and `/official-docs` now declare `context: fork` and `agent:` in frontmatter, running directly as their agents in a forked context; command bodies reworded from "Use the X agent to…" to direct instructions.

### Changed
- **All plugins**: Trimmed `plugin.json` manifests to metadata only — removed the explicit `agents`, `commands`, and `skills` arrays so default directory auto-discovery applies.
- **codebase-health 2.2.0**: `/deep-audit` hardening — replaced bare `Bash` in `allowed-tools` with five scoped pre-approvals (dead-code-detect.sh, `npx knip`, `npm run lint`, `npm run typecheck`, `deadcode`), renamed the `Task` tool to `Agent` throughout (v2.1.63 rename; `Task` remains an alias), and rewrote the Stop hook prompt with a `stop_hook_active` loop guard and an explicit `{"ok": true}` / `{"ok": false, "reason": …}` response contract.
- **codebase-health 2.2.0**: Reworked `dead-code-cleanup` and `update-docs` agents for subagent reality — `AskUserQuestion` removed from their tools lists (unavailable inside subagents). Agents now return a verified findings report plus a plan (cleanup groups by confidence; file-by-file doc updates with before/after snippets) and hand off to the main conversation, where `/dead-code` and `/update-docs` gather user approval via `AskUserQuestion` before applying changes. Interactive "Would you like to…" error prompts replaced with fallback-and-report behavior.
- **codebase-health 2.2.0**: Skills modernized — `references/` paths in both SKILL.md files now use `${CLAUDE_SKILL_DIR}/`, frontmatter descriptions rewritten as one-line capability statements with trigger phrases moved to a new `when_to_use` field, and `docs-maintenance` gains `Edit`/`Write` in `allowed-tools`.
- **codebase-health 2.2.0**: `dead-code-detect.sh` mixed-project detection with `--format json` now emits a single JSON envelope (`{"nodejs": <knip JSON>, "python": "<deadcode text>"}`) instead of interleaved output, with graceful fallbacks for invalid/empty knip output and for systems without `jq` (deadcode text routed to stderr). Documented script invocations now quote the expansion: `"${CLAUDE_PLUGIN_ROOT}"/scripts/dead-code-detect.sh`.
- **CLAUDE.md**: Updated repo conventions to match — `Agent` tool rename, `AskUserQuestion` unavailable in subagents, metadata-only manifests with auto-discovery, `when_to_use` skill field, `${CLAUDE_SKILL_DIR}` for skill-bundled files, and the optional command frontmatter used in this repo (`disable-model-invocation`, `context: fork` + `agent:`).

## [3.1.3] - 2026-06-10

### Fixed
- **codebase-health 2.1.3**: Scoped the audit-report Stop hook to `/deep-audit` runs only — it was firing on every turn-end in every session.
  - The v3.1.2 hooks.json repair activated a plugin-level Stop hook that had silently never loaded (broken since its introduction in v2.2.0). Once loaded, it evaluated "was an audit report created?" at the end of every conversation turn, constantly nagging in sessions where no audit ever ran.
  - The hook now lives in the `/deep-audit` command's frontmatter (`hooks:` field), which scopes it to the skill's lifecycle per the official hooks spec — active only while the command runs, cleaned up when it finishes.
  - Removed the plugin-level `hooks/hooks.json` and the `hooks` entry from `plugin.json`; the prompt now also states the approve path explicitly so it cannot re-block in a loop.

## [3.1.2] - 2026-06-10

### Fixed
- **codebase-health 2.1.2**: Fixed two plugin manifest bugs that made `/doctor` report "skills load failed" and "Hook load failed".
  - `plugin.json` `skills` entries now point at the skill directories (`./skills/code-auditing`, `./skills/docs-maintenance`) instead of the `SKILL.md` files inside them.
  - `hooks/hooks.json` events are now nested under the required top-level `"hooks"` key (the `Stop` event was previously at the root, failing validation).
- **README**: Documented the optional AWS Documentation MCP server — the `research-assistant` agent already listed its tools, but the README's MCP requirements only mentioned Context7 and Fetch.

### Added
- **All plugins**: Added `displayName` ("Codebase Health", "Research Assistant") to plugin manifests and marketplace entries for friendlier display in the `/plugin` picker (Claude Code v2.1.143+; older versions fall back to `name`).

### Changed
- Bumped `research-assistant` to 1.3.2 to deliver the manifest metadata to installed users.

## [3.1.1] - 2026-05-02

### Fixed
- **codebase-health 2.1.1**: Hardened `/deep-audit` orchestrator boundary (follow-up to PR #8 review).
  - Orchestrator now verifies each specialist's return value against the expected `## <Name> Findings` heading and severity sections (`### Critical` / `### High` / `### Medium`) before pasting it into the report. Empty, missing-heading, or malformed results are recorded under a new `Specialists that failed:` line in the Notes section instead of being silently dropped — a launched specialist is never omitted from the final report.
  - The dead-code skip note is now mandatory: when `dead` is requested (or selected via `all`) but no dependency manifest exists, the Notes section must include an explicit `Dead code: skipped — no manifest` line, regardless of whether other specialists ran.
  - Added a `### Notes` section to `library-modernizer` and `code-quality-reviewer` output templates so per-specialist skip-notes (e.g., Context7 unavailable, no CLAUDE.md to read conventions from) survive aggregation — closing a parity gap with `security-auditor` and `performance-analyzer`.

## [3.1.0] - 2026-05-02

### Changed
- **codebase-health 2.1.0**: Refactored `/deep-audit` from a single 360-line monolithic agent into an orchestrator-of-specialists pattern, mirroring the official `pr-review-toolkit` plugin.
  - The `/deep-audit` command is now the orchestrator: it inspects the project, decides which specialists apply, launches them via `Task` (parallel by default; opt-in `sequential`), and aggregates findings into `code-audit-[timestamp].md`.
  - Concerns split across four new specialist agents — `security-auditor`, `performance-analyzer`, `library-modernizer`, `code-quality-reviewer` — and the existing `dead-code-cleanup` is reused in detect-only mode.
  - Specialists return structured findings blocks (Critical/High/Medium severity, confidence ≥ 80, file:line refs); the orchestrator owns the final report.
  - Each specialist's description says "Used by the deep-audit orchestrator. Do not invoke directly." to prevent auto-triggering in normal conversations.
  - `$ARGUMENTS` now supports per-aspect scoping (`security`, `perf`, `deps`, `quality`, `dead`, `all`) plus an optional `sequential` token to opt out of parallel execution.

### Removed
- **codebase-health**: Removed the monolithic `deep-audit` agent (replaced by the orchestrator command + specialists).

## [3.0.1] - 2026-05-02

### Fixed
- **All agents**: Moved `<example>` blocks out of YAML `description:` field into the markdown body. Previously the multi-line examples were being parsed as a single oversized `description` scalar, getting truncated at the 1,536-char auto-routing cap and defeating the purpose of the examples.
- **Skills**: Added `allowed-tools` frontmatter to `code-auditing` and `docs-maintenance` (was missing from current files; documented as required in CLAUDE.md template and matches v1.0.1 state).
- **Skills**: Removed non-spec `version` field from `code-auditing` and `docs-maintenance` SKILL.md frontmatter (skill version is implied by plugin version).
- **CLAUDE.md**: Removed stale references to retired second-opinion plugin (Codex/Gemini); marketplace was retitled in v3.0.0 but project description was not updated.
- **CLAUDE.md**: Updated agent frontmatter template to match the JSON-array `tools:` format actually used in the codebase, and added `model: inherit` / `color:` keys plus a note that examples belong in the body, not the description.
- **README.md**: Annotated `.mcp.json` in the plugin structure example to clarify it's optional and not bundled in this marketplace; added `hooks/hooks.json` to the example.

### Changed
- Bumped `codebase-health` to 2.0.1 and `research-assistant` to 1.3.1 to deliver the modernization fixes to installed users.

## [3.0.0] - 2026-05-02

### Removed
- **BREAKING**: Removed `second-opinion` plugin (Codex + Gemini consultants)
  - Codex Claude Code plugin now provides built-in second-opinion functionality
  - Gemini consultation was rarely used in this configuration
  - Users wanting external AI consultations should install the Codex plugin directly

## [2.2.0] - 2026-01-19

### Added
- **All plugins**: Added `homepage` and `repository` fields to plugin.json
- **codebase-health**: Added `skills` field to agents for automatic skill loading
  - `deep-audit`, `dead-code-cleanup` now load `code-auditing` skill
  - `update-docs` now loads `docs-maintenance` skill
- **second-opinion**: Added `skills` field to agents
  - `codex-consultant` and `gemini-consultant` now load `ai-consultation` skill
- **research-assistant**: Added `disallowedTools: Write, Edit` to agents for read-only safety
- **codebase-health**: Added prompt-based Stop hook for audit report verification
- **second-opinion**: Added prompt-based PreToolUse hook for Bash sandbox safety

### Changed
- **research-assistant**: Removed bundled MCP servers (Context7, Fetch)
  - MCP servers are commonly installed by users separately
  - Plugin now falls back to WebSearch/WebFetch when MCP unavailable
  - Added installation nudges when MCP tools are missing
  - Updated plugin description to note MCP dependencies

### Removed
- **research-assistant**: Removed `.mcp.json` (Context7 and Fetch no longer bundled)

## [2.1.0] - 2025-12-17

### Changed
- **BREAKING**: Consolidated `codex-consultant` and `gemini-consultant` into single `second-opinion` plugin
  - Old: `/plugin install codex-consultant@somepulp-agents` + `/plugin install gemini-consultant@somepulp-agents`
  - New: `/plugin install second-opinion@somepulp-agents`
  - Commands remain the same: `/codex-opinion` and `/gemini-opinion`
  - Agents remain the same: `codex-consultant` and `gemini-consultant`
  - Shared `ai-consultation` skill with unified reference documentation

### Removed
- `codex-consultant` plugin (merged into `second-opinion`)
- `gemini-consultant` plugin (merged into `second-opinion`)

## [2.0.0] - 2025-12-15

### Changed
- **BREAKING**: Renamed `code-auditor` plugin to `codebase-health`
  - Better reflects expanded scope: code auditing + documentation maintenance
  - Update install commands: `/plugin install codebase-health@somepulp-agents`
  - Commands now prefixed with `codebase-health:` instead of `code-auditor:`

### Added
- **codebase-health**: New documentation maintenance feature
  - New `/update-docs` command for syncing documentation with code changes
  - New `update-docs` agent for interactive documentation updates
  - New `docs-maintenance` skill with 7-phase methodology
  - Reference docs: `claude-md-guide.md`, `changelog-patterns.md`, `doc-sync-methodology.md`
  - Git history analysis to find undocumented changes
  - CLAUDE.md optimization for AI agent effectiveness
  - Cross-document consistency verification
  - Support for CLAUDE.md, README, CHANGELOG, and /docs directories

## [1.3.0] - 2025-12-09

### Added
- **research-assistant**: New `/official-docs` command and agent
  - Focused pre-task documentation fetching from official sources only
  - Strict source hierarchy: Context7 → Official sites → Official GitHub repos
  - Honest "not found" reporting when official docs don't exist
  - Reference summary output format (overview, quick start, key APIs, examples)
  - Never uses blogs, Stack Overflow, tutorials, or community content
  - Complements `/research` for quick authoritative lookups before coding

## [1.2.0] - 2025-12-09

### Added
- **code-auditor v2.1.0**: Dead code detection with knip/deadcode integration
  - New `/dead-code` command for standalone dead code detection and cleanup
  - New `dead-code-cleanup` agent for interactive guided removal
  - New `scripts/dead-code-detect.sh` helper for auto-detection of project type
  - New `references/dead-code-methodology.md` documentation
  - Integration of knip for JavaScript/TypeScript projects
  - Integration of deadcode for Python projects
  - False positive verification before reporting findings
  - Guided cleanup workflow with user approval before removal

### Changed
- **code-auditor**: Added Phase 2.5 (Dead Code Detection) to deep-audit workflow
- **code-auditor**: Added `AskUserQuestion` tool for cleanup approval workflow
- **code-auditor**: Added Dead Code section to SKILL.md analysis categories

## [1.1.0] - 2025-12-09

### Added
- **research-assistant**: Bundled MCP servers (Context7, Fetch) via `.mcp.json`
  - Users no longer need to install these MCP servers separately
  - Servers start automatically when plugin is enabled
  - Requires Claude Code restart after enabling plugin

## [1.0.2] - 2025-11-29

### Fixed
- **gemini-review.sh**: Corrected installation instructions (was incorrectly referencing `@anthropic-ai/gemini`)
- **audit-methodology.md**: Fixed MCP tool casing (`mcp__Context7__*` → `mcp__context7__*`)
- **CLAUDE.md**: Clarified Task tool documentation (available to main Claude, not agents/skills)
- **CHANGELOG.md**: Fixed version 1.0.0 date typo (2024 → 2025)

### Added
- **plugin.json**: Added explicit `skills` field for better discoverability
- **All agents**: Added `examples` frontmatter field for better invocation matching
- **All commands**: Added structured `arguments` definitions
- **code-auditor.md**: Added MCP tool fallback documentation
- **research-assistant.md**: Added MCP tool fallback documentation
- **Skills**: Enhanced descriptions with trigger phrases for better discovery

### Changed
- **code-quality-auditor.md**: Restructured description (moved examples to dedicated field)

## [1.0.1] - 2025-11-29

### Fixed
- **code-auditor.md**: Fixed MCP tool naming (lowercase `mcp__context7__*`)
- **code-auditor.md**: Removed invalid tools (`Task`, `LS`)
- **code-quality-auditor.md**: Added missing `tools:` frontmatter field
- **code-quality-auditor.md**: Removed `model: sonnet` to inherit user's model
- **README.md**: Fixed repository URL (`jeffrigby/somepulp-agents`)

### Added
- **Slash Commands**: New `commands/` directory with quick-access commands
  - `/audit` - Run comprehensive code audit
  - `/research` - Research libraries and technical topics
  - `/second-opinion` - Get second opinion from Codex or Gemini
- **plugin.json**: Added `agents`, `commands`, `repository`, `homepage` fields
- **Skills**: Added `allowed-tools` field to both SKILL.md files
- **CLAUDE.md**: Added tool naming conventions section

### Changed
- Updated plugin manifest to full Claude Code schema compliance
- Agents now inherit user's model (removed explicit model overrides)

## [1.0.0] - 2025-11-29

### Added

#### Agents
- **code-auditor**: Comprehensive code quality audit tool with 6-phase analysis
  - Dead code detection
  - Security vulnerability scanning
  - Performance issue identification
  - Library recommendations with Context7 integration
  - Detailed markdown report generation

- **code-quality-auditor**: Fast post-implementation quality checks
  - Optimized for recently modified files
  - DRY violation detection
  - Security concern identification
  - Uses sonnet model for efficiency

- **research-assistant**: Library and API research agent
  - Context7 integration for official documentation
  - GitHub CLI for code examples
  - Web search for additional context

- **codex-consultant**: OpenAI Codex CLI integration
  - Second opinion consultations
  - Read-only/sandbox mode for safety
  - Helper script with CLI detection

- **gemini-consultant**: Google Gemini CLI integration
  - Second opinion consultations
  - Sandbox mode for safety
  - Helper script with CLI detection

#### Skills
- **ai-consultation**: AI consultation workflow guidance
  - Prompt templates for all consultation types
  - 12 concrete examples with workflows
  - Decision tree for choosing consultation approach
  - Quality checklist for thorough consultations
  - CLI options reference

- **code-auditing**: Code auditing methodology
  - Complete 6-phase audit process
  - Issue priority classification
  - Analysis category checklists
  - Report format guidelines

#### Scripts
- **codex-review.sh**: Helper script for Codex consultations
  - Enhanced CLI detection with helpful error messages
  - Colored output for better readability
  - Always read-only mode

- **gemini-review.sh**: Helper script for Gemini consultations
  - Enhanced CLI detection with helpful error messages
  - Colored output for better readability
  - Always sandbox mode

#### Documentation
- Comprehensive README with usage examples
- MIT License
- Codex setup guide
- Gemini setup guide

### Technical Notes
- Plugin uses `${CLAUDE_PLUGIN_ROOT}` for portable path references
- All external AI consultations operate in read-only/sandbox mode
- Skills organized with SKILL.md frontmatter and references directories