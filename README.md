# Somepulp Agents

A plugin marketplace for [Claude Code](https://docs.anthropic.com/claude-code) providing specialized agents for code auditing, documentation maintenance, and library/API research.

## What Are These Plugins?

Claude Code plugins extend functionality through custom slash commands, specialized agents, and skills. Each plugin in this marketplace can be installed independently, letting you pick the tools that fit your workflow.

## Available Plugins

| Plugin | Description | Contents |
|--------|-------------|----------|
| [codebase-health](./plugins/codebase-health/) | Codebase health tools: orchestrated deep audits, dead code detection, and documentation maintenance | **Commands:** `/deep-audit`, `/dead-code`, `/update-docs`<br>**Agents:** `security-auditor`, `performance-analyzer`, `library-modernizer`, `code-quality-reviewer`, `dead-code-cleanup`, `update-docs`<br>**Skills:** `code-auditing`, `docs-maintenance` |
| [research-assistant](./plugins/research-assistant/) | Research libraries and APIs using official documentation | **Commands:** `/research`, `/official-docs`<br>**Agents:** `research-assistant`, `official-docs`<br>**MCP:** Context7, Fetch, AWS Documentation (all optional) |

## Installation

### From GitHub

1. Add the marketplace to Claude Code:
   ```
   /plugin marketplace add jeffrigby/somepulp-agents
   ```

2. Install the plugins you want:
   ```
   /plugin install codebase-health@somepulp-agents
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
| **research-assistant** | Recommended: [Context7](https://github.com/upstash/context7) and [Fetch](https://github.com/modelcontextprotocol/servers/tree/main/src/fetch) MCP servers (install separately). Optional: [AWS Documentation](https://github.com/awslabs/mcp/tree/main/src/aws-documentation-mcp-server) MCP server for AWS docs research. Falls back to WebSearch/WebFetch if unavailable. |

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
├── hooks/hooks.json         # Lifecycle hooks (optional)
└── .mcp.json                # MCP server configuration (optional, not bundled here)
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
