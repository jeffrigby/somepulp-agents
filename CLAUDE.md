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
- **`.claude-plugin/plugin.json`** - Plugin manifest (metadata only; agents/commands/skills are auto-discovered from their default directories, not enumerated in the manifest)
- **`agents/`** - Markdown agents with YAML frontmatter
- **`commands/`** - Slash command definitions
- **`skills/`** - Skills with reference documentation
- **`scripts/`** - Helper shell scripts (optional)

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

**Important**: Keep `description` to a single line. Multi-line content (especially `<example>` blocks) belongs in the body, not the frontmatter — descriptions are truncated at 1,536 characters for auto-routing decisions, so embedded examples get cut off.

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

### Command Files (`commands/*.md`)
```yaml
---
description: Brief description of what the command does
---

Command prompt content...
$ARGUMENTS
```

Optional frontmatter used in this repo:
- `disable-model-invocation: true` - user-invoked only, never auto-triggered (set on `/deep-audit` and `/update-docs`)
- `context: fork` + `agent: <agent-name>` - run the command in a forked context as the named agent (used by the research-assistant commands)

## Tool Naming Conventions

### MCP Tools
MCP tool names must be **lowercase**. Examples:
- `mcp__context7__resolve-library-id` (correct)
- `mcp__context7__query-docs` (correct)
- `mcp__fetch__fetch` (correct)
- ~~`mcp__Context7__resolve-library-id`~~ (incorrect - wrong casing)

### Valid Claude Code Tools
Standard tools: `Read`, `Write`, `Edit`, `Grep`, `Glob`, `Bash`, `WebSearch`, `WebFetch`, `TodoWrite`, `AskUserQuestion`

**Tools unavailable in subagent context** (cannot be used in agent/skill tool lists):
- `Agent` (renamed from `Task` in Claude Code v2.1.63; `Task` remains an alias) - Used by main Claude to spawn subagents; subagents cannot spawn other subagents
- `AskUserQuestion` - Unavailable inside subagents even when listed in `tools`
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

Parallel by default (it's a batch report — no reason to wait). Pass `sequential` in `$ARGUMENTS` to fall back to one-at-a-time execution.

Each specialist's `description` says "Used by the deep-audit orchestrator. Do not invoke directly." so they don't auto-trigger in normal conversations.

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