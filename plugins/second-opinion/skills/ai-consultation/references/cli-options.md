# AI CLI Options Reference

This document provides detailed information about CLI options for the Codex and Gemini AI consultation tools. Both tools support similar patterns with tool-specific syntax variations noted throughout.

> **Note:** This plugin provides helper scripts (`scripts/codex-review.sh` and `scripts/gemini-review.sh`) that wrap the CLI tools with safety defaults. The scripts **always enforce sandbox (read-only) mode** and provide a simplified interface. Some options documented below are only available when using the CLI directly, not through the plugin wrapper.

## Plugin Wrapper vs Direct CLI

**Common features (both wrappers):**

| Feature | Plugin Wrapper | Direct CLI |
|---------|----------------|------------|
| Sandbox mode | Always enabled (enforced) | Manual flag required |
| Auto-approve | Always enabled | Manual flag required |

**Tool-specific options:**

| Feature | Codex Wrapper | Codex Direct | Gemini Wrapper | Gemini Direct |
|---------|---------------|--------------|----------------|---------------|
| Working directory | `-d path` | `-C path` | (uses current dir) | (uses current dir) |
| Include directories | N/A | `--add-dir path` | `-d path` (repeatable) | `--include-directories path` |
| Output format | `-o file` | `--output-last-message file` | `-o format` | `--output-format format` |
| Disable auto-approve | `-n` | (omit `-c` override) | N/A | (omit `--approval-mode`) |

> **Note:** The `-d` flag has different meanings: for Codex it sets the working directory, for Gemini it adds directories to include in context.

## Core Options

### --sandbox MODE (Codex) / --sandbox (Gemini)

Controls what modifications the AI can make to the workspace.

