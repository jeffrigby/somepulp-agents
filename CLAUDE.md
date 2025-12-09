# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Claude Code plugin called `somepulp-agents` that provides specialized AI agents and skills for code auditing, research, and multi-model consultation (Codex, Gemini).

## Repository Structure

- **`.claude-plugin/plugin.json`** - Plugin manifest defining name, version, and metadata
- **`agents/`** - Markdown-based agent definitions with YAML frontmatter for configuration
- **`commands/`** - Slash command definitions (`/audit`, `/research`, `/official-docs`, `/second-opinion`)
- **`skills/`** - Skill definitions with reference documentation in subdirectories
- **`scripts/`** - Helper shell scripts for external AI tool invocations

## Agent and Skill Format

### Agent Files (`agents/*.md`)
```yaml
---
name: agent-name
description: When this agent should be triggered
tools: Comma-separated list of tools the agent can use
---

System prompt content defining agent behavior...
```

### Skill Files (`skills/*/SKILL.md`)
```yaml
---
name: skill-name
description: When this skill should be invoked
allowed-tools: Read, Grep, Glob, Bash
---

Skill methodology and guidance...
```

Reference materials go in `skills/*/references/*.md`.

### Command Files (`commands/*.md`)
```yaml
---
description: Brief description of what the command does
---

Command prompt content...
$ARGUMENTS
```

## Tool Naming Conventions

### MCP Tools
MCP tool names must be **lowercase**. Examples:
- `mcp__context7__resolve-library-id` (correct)
- `mcp__context7__get-library-docs` (correct)
- `mcp__fetch__fetch` (correct)
- ~~`mcp__Context7__resolve-library-id`~~ (incorrect - wrong casing)

### Valid Claude Code Tools
Standard tools: `Read`, `Write`, `Edit`, `Grep`, `Glob`, `Bash`, `WebSearch`, `WebFetch`, `TodoWrite`, `AskUserQuestion`

**Tools unavailable in subagent context** (cannot be used in agent/skill tool lists):
- `Task` - Used by main Claude to spawn subagents; subagents cannot spawn other subagents
- `LS` - Not a standard Claude Code tool; use `Glob` for file discovery or `Bash` with `ls`

## External Tool Integration

### Codex Consultant
- Uses `scripts/codex-review.sh` helper
- Requires: `npm install -g @openai/codex` and `OPENAI_API_KEY`
- Always runs in read-only/sandbox mode
- Invocation: `${CLAUDE_PLUGIN_ROOT}/scripts/codex-review.sh "<prompt>"`

### Gemini Consultant
- Uses `scripts/gemini-review.sh` helper
- Requires: `gemini auth login`
- Always runs with `--yolo --sandbox` flags
- Invocation: `${CLAUDE_PLUGIN_ROOT}/scripts/gemini-review.sh "<prompt>"`

### Research Assistant
- **Bundles MCP servers** via `.mcp.json`: Context7 and Fetch
- MCP servers start automatically when plugin is enabled (requires Claude Code restart)
- Prioritizes Context7 MCP for official documentation
- Uses `gh` CLI for GitHub operations and code examples
- Falls back to WebSearch/WebFetch if MCP tools unavailable

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

### Safety-First Consultation
All external AI consultations (Codex, Gemini) operate in read-only/sandbox mode. Never allow file modifications from external tools.

### Code Auditor Workflow
The `code-auditor` agent follows a 7-phase process:
1. Pre-Analysis Setup (check configs, run existing linters)
2. Discovery (find all code files)
3. File-by-File Analysis
4. **Dead Code Detection** (knip/deadcode with verification)
5. Best Practices Verification (Context7 for official docs)
6. Library Recommendations
7. Report Generation (saves to `code-audit-[timestamp].md`)

### Dead Code Detection
- Uses `scripts/dead-code-detect.sh` helper for auto-detection
- **JavaScript/TypeScript**: Uses knip (`npx knip --reporter json`)
- **Python**: Uses deadcode (`deadcode .`)
- **Critical**: Always verify tool findings before reporting (filter false positives)
- Invocation: `${CLAUDE_PLUGIN_ROOT}/scripts/dead-code-detect.sh --format json`

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

Use `${CLAUDE_PLUGIN_ROOT}` to reference paths within this plugin directory (e.g., for script invocations or reading reference files).