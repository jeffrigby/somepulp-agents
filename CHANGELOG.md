# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-11-29

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