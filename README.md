# Somepulp Agents

A plugin marketplace for [Claude Code](https://docs.anthropic.com/claude-code) providing specialized agents for code auditing, research, and multi-model consultation.

## What Are These Plugins?

Claude Code plugins extend functionality through custom slash commands, specialized agents, and skills. Each plugin in this marketplace can be installed independently, letting you pick the tools that fit your workflow.

## Available Plugins

| Plugin | Description | Contents |
|--------|-------------|----------|
| [codebase-health](./plugins/codebase-health/) | Comprehensive codebase health tools: code audits, dead code detection, and documentation maintenance | **Commands:** `/deep-audit`, `/quick-check`, `/dead-code`, `/update-docs`<br>**Agents:** `deep-audit`, `quick-check`, `dead-code-cleanup`, `update-docs`<br>**Skills:** `code-auditing`, `docs-maintenance` |
| [codex-consultant](./plugins/codex-consultant/) | Get second opinions from OpenAI Codex CLI | **Command:** `/codex-opinion`<br>**Agent:** `codex-consultant`<br>**Skill:** `ai-consultation` |
| [gemini-consultant](./plugins/gemini-consultant/) | Get second opinions from Google Gemini CLI | **Command:** `/gemini-opinion`<br>**Agent:** `gemini-consultant`<br>**Skill:** `ai-consultation` |
| [research-assistant](./plugins/research-assistant/) | Research libraries and APIs using official documentation | **Commands:** `/research`, `/official-docs`<br>**Agents:** `research-assistant`, `official-docs`<br>**MCP:** Context7, Fetch |

## Installation

### From GitHub

1. Add the marketplace to Claude Code:
   ```
   /plugin marketplace add jeffrigby/somepulp-agents
   ```

2. Install the plugins you want:
   ```
   /plugin install codebase-health@somepulp-agents
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
/plugin install codebase-health@somepulp-agents
```

## Requirements

| Plugin | Requirements |
|--------|--------------|
| **research-assistant** | Bundled MCP servers start automatically. **Requires Claude Code restart** after enabling. |
| **codex-consultant** | [OpenAI Codex CLI](https://github.com/openai/codex) + `OPENAI_API_KEY` environment variable |
| **gemini-consultant** | [Google Gemini CLI](https://github.com/google-gemini/gemini-cli) with authentication configured |

## Plugin Structure

Each plugin follows the standard Claude Code plugin structure:

```
plugin-name/
├── .claude-plugin/
│   └── plugin.json          # Plugin metadata
├── commands/                # Slash commands (optional)
├── agents/                  # Specialized agents (optional)
├── skills/                  # Agent skills (optional)
├── scripts/                 # Helper scripts (optional)
├── .mcp.json                # MCP server configuration (optional)
└── README.md                # Plugin documentation
```

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

MIT License - see [LICENSE](LICENSE) for details.

## Learn More

- [Claude Code Documentation](https://docs.anthropic.com/claude-code)
- [Plugin System Documentation](https://docs.anthropic.com/en/docs/claude-code/plugins)
