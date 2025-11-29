# Codex CLI Setup Guide

This guide covers setting up OpenAI Codex CLI for use with the codex-consultant agent.

## Prerequisites

- Node.js 18+ installed
- OpenAI API account with API key
- Terminal access

## Installation

### 1. Install Codex CLI

```bash
npm install -g @openai/codex
```

Verify installation:

```bash
codex --version
```

### 2. Configure API Key

Set your OpenAI API key as an environment variable:

```bash
# Add to your ~/.bashrc, ~/.zshrc, or shell profile
export OPENAI_API_KEY='your-api-key-here'
```

Reload your shell:

```bash
source ~/.bashrc  # or ~/.zshrc
```

### 3. Test Installation

```bash
codex exec --sandbox read-only --full-auto -C "$(pwd)" "List the files in this directory"
```

## Usage with codex-consultant

The codex-consultant agent uses the helper script at `scripts/codex-review.sh`.

### Basic Usage

```bash
# From the plugin directory
./scripts/codex-review.sh "Review index.js for security issues"

# With a specific directory
./scripts/codex-review.sh -d /path/to/project "Analyze architecture"

# Save output to file
./scripts/codex-review.sh -o review.txt "Comprehensive code review"
```

### Options

| Option | Description |
|--------|-------------|
| `-d, --dir DIR` | Project directory (default: current directory) |
| `-o, --output FILE` | Save response to file |
| `-n, --no-auto` | Disable full-auto mode |
| `-h, --help` | Show help message |

## CLI Options Reference

### Sandbox Modes

- `read-only`: Safe mode for analysis (cannot modify files)
- `workspace-write`: Allow file modifications (use with caution)

The codex-consultant agent **always uses read-only mode** for safety.

### --full-auto

Runs without asking for approval on each tool use. Enabled by default for consultations.

### -C, --directory

Sets the working directory for the session.

```bash
codex exec --sandbox read-only --full-auto -C "/path/to/project" "Review code"
```

### --output-last-message

Captures the AI's final response to a file:

```bash
codex exec --sandbox read-only --full-auto \
  --output-last-message review.txt \
  -C "$(pwd)" "Review code"
```

## Troubleshooting

### "codex: command not found"

Ensure npm global bin directory is in your PATH:

```bash
# Find npm global bin directory
npm config get prefix

# Add to PATH in your shell profile
export PATH="$(npm config get prefix)/bin:$PATH"
```

### API Key Not Found

Verify your API key is set:

```bash
echo $OPENAI_API_KEY
```

If empty, set it in your shell profile and reload.

### Timeout Issues

For large codebases, be more specific with your prompts:

```bash
# Instead of: "Review entire codebase"
# Use: "Review src/auth/login.js for security issues"
```

### Permission Denied

Ensure the helper script is executable:

```bash
chmod +x scripts/codex-review.sh
```

## Best Practices

1. **Be Specific**: Name files and components explicitly
2. **Use Read-Only**: Never use workspace-write unless absolutely necessary
3. **Review Output**: Always critically evaluate AI suggestions
4. **Save Important Reviews**: Use `-o` to save output for reference

## Example Prompts

### Code Review
```bash
./scripts/codex-review.sh "Review src/api/auth.js for:
1. Security vulnerabilities
2. Error handling gaps
3. Performance issues
Provide line numbers for each finding."
```

### Architecture Analysis
```bash
./scripts/codex-review.sh "Analyze the architecture of this project:
- Component structure
- Data flow
- Scalability concerns
What would you improve?"
```

### Debugging Help
```bash
./scripts/codex-review.sh "Users report intermittent 500 errors from /api/users.
Investigate src/api/users.js for:
- Race conditions
- Error handling gaps
- Potential causes"
```

## Resources

- [OpenAI Codex Documentation](https://github.com/openai/codex)
- [OpenAI API Documentation](https://platform.openai.com/docs)
