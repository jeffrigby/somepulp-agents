# somepulp-agents

AI-powered developer assistants for code auditing, research, and multi-model consultation. A Claude Code plugin providing specialized agents and skills for comprehensive code analysis.

## Features

### Agents

| Agent | Description |
|-------|-------------|
| **code-auditor** | Comprehensive code quality audits with dead code detection, security analysis, and library recommendations |
| **code-quality-auditor** | Fast post-implementation quality checks for recently modified files |
| **research-assistant** | Research libraries, frameworks, and APIs using official documentation |
| **codex-consultant** | Get second opinions from OpenAI Codex CLI on code reviews and architecture |
| **gemini-consultant** | Get second opinions from Google Gemini CLI on code reviews and architecture |

### Skills

| Skill | Description |
|-------|-------------|
| **ai-consultation** | Guidance on AI consultation workflows, prompt templates, and best practices |
| **code-auditing** | Comprehensive code auditing methodology and checklists |

## Installation

### From GitHub (recommended)

1. Add the marketplace to Claude Code:
   ```
   /plugin marketplace add jeffrigby/somepulp-agents
   ```

2. Install the plugin:
   ```
   /plugin install somepulp-agents@somepulp-agents
   ```

Or use the interactive `/plugin` command to browse and install.

### Manual Installation (for development)

```bash
# Clone the repository
git clone https://github.com/jeffrigby/somepulp-agents.git

# In Claude Code, add as local marketplace
/plugin marketplace add /path/to/somepulp-agents

# Then install
/plugin install somepulp-agents@somepulp-agents
```

## Requirements

### For Codex Consultant

The codex-consultant agent requires [OpenAI Codex CLI](https://github.com/openai/codex).

### For Gemini Consultant

The gemini-consultant agent requires [Google Gemini CLI](https://github.com/google-gemini/gemini-cli).

## Usage

### Code Auditing

```
Use the code-auditor agent to perform a comprehensive code audit
```

The code-auditor will:
- Analyze all code files for issues
- Check for dead code and unused dependencies
- Identify security vulnerabilities
- Recommend mature libraries for custom implementations
- Generate a detailed report with prioritized findings

### Multi-Model Consultation

Get a second opinion from Codex or Gemini:

```
Ask codex for a security review of src/auth.js
```

```
Get gemini's opinion on our API architecture
```

### Research

```
Research the best practices for React hooks
```

### Slash Commands

Quick access via slash commands:

```
/audit                    # Run comprehensive code audit
/research <topic>         # Research a library or technical topic
/second-opinion <request> # Get second opinion from Codex or Gemini
```

## Agent Details

### code-auditor

**Trigger:** User explicitly requests a code audit

Performs a 6-phase comprehensive analysis:
1. Pre-Analysis Setup - Identify tech stack and run baseline linting
2. Discovery - Find all code files and group by module
3. File-by-File Analysis - Check each file for issues
4. Best Practices Verification - Cross-reference with official documentation
5. Library Recommendations - Find mature replacements for custom code
6. Report Generation - Create prioritized action plan

### code-quality-auditor

**Trigger:** After completing feature implementations or before PRs

Fast quality checks for:
- Dead code identification
- DRY violations
- Security concerns
- Linting errors

### research-assistant

**Trigger:** User asks to research libraries or APIs

Uses:
- Context7 for official documentation
- GitHub CLI for code examples
- Web search for additional context

### codex-consultant / gemini-consultant

**Trigger:** User requests a "second opinion" or asks "what would codex/gemini think"

Consultation types:
- Code review
- Security audit
- Architecture review
- Debugging analysis
- Performance review

Always operates in read-only/sandbox mode for safety.

## Skills Reference

### ai-consultation

Provides:
- Prompt templates for different consultation types
- Decision tree for choosing consultation approach
- Quality checklist for thorough consultations
- CLI options reference

### code-auditing

Provides:
- 6-phase audit methodology
- Issue priority classification
- Analysis categories (security, performance, TypeScript)
- Report format guidelines

## Project Structure

```
somepulp-agents/
├── .claude-plugin/
│   └── plugin.json          # Plugin manifest
├── agents/
│   ├── code-auditor.md
│   ├── code-quality-auditor.md
│   ├── codex-consultant.md
│   ├── gemini-consultant.md
│   └── research-assistant.md
├── commands/
│   ├── audit.md             # /audit slash command
│   ├── research.md          # /research slash command
│   └── second-opinion.md    # /second-opinion slash command
├── skills/
│   ├── ai-consultation/
│   │   ├── SKILL.md
│   │   └── references/
│   │       ├── prompt-templates.md
│   │       ├── examples.md
│   │       ├── decision-tree.md
│   │       ├── consultation-checklist.md
│   │       └── codex-options.md
│   └── code-auditing/
│       ├── SKILL.md
│       └── references/
│           └── audit-methodology.md
├── scripts/
│   ├── codex-review.sh      # Helper for Codex consultations
│   └── gemini-review.sh     # Helper for Gemini consultations
├── README.md
├── LICENSE
└── CHANGELOG.md
```

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

MIT License - see [LICENSE](LICENSE) for details.

## Author

Some Pulp LLC

## Links

- [Claude Code Documentation](https://docs.anthropic.com/claude-code)
- [OpenAI Codex CLI](https://github.com/openai/codex)
- [Google Gemini CLI](https://github.com/google-gemini/gemini-cli)