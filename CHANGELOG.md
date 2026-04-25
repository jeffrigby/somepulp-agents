# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [3.1.0] - 2026-04-25

### Changed
- **codebase-health 2.1.0**: Refactored `/deep-audit` from a single 360-line monolithic agent into an orchestrator-of-specialists pattern, mirroring the official `pr-review-toolkit` plugin.
  - The `/deep-audit` command is now the orchestrator: it inspects the project, decides which specialists apply, launches them via `Task` (sequential by default; opt-in `parallel`), and aggregates findings into `code-audit-[timestamp].md`.
  - Concerns split across four new specialist agents — `security-auditor`, `performance-analyzer`, `library-modernizer`, `code-quality-reviewer` — and the existing `dead-code-cleanup` is reused in detect-only mode.
  - Specialists return structured findings blocks (Critical/High/Medium severity, confidence ≥ 80, file:line refs); the orchestrator owns the final report.
  - Each specialist's description says "Used by the deep-audit orchestrator. Do not invoke directly." to prevent auto-triggering in normal conversations.
  - `$ARGUMENTS` now supports per-aspect scoping (`security`, `perf`, `deps`, `quality`, `dead`, `all`) plus an optional `parallel` token.

### Removed
- **codebase-health**: Removed the monolithic `deep-audit` agent (replaced by the orchestrator command + specialists).

## [3.0.1] - 2026-04-25

### Fixed
- **All agents**: Moved `<example>` blocks out of YAML `description:` field into the markdown body. Previously the multi-line examples were being parsed as a single oversized `description` scalar, getting truncated at the 1,536-char auto-routing cap and defeating the purpose of the examples.
- **Skills**: Added `allowed-tools` frontmatter to `code-auditing` and `docs-maintenance` (was missing from current files; documented as required in CLAUDE.md template and matches v1.0.1 state).
- **Skills**: Removed non-spec `version` field from `code-auditing` and `docs-maintenance` SKILL.md frontmatter (skill version is implied by plugin version).
- **CLAUDE.md**: Removed stale references to retired second-opinion plugin (Codex/Gemini); marketplace was retitled in v3.0.0 but project description was not updated.
- **CLAUDE.md**: Updated agent frontmatter template to match the JSON-array `tools:` format actually used in the codebase, and added `model: inherit` / `color:` keys plus a note that examples belong in the body, not the description.
- **README.md**: Annotated `.mcp.json` in the plugin structure example to clarify it's optional and not bundled in this marketplace; added `hooks/hooks.json` to the example.

### Changed
- Bumped `codebase-health` to 2.0.1 and `research-assistant` to 1.3.1 to deliver the modernization fixes to installed users.

## [3.0.0] - 2026-04-25

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