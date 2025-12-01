#!/usr/bin/env bash
# codex-review.sh - Helper script for codex consultations (READ-ONLY)
# Part of somepulp-agents plugin for Claude Code

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values - ALWAYS read-only
DIR="$(pwd)"
SANDBOX="read-only"
OUTPUT_FILE=""
FULL_AUTO="yes"
PROMPT=""

# Function to show help
show_help() {
    cat << EOF
${GREEN}codex-review.sh${NC} - Helper script for codex consultations (READ-ONLY)

${YELLOW}USAGE:${NC}
    codex-review.sh [OPTIONS] "<prompt>"

${YELLOW}OPTIONS:${NC}
    -d, --dir DIR       Project directory (default: current directory)
    -o, --output FILE   Save codex's final response to file
    -n, --no-auto       Disable full-auto mode (ask for approval)
    -h, --help          Show this help message

${YELLOW}EXAMPLES:${NC}
    ${GREEN}# Review current directory${NC}
    codex-review.sh "Review index.js for security issues"

    ${GREEN}# Review specific directory${NC}
    codex-review.sh -d /path/to/project "Review architecture"

    ${GREEN}# Save output to file${NC}
    codex-review.sh -o review.txt "Comprehensive code review"

${YELLOW}COMMON CONSULTATION TYPES:${NC}
    • Code Review:        codex-review.sh "Review [file] for code quality"
    • Security Audit:     codex-review.sh "Security audit of [file]"
    • Architecture:       codex-review.sh "Analyze architecture of [component]"
    • Debugging:          codex-review.sh "Investigate [symptom] in [file]"
    • Performance:        codex-review.sh "Analyze [file] for performance issues"

${YELLOW}NOTES:${NC}
    • This script is READ-ONLY - codex cannot modify files
    • The prompt should be specific and include file names
    • Requires Codex CLI: ${BLUE}https://github.com/openai/codex${NC}

EOF
}

# Check if codex command is available - do this early with helpful message
check_codex_installed() {
    if ! command -v codex &> /dev/null; then
        echo -e "${RED}ERROR: Codex CLI is not installed${NC}" >&2
        echo -e "See: ${BLUE}https://github.com/openai/codex${NC}" >&2
        return 1
    fi
    return 0
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--dir)
            if [[ $# -lt 2 || "$2" == -* ]]; then
                echo -e "${RED}Error: -d/--dir requires a directory path${NC}" >&2
                exit 1
            fi
            DIR="$2"
            shift 2
            ;;
        -o|--output)
            if [[ $# -lt 2 || "$2" == -* ]]; then
                echo -e "${RED}Error: -o/--output requires a file path${NC}" >&2
                exit 1
            fi
            OUTPUT_FILE="$2"
            shift 2
            ;;
        -n|--no-auto)
            FULL_AUTO="no"
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        -*)
            echo -e "${RED}Error: Unknown option: $1${NC}" >&2
            echo "Use -h or --help for usage information" >&2
            exit 1
            ;;
        *)
            # Collect all remaining positional arguments as the prompt
            PROMPT="$*"
            break
            ;;
    esac
done

# Check codex is installed first
if ! check_codex_installed; then
    exit 1
fi

# Validate prompt is provided
if [[ -z "$PROMPT" ]]; then
    echo -e "${RED}Error: Prompt is required${NC}" >&2
    echo "" >&2
    show_help
    exit 1
fi

# Validate directory exists
if [[ ! -d "$DIR" ]]; then
    echo -e "${RED}Error: Directory does not exist: $DIR${NC}" >&2
    exit 1
fi

# Show what we're about to do
echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}" >&2
echo -e "${GREEN}║  Codex Consultation (READ-ONLY)                              ║${NC}" >&2
echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}" >&2
printf '  Directory:  %s\n' "$DIR" >&2
printf '  Sandbox:    %s\n' "$SANDBOX" >&2
printf '  Full-auto:  %s\n' "$FULL_AUTO" >&2
if [[ -n "$OUTPUT_FILE" ]]; then
    printf '  Output:     %s\n' "$OUTPUT_FILE" >&2
fi
printf '  Prompt:     "%s"\n' "$PROMPT" >&2
echo "" >&2

# Build command array - ALWAYS read-only (no eval, no injection possible)
cmd=(codex exec --sandbox "$SANDBOX" -C "$DIR")

if [[ "$FULL_AUTO" == "yes" ]]; then
    cmd+=(--full-auto)
fi

if [[ -n "$OUTPUT_FILE" ]]; then
    cmd+=(--output-last-message "$OUTPUT_FILE")
fi

cmd+=("$PROMPT")

echo -e "${GREEN}Executing codex...${NC}" >&2
echo "" >&2

# Execute the command safely using array expansion
"${cmd[@]}"

# Capture exit code
EXIT_CODE=$?

echo "" >&2
if [[ $EXIT_CODE -eq 0 ]]; then
    echo -e "${GREEN}✓ Codex consultation completed successfully${NC}" >&2
else
    echo -e "${RED}✗ Codex consultation failed with exit code: $EXIT_CODE${NC}" >&2
fi

exit $EXIT_CODE
