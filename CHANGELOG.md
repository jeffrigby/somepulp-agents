# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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