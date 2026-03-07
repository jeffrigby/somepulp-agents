#!/usr/bin/env bash
# validate-sandbox.sh - Deterministic safety check for codex/gemini invocations
# Used as a PreToolUse hook to block unsafe CLI usage
#
# Reads the Bash command from the CLAUDE_TOOL_INPUT environment variable (JSON).
# Exits 0 to approve, exits 2 to block.

set -euo pipefail

# Extract the command from CLAUDE_TOOL_INPUT JSON
COMMAND="${CLAUDE_TOOL_INPUT:-}"
if [[ -z "$COMMAND" ]]; then
    exit 0  # No input, approve (shouldn't happen)
fi

# Extract the "command" field from JSON using python (available on macOS/Linux)
CMD=$(python3 -c "import json,sys; print(json.loads(sys.stdin.read()).get('command',''))" <<< "$COMMAND" 2>/dev/null || echo "")

if [[ -z "$CMD" ]]; then
    exit 0  # Could not parse, let the prompt hook handle it
fi

# Only check commands that invoke codex or gemini
if ! echo "$CMD" | grep -qE '\b(codex|gemini)\b'; then
    exit 0  # Not a codex/gemini command, approve
fi

# Block: codex with --full-auto (overrides sandbox to workspace-write)
if echo "$CMD" | grep -qE '\bcodex\b' && echo "$CMD" | grep -qE '\-\-full-auto'; then
    echo "BLOCKED: --full-auto overrides --sandbox to workspace-write. Use -c 'ask_for_approval=\"on-request\"' instead." >&2
    exit 2
fi

# Block: codex with workspace-write or danger-full-access sandbox
if echo "$CMD" | grep -qE '\bcodex\b' && echo "$CMD" | grep -qE '\-\-sandbox[= ](workspace-write|danger-full-access)'; then
    echo "BLOCKED: Only --sandbox read-only is allowed for consultations." >&2
    exit 2
fi

# Block: codex without --sandbox flag at all (default may not be read-only)
if echo "$CMD" | grep -qE '\bcodex\s+exec\b' && ! echo "$CMD" | grep -qE '\-\-sandbox'; then
    echo "BLOCKED: codex exec must include --sandbox read-only." >&2
    exit 2
fi

# Block: gemini without --sandbox flag
if echo "$CMD" | grep -qE '\bgemini\b' && ! echo "$CMD" | grep -qE '\-\-sandbox\b'; then
    echo "BLOCKED: gemini must include --sandbox flag." >&2
    exit 2
fi

# All checks passed
exit 0
