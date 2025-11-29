# Gemini CLI Setup Guide

This guide covers setting up Google Gemini CLI for use with the gemini-consultant agent.

## Prerequisites

- Google account with Gemini API access
- Terminal access

## Installation

### 1. Install Gemini CLI

Follow Google's official installation guide for your platform:

- **macOS/Linux**: Use the official installer or package manager
- **Windows**: Use the Windows installer

### 2. Authenticate

```bash
gemini auth login
```

Follow the prompts to authenticate with your Google account.

### 3. Test Installation

```bash
gemini --version
```

Test a simple command:

```bash
gemini --yolo --sandbox "What files are in the current directory?"
```

## Usage with gemini-consultant

The gemini-consultant agent uses the helper script at `scripts/gemini-review.sh`.

### Basic Usage

```bash
# From the plugin directory
./scripts/gemini-review.sh "Review index.js for security issues"

# Include additional directory
./scripts/gemini-review.sh -d /path/to/lib "Analyze architecture"

# Get JSON output
./scripts/gemini-review.sh -o json "Analyze this code"
```

### Options

| Option | Description |
|--------|-------------|
| `-d, --dir DIR` | Include additional directory (can be repeated) |
| `-o, --output FORMAT` | Output format: text, json, stream-json |
| `-h, --help` | Show help message |

## CLI Options Reference

### --sandbox (-s)

Runs in sandbox mode (read-only). The gemini-consultant agent **always uses sandbox mode** for safety.

### --yolo (-y)

Auto-approves all actions without prompting. Enabled by default for consultations.

### --include-directories

Include additional directories for context:

```bash
gemini --yolo --sandbox --include-directories /path/to/lib "Review code"
```

### --output-format (-o)

Specify output format:
- `text`: Plain text (default)
- `json`: JSON format
- `stream-json`: Streaming JSON

## Troubleshooting

### "gemini: command not found"

Ensure Gemini CLI is properly installed and in your PATH.

### Authentication Issues

Re-authenticate with:

```bash
gemini auth logout
gemini auth login
```

### Permission Denied

Ensure the helper script is executable:

```bash
chmod +x scripts/gemini-review.sh
```

## Best Practices

1. **Be Specific**: Name files and components explicitly
2. **Use Sandbox Mode**: Always use sandbox mode for consultations
3. **Review Output**: Always critically evaluate AI suggestions
4. **Include Context**: Use `-d` to include relevant directories

## Example Prompts

### Code Review
```bash
./scripts/gemini-review.sh "Review src/api/auth.js for:
1. Security vulnerabilities
2. Error handling gaps
3. Performance issues
Provide specific line numbers."
```

### Architecture Analysis
```bash
./scripts/gemini-review.sh "Analyze the architecture of this project:
- Component relationships
- Data flow patterns
- Potential scalability issues
What improvements would you suggest?"
```

### Debugging Help
```bash
./scripts/gemini-review.sh "We're seeing memory leaks in production.
Analyze src/cache.js for:
- Unreleased references
- Event listener cleanup
- Timer management"
```

### With Additional Context

```bash
./scripts/gemini-review.sh \
  -d /path/to/shared/lib \
  "Review how we use the shared library in src/api/"
```

## Comparing with Codex

Both tools can provide valuable perspectives. Consider:

| Aspect | Codex | Gemini |
|--------|-------|--------|
| Provider | OpenAI | Google |
| Strengths | Code generation | Multimodal understanding |
| Setup | npm install | Official installer |
| Auth | API key | Google account |

Using both tools for the same review can provide complementary insights.

## Resources

- [Google Gemini API Documentation](https://ai.google.dev/gemini-api/docs)
- [Gemini CLI Guide](https://ai.google.dev/gemini-api/docs/cli)