**Modes:**
- `read-only`: Safe mode for analysis and review (won't modify files)
  - Use for: Code reviews, architecture opinions, debugging analysis
  - Files can be read but not modified
  - Safe for production code review

- `workspace-write`: Allow file modifications (**Direct CLI only**)
  - Use for: Refactoring, implementation changes, fixes
  - AI can create, edit, and delete files
  - **Caution**: Only use with user confirmation
  - **Not available through plugin wrapper** - use CLI directly

**Examples:**
```bash
# Safe review (direct CLI — plugin wrapper handles this automatically)
codex exec --sandbox read-only -c 'ask_for_approval="on-request"' -C "$(pwd)" "Review security issues"

# Allow changes - DIRECT CLI ONLY (use carefully!)
# Note: The plugin wrapper always enforces read-only mode
codex exec --sandbox workspace-write --full-auto -C "$(pwd)" "Refactor error handling"
```

### Auto-Approval: Codex config override / Gemini --approval-mode

Run without user approval for each tool use.

**Benefits:**
- Faster responses
- No interruptions for approval
- Better for read-only reviews

**When to use:**
- Code reviews and analysis
- Architecture discussions
- Debugging consultations
- Any read-only consultation

**When NOT to use:**
- When making actual code changes
- In sensitive codebases where you want to approve each read

**Codex:**

> **Important:** Do NOT use `--full-auto` when you want read-only mode. `--full-auto` is a convenience alias that sets BOTH `--sandbox workspace-write` AND auto-approval, overriding any explicit `--sandbox read-only`. Instead, use `-c 'ask_for_approval="on-request"'` to enable auto-approval without changing the sandbox mode.

**Examples:**
```bash
# Direct CLI with auto-approval (read-only preserved)
codex exec --sandbox read-only -c 'ask_for_approval="on-request"' -C "$(pwd)" "Analyze performance bottlenecks"

# Direct CLI without auto-approval (manual approval required)
codex exec --sandbox read-only -C "$(pwd)" "Analyze performance bottlenecks"
```

**Gemini:**

> **Note:** `--yolo` / `-y` is deprecated. Use `--approval-mode=yolo` instead.

**Plugin wrapper:**
```bash
# Auto-approval enabled (default)
codex-review.sh "Analyze performance bottlenecks"

# Auto-approval disabled (manual approval)
codex-review.sh -n "Analyze performance bottlenecks"
```

### -C, --directory DIRECTORY (Codex)

Set the working directory for the session.

**Usage:**
```bash
# Use current directory
codex exec --sandbox read-only -C "$(pwd)" "Review code"

# Use specific directory
codex exec --sandbox read-only -C "/path/to/project" "Review code"

# Use environment variable
codex exec --sandbox read-only -C "$PROJECT_DIR" "Review code"
```

**Best practice:** Use `$(pwd)` for portability rather than hardcoded paths.

### -m, --model MODEL

Specify which model to use.

**Available models (varies by CLI):**
- Default model (usually sufficient)
- Higher-capability models for complex analysis

**When to specify:**
- Need higher reasoning capability
- Cost optimization
- Testing with specific model version

### --output-last-message FILE (Codex)

Capture the AI's final response to a file.

**Use cases:**
- Save review results for later reference
- Create documentation from analysis
- Process output with other tools
- Keep consultation history

**Example:**
```bash
codex exec --sandbox read-only \
  -C "$(pwd)" \
  --output-last-message /tmp/codex-review.txt \
  "Review index.js for security issues"

# Then read the results
cat /tmp/codex-review.txt
```

## Common Patterns

### Safe Code Review

**Plugin wrapper (recommended):**
```bash
codex-review.sh "Review [FILE] for [CONCERNS]"
gemini-review.sh "Review [FILE] for [CONCERNS]"
```

**Direct CLI:**
```bash
codex exec --sandbox read-only -c 'ask_for_approval="on-request"' -C "$(pwd)" \
  "Review [FILE] for [CONCERNS]"

gemini --approval-mode=yolo --sandbox -p "Review [FILE] for [CONCERNS]"
```

### Architecture Discussion

**Plugin wrapper:**
```bash
codex-review.sh "Analyze architecture and suggest improvements"
gemini-review.sh "Analyze architecture and suggest improvements"
```

**Direct CLI:**
```bash
codex exec --sandbox read-only -c 'ask_for_approval="on-request"' -C "$(pwd)" \
  "Analyze architecture and suggest improvements"

gemini --approval-mode=yolo --sandbox -p "Analyze architecture and suggest improvements"
```

### Debugging Consultation

**Plugin wrapper:**
```bash
codex-review.sh "Investigate [PROBLEM] in [FILE]. What are likely causes?"
gemini-review.sh "Investigate [PROBLEM] in [FILE]. What are likely causes?"
```

**Direct CLI:**
```bash
codex exec --sandbox read-only -c 'ask_for_approval="on-request"' -C "$(pwd)" \
  "Investigate [PROBLEM] in [FILE]. What are likely causes?"

gemini --approval-mode=yolo --sandbox -p "Investigate [PROBLEM] in [FILE]. What are likely causes?"
```

### With Output Capture

**Plugin wrapper:**
```bash
codex-review.sh -o ./codex-output.txt "Comprehensive code review"
gemini-review.sh -o json "Comprehensive code review"
```

**Direct CLI:**
```bash
codex exec --sandbox read-only -c 'ask_for_approval="on-request"' \
  -C "$(pwd)" \
  --output-last-message ./codex-output.txt \
  "Comprehensive code review"

gemini --approval-mode=yolo --sandbox --output-format json -p "Comprehensive code review"
```

### Allowing Modifications (Direct CLI Only!)
```bash
# Only use after user confirmation - NOT available through plugin wrapper
codex exec --sandbox workspace-write --full-auto -C "$(pwd)" \
  "Refactor [COMPONENT] to improve [ASPECT]"
```

## Advanced Usage

### Environment Variables

Set default behavior with environment variables:

```bash
# Set default project directory
export CODEX_PROJECT_DIR="$(pwd)"

# Then use in commands
codex exec --sandbox read-only -C "$CODEX_PROJECT_DIR" "Review code"
```

### Combining with Other Tools

```bash
# Pipe output to less for paging
codex exec --sandbox read-only -C "$(pwd)" "Review code" | less

# Save and process
codex exec --sandbox read-only \
  --output-last-message /tmp/review.txt \
  -C "$(pwd)" "Review code"
grep "TODO" /tmp/review.txt
```

### Multiple Reviews

```bash
# Review multiple files
for file in src/*.js; do
  echo "Reviewing $file..."
  codex exec --sandbox read-only -c 'ask_for_approval="on-request"' -C "$(pwd)" \
    "Review $file for security issues" > "reviews/$(basename $file).txt"
done
```

## Safety Guidelines

### Read-Only Safety Checklist
- Use for all reviews and consultations
- Safe for production code
- No risk of accidental changes
- Codex: use `-c 'ask_for_approval="on-request"'` (NOT `--full-auto`) to auto-approve
- Gemini: use `--approval-mode=yolo` to auto-approve

### Workspace-Write Safety Checklist
- Get user confirmation first
- Review changes before committing
- Use in development/feature branches only
- Consider omitting auto-approval for manual approval of each action
- Keep backups or ensure git is clean

## Troubleshooting

### AI Tool Not Found
```bash
# Check if tool is installed
which codex
which gemini

# Install if missing (follow official documentation)
```

### Permission Denied
```bash
# Ensure you have read access to project
ls -la "$(pwd)"

# Check tool has execute permissions
ls -l $(which codex)
```

### Timeout Issues
```bash
# For large codebases, be more specific
# Instead of: "Review entire codebase"
# Use: "Review src/main.js for security issues"
```

## Quick Reference

| Task | Sandbox Mode | Full Auto | Notes |
|------|--------------|-----------|-------|
| Code Review | read-only | Yes | Default for analysis |
| Architecture Opinion | read-only | Yes | Safe consultation |
| Debugging Analysis | read-only | Yes | Investigation mode |
| Deep Analysis | read-only | Yes | May need more capable model |
| Refactoring | workspace-write | Caution | Confirm with user |
| Bug Fixes | workspace-write | Caution | Confirm with user |

## Codex CLI Options

```bash
codex exec [options] "<prompt>"

Key options:
  --sandbox MODE       Sandbox mode: read-only, workspace-write, or danger-full-access
  -c key=value         Config override (e.g. -c 'ask_for_approval="on-request"')
  --full-auto          Auto-approve + workspace-write (DO NOT use with --sandbox read-only)
  -C, --cd DIR         Working directory
  -m, --model MODEL    Model selection
  -o, --output-last-message FILE  Capture output to file
  --ephemeral          Run without persisting session files
  --skip-git-repo-check  Allow running outside a git repo
```

## Gemini CLI Options

```bash
gemini [options] -p "<prompt>"

Key options:
  -s, --sandbox          Run in sandbox mode (read-only)
  --approval-mode=yolo   Auto-approve all actions (replaces deprecated --yolo)
  -p, --prompt           Non-interactive (headless) mode with given prompt
  --include-directories  Additional directories to include
  -o, --output-format    Output format: text, json, stream-json
  -r, --resume           Resume a previous session
```
