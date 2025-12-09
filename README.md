# somepulp-agents

AI-powered developer assistants for code auditing, research, and multi-model consultation. A Claude Code plugin marketplace providing specialized agents that can be installed individually.

## Available Plugins

| Plugin | Description | Commands |
|--------|-------------|----------|
| **code-auditor** | Comprehensive code quality audits with dead code detection, security analysis, and library recommendations | `/deep-audit`, `/quick-check`, `/dead-code` |
| **codex-consultant** | Get second opinions from OpenAI Codex CLI on code reviews and architecture | `/codex-opinion` |
| **gemini-consultant** | Get second opinions from Google Gemini CLI on code reviews and architecture | `/gemini-opinion` |
| **research-assistant** | Research libraries, frameworks, and APIs using official documentation | `/research`, `/official-docs` |

## Installation

### From GitHub

1. Add the marketplace to Claude Code:
   ```
   /plugin marketplace add jeffrigby/somepulp-agents
   ```

2. Install the plugins you want:
   ```
   /plugin install code-auditor@somepulp-agents
   /plugin install codex-consultant@somepulp-agents
   /plugin install gemini-consultant@somepulp-agents
   /plugin install research-assistant@somepulp-agents
   ```

Or use the interactive `/plugin` command to browse and install.

### Manual Installation (for development)

```bash
# Clone the repository
git clone https://github.com/jeffrigby/somepulp-agents.git

# In Claude Code, add as local marketplace
/plugin marketplace add /path/to/somepulp-agents

# Then install the plugins you want
/plugin install code-auditor@somepulp-agents
```

## Requirements

### For Research Assistant

The research-assistant plugin includes bundled MCP servers (Context7, Fetch) that start automatically. **Requires Claude Code restart after enabling the plugin** for MCP servers to initialize.

### For Codex Consultant

The codex-consultant plugin requires [OpenAI Codex CLI](https://github.com/openai/codex). See the official repo for installation instructions. Requires `OPENAI_API_KEY` environment variable.

### For Gemini Consultant

The gemini-consultant plugin requires [Google Gemini CLI](https://github.com/google-gemini/gemini-cli). See the official repo for installation and authentication instructions.

## Plugin Details

### code-auditor

**Trigger:** User explicitly requests a code audit or dead code cleanup

**Commands:**
- `/deep-audit` - Comprehensive 7-phase codebase audit
- `/quick-check` - Fast quality check on recent changes
- `/dead-code` - Detect and clean up unused code with guided removal

**Dead Code Detection (v2.1.0):**
- Integrates **knip** for JavaScript/TypeScript projects
- Integrates **deadcode** for Python projects
- Auto-detects project type
- Verifies findings to filter false positives before reporting
- Guided cleanup with user approval before removal

**Deep Audit Phases:**
1. Pre-Analysis Setup - Identify tech stack and run baseline linting
2. Discovery - Find all code files and group by module
3. File-by-File Analysis - Check each file for issues
4. **Dead Code Detection** - Run knip/deadcode with verification
5. Best Practices Verification - Cross-reference with official documentation
6. Library Recommendations - Find mature replacements for custom code
7. Report Generation - Create prioritized action plan

### research-assistant

**Trigger:** User asks to research libraries or APIs, or needs official documentation

**Commands:**
- `/research <topic>` - Comprehensive research including community sources
- `/official-docs <topic>` - Pre-task documentation from official sources only

**Bundled MCP Servers:** This plugin includes [Context7](https://github.com/upstash/context7) and [Fetch](https://github.com/modelcontextprotocol/servers/tree/main/src/fetch) MCP servers. They start automatically when the plugin is enabled (requires Claude Code restart).

Uses:
- Context7 MCP for official documentation (bundled)
- Fetch MCP for web content retrieval (bundled)
- GitHub CLI for code examples
- Web search for additional context

**Official Docs Agent (v1.3.0):**
- Strict source hierarchy: Context7 → Official sites → Official GitHub repos
- Never uses blogs, Stack Overflow, tutorials, or community content
- Honest "not found" reporting when official docs don't exist
- Reference summary output: overview, quick start, key APIs, examples, sources

### codex-consultant / gemini-consultant

**Trigger:** User requests a "second opinion" or asks "what would codex/gemini think"

Consultation types:
- Code review
- Security audit
- Architecture review
- Debugging analysis
- Performance review

Always operates in read-only/sandbox mode for safety.

## Project Structure

```
somepulp-agents/
├── .claude-plugin/
│   └── marketplace.json          # Marketplace manifest
├── plugins/
│   ├── code-auditor/             # v2.1.0
│   │   ├── .claude-plugin/
│   │   │   └── plugin.json
│   │   ├── agents/               # deep-audit, quick-check, dead-code-cleanup
│   │   ├── commands/             # /deep-audit, /quick-check, /dead-code
│   │   ├── scripts/              # dead-code-detect.sh
│   │   └── skills/               # code-auditing methodology
│   ├── codex-consultant/         # v1.0.2
│   │   ├── .claude-plugin/
│   │   │   └── plugin.json
│   │   ├── agents/               # codex-consultant
│   │   ├── commands/             # /codex-opinion
│   │   ├── scripts/              # codex-review.sh
│   │   └── skills/               # ai-consultation
│   ├── gemini-consultant/        # v1.0.2
│   │   ├── .claude-plugin/
│   │   │   └── plugin.json
│   │   ├── agents/               # gemini-consultant
│   │   ├── commands/             # /gemini-opinion
│   │   ├── scripts/              # gemini-review.sh
│   │   └── skills/               # ai-consultation
│   └── research-assistant/       # v1.3.0
│       ├── .claude-plugin/
│       │   └── plugin.json
│       ├── .mcp.json             # Bundled MCP servers (Context7, Fetch)
│       ├── agents/               # research-assistant, official-docs
│       └── commands/             # /research, /official-docs
├── README.md
├── LICENSE
├── CHANGELOG.md
└── CLAUDE.md                     # Development instructions
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
- [Context7 MCP](https://github.com/upstash/context7) - Official documentation lookup
- [Fetch MCP](https://github.com/modelcontextprotocol/servers/tree/main/src/fetch) - Web content retrieval
