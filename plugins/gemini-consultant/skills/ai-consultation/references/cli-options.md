# AI CLI Options Reference

This document provides detailed information about CLI options for AI consultations. While examples show Codex CLI syntax, the patterns apply to Gemini CLI and other AI CLI tools as well.

> **Note:** This plugin provides a helper script (`scripts/gemini-review.sh`) that wraps the Gemini CLI with safety defaults. The script **always enforces sandbox (read-only) mode** and provides a simplified interface. Some options documented below are only available when using the CLI directly, not through the plugin wrapper.

## Plugin Wrapper vs Direct CLI

| Feature | Plugin Wrapper (`gemini-review.sh`) | Direct CLI (`gemini`) |
|---------|-------------------------------------|----------------------|
| Sandbox mode | Always enabled (enforced) | `--sandbox` flag |
| Auto-approve | Always enabled (`--yolo`) | `--yolo` flag |
| Output format | `-o format` | `--output-format format` |
| Include directories | `-d path` (repeatable) | `--include-directories path` |

## Core Options

### --sandbox MODE

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
  - **Not available through plugin wrapper** - use `codex exec` directly

**Examples:**
```bash
# Safe review (plugin wrapper or direct CLI)
codex exec --sandbox read-only --full-auto -C "$(pwd)" "Review security issues"

# Allow changes - DIRECT CLI ONLY (use carefully!)
# Note: The plugin wrapper always enforces read-only mode
codex exec --sandbox workspace-write --full-auto -C "$(pwd)" "Refactor error handling"
```

### --full-auto

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

**Examples:**
```bash
# Direct CLI with full-auto enabled
codex exec --sandbox read-only --full-auto -C "$(pwd)" "Analyze performance bottlenecks"

# Direct CLI without full-auto (manual approval required)
codex exec --sandbox read-only -C "$(pwd)" "Analyze performance bottlenecks"
```

**Plugin wrapper:**
```bash
# Full-auto enabled (default)
codex-review.sh "Analyze performance bottlenecks"

# Full-auto disabled (manual approval)
codex-review.sh -n "Analyze performance bottlenecks"
```

### -C, --directory DIRECTORY

Set the working directory for the session.

**Usage:**
```bash
# Use current directory
codex exec --sandbox read-only --full-auto -C "$(pwd)" "Review code"

# Use specific directory
codex exec --sandbox read-only --full-auto -C "/path/to/project" "Review code"

# Use environment variable
codex exec --sandbox read-only --full-auto -C "$PROJECT_DIR" "Review code"
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

### --output-last-message FILE

Capture the AI's final response to a file.

**Use cases:**
- Save review results for later reference
- Create documentation from analysis
- Process output with other tools
- Keep consultation history

**Example:**
```bash
codex exec --sandbox read-only --full-auto \
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
```

**Direct CLI:**
```bash
codex exec --sandbox read-only --full-auto -C "$(pwd)" \
  "Review [FILE] for [CONCERNS]"
```

### Architecture Discussion

**Plugin wrapper:**
```bash
codex-review.sh "Analyze architecture and suggest improvements"
```

**Direct CLI:**
```bash
codex exec --sandbox read-only --full-auto -C "$(pwd)" \
  "Analyze architecture and suggest improvements"
```

### Debugging Consultation

**Plugin wrapper:**
```bash
codex-review.sh "Investigate [PROBLEM] in [FILE]. What are likely causes?"
```

**Direct CLI:**
```bash
codex exec --sandbox read-only --full-auto -C "$(pwd)" \
  "Investigate [PROBLEM] in [FILE]. What are likely causes?"
```

### With Output Capture

**Plugin wrapper:**
```bash
codex-review.sh -o ./codex-output.txt "Comprehensive code review"
```

**Direct CLI:**
```bash
codex exec --sandbox read-only --full-auto \
  -C "$(pwd)" \
  --output-last-message ./codex-output.txt \
  "Comprehensive code review"
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
codex exec --sandbox read-only --full-auto -C "$CODEX_PROJECT_DIR" "Review code"
```

### Combining with Other Tools

```bash
# Pipe output to less for paging
codex exec --sandbox read-only --full-auto -C "$(pwd)" "Review code" | less

# Save and process
codex exec --sandbox read-only --full-auto \
  --output-last-message /tmp/review.txt \
  -C "$(pwd)" "Review code"
grep "TODO" /tmp/review.txt
```

### Multiple Reviews

```bash
# Review multiple files
for file in src/*.js; do
  echo "Reviewing $file..."
  codex exec --sandbox read-only --full-auto -C "$(pwd)" \
    "Review $file for security issues" > "reviews/$(basename $file).txt"
done
```

## Safety Guidelines

### Read-Only Safety Checklist
- Use for all reviews and consultations
- Safe for production code
- No risk of accidental changes
- Can combine with --full-auto

### Workspace-Write Safety Checklist
- Get user confirmation first
- Review changes before committing
- Use in development/feature branches only
- Consider using without --full-auto for approval
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

## Gemini CLI Equivalent Options

For Gemini CLI, similar patterns apply:

```bash
# Basic consultation (read-only with sandbox)
gemini --yolo --sandbox "Review index.js for security issues"

# With additional directory
gemini --yolo --sandbox --include-directories /path/to/lib "Review code"

# Output format options
gemini --yolo --sandbox --output-format json "Analyze code"
```

Key options:
- `-s, --sandbox` - Run in sandbox mode (read-only)
- `-y, --yolo` - Auto-approve all actions
- `--include-directories` - Additional directories to include
- `-o, --output-format` - Output format: text, json, stream-json
