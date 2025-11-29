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
OUTPUT=""
FULL_AUTO="--full-auto"
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
    • For more examples, see skills/ai-consultation/references/examples.md

${YELLOW}INSTALLATION:${NC}
    Codex CLI must be installed. Install via:
    ${BLUE}npm install -g @openai/codex${NC}

EOF
}

# Check if codex command is available - do this early with helpful message
check_codex_installed() {
    if ! command -v codex &> /dev/null; then
        echo -e "${RED}╔══════════════════════════════════════════════════════════════╗${NC}" >&2
        echo -e "${RED}║  ERROR: Codex CLI is not installed                           ║${NC}" >&2
        echo -e "${RED}╚══════════════════════════════════════════════════════════════╝${NC}" >&2
        echo "" >&2
        echo -e "${YELLOW}To install Codex CLI:${NC}" >&2
        echo -e "  ${BLUE}npm install -g @openai/codex${NC}" >&2
        echo "" >&2
        echo -e "${YELLOW}After installation, ensure you have:${NC}" >&2
        echo -e "  1. Set your OpenAI API key: ${BLUE}export OPENAI_API_KEY='your-key'${NC}" >&2
        echo -e "  2. Verified installation: ${BLUE}codex --version${NC}" >&2
        echo "" >&2
        echo -e "${YELLOW}Documentation:${NC}" >&2
        echo -e "  https://github.com/openai/codex" >&2
        echo "" >&2
        return 1
    fi
    return 0
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--dir)
            DIR="$2"
            shift 2
            ;;
        -o|--output)
            OUTPUT="--output-last-message $2"
            shift 2
            ;;
        -n|--no-auto)
            FULL_AUTO=""
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
            PROMPT="$1"
            shift
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
echo -e "  Directory:  $DIR" >&2
echo -e "  Sandbox:    $SANDBOX" >&2
echo -e "  Full-auto:  ${FULL_AUTO:-disabled}" >&2
if [[ -n "$OUTPUT" ]]; then
    echo -e "  Output:     ${OUTPUT#--output-last-message }" >&2
fi
echo -e "  Prompt:     \"$PROMPT\"" >&2
echo "" >&2

# Execute codex - ALWAYS read-only
CMD="codex exec --sandbox \"$SANDBOX\" $FULL_AUTO -C \"$DIR\" $OUTPUT \"$PROMPT\""

echo -e "${GREEN}Executing codex...${NC}" >&2
echo "" >&2

# Execute the command
eval "$CMD"

# Capture exit code
EXIT_CODE=$?

echo "" >&2
if [[ $EXIT_CODE -eq 0 ]]; then
    echo -e "${GREEN}✓ Codex consultation completed successfully${NC}" >&2
else
    echo -e "${RED}✗ Codex consultation failed with exit code: $EXIT_CODE${NC}" >&2
fi

exit $EXIT_CODE
