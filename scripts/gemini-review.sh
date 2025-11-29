#!/usr/bin/env bash
# gemini-review.sh - Helper script for gemini consultations (READ-ONLY)
# Part of somepulp-agents plugin for Claude Code

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values - ALWAYS sandbox (read-only)
DIR="$(pwd)"
SANDBOX="--sandbox"
OUTPUT_FORMAT=""
YOLO="--yolo"
PROMPT=""
INCLUDE_DIRS=""

# Function to show help
show_help() {
    cat << EOF
${GREEN}gemini-review.sh${NC} - Helper script for gemini consultations (READ-ONLY)

${YELLOW}USAGE:${NC}
    gemini-review.sh [OPTIONS] "<prompt>"

${YELLOW}OPTIONS:${NC}
    -d, --dir DIR           Include additional directory (can be repeated)
    -o, --output FORMAT     Output format: text, json, stream-json
    -h, --help              Show this help message

${YELLOW}EXAMPLES:${NC}
    ${GREEN}# Review current directory${NC}
    gemini-review.sh "Review index.js for security issues"

    ${GREEN}# Include additional directory${NC}
    gemini-review.sh -d /path/to/lib "Review architecture"

    ${GREEN}# Get JSON output${NC}
    gemini-review.sh -o json "Analyze this code"

${YELLOW}COMMON CONSULTATION TYPES:${NC}
    • Code Review:        gemini-review.sh "Review [file] for code quality"
    • Security Audit:     gemini-review.sh "Security audit of [file]"
    • Architecture:       gemini-review.sh "Analyze architecture of [component]"
    • Debugging:          gemini-review.sh "Investigate [symptom] in [file]"
    • Performance:        gemini-review.sh "Analyze [file] for performance issues"

${YELLOW}NOTES:${NC}
    • This script is READ-ONLY - gemini cannot modify files (sandbox mode)
    • The prompt should be specific and include file names
    • Gemini CLI works from the current directory by default

${YELLOW}INSTALLATION:${NC}
    Gemini CLI must be installed. Follow Google's official installation guide:
    ${BLUE}https://github.com/google-gemini/gemini-cli${NC}

EOF
}

# Check if gemini command is available - do this early with helpful message
check_gemini_installed() {
    if ! command -v gemini &> /dev/null; then
        echo -e "${RED}╔══════════════════════════════════════════════════════════════╗${NC}" >&2
        echo -e "${RED}║  ERROR: Gemini CLI is not installed                          ║${NC}" >&2
        echo -e "${RED}╚══════════════════════════════════════════════════════════════╝${NC}" >&2
        echo "" >&2
        echo -e "${YELLOW}To install Gemini CLI:${NC}" >&2
        echo -e "  Follow Google's official installation guide" >&2
        echo "" >&2
        echo -e "${YELLOW}After installation, ensure you have:${NC}" >&2
        echo -e "  1. Authenticated with Google: ${BLUE}gemini auth login${NC}" >&2
        echo -e "  2. Verified installation: ${BLUE}gemini --version${NC}" >&2
        echo "" >&2
        echo -e "${YELLOW}Documentation:${NC}" >&2
        echo -e "  https://ai.google.dev/gemini-api/docs" >&2
        echo "" >&2
        return 1
    fi
    return 0
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--dir)
            if [[ -n "$INCLUDE_DIRS" ]]; then
                INCLUDE_DIRS="$INCLUDE_DIRS --include-directories $2"
            else
                INCLUDE_DIRS="--include-directories $2"
            fi
            shift 2
            ;;
        -o|--output)
            OUTPUT_FORMAT="-o $2"
            shift 2
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

# Check gemini is installed first
if ! check_gemini_installed; then
    exit 1
fi

# Validate prompt is provided
if [[ -z "$PROMPT" ]]; then
    echo -e "${RED}Error: Prompt is required${NC}" >&2
    echo "" >&2
    show_help
    exit 1
fi

# Show what we're about to do
echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}" >&2
echo -e "${GREEN}║  Gemini Consultation (READ-ONLY)                             ║${NC}" >&2
echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}" >&2
echo -e "  Directory:  $(pwd)" >&2
echo -e "  Sandbox:    enabled (read-only)" >&2
if [[ -n "$INCLUDE_DIRS" ]]; then
    echo -e "  Include:    ${INCLUDE_DIRS}" >&2
fi
if [[ -n "$OUTPUT_FORMAT" ]]; then
    echo -e "  Output:     ${OUTPUT_FORMAT}" >&2
fi
echo -e "  Prompt:     \"$PROMPT\"" >&2
echo "" >&2

# Build and execute command - ALWAYS sandbox (read-only)
CMD="gemini $YOLO $SANDBOX $OUTPUT_FORMAT $INCLUDE_DIRS \"$PROMPT\""

echo -e "${GREEN}Executing gemini...${NC}" >&2
echo "" >&2

# Execute the command
eval "$CMD"

# Capture exit code
EXIT_CODE=$?

echo "" >&2
if [[ $EXIT_CODE -eq 0 ]]; then
    echo -e "${GREEN}✓ Gemini consultation completed successfully${NC}" >&2
else
    echo -e "${RED}✗ Gemini consultation failed with exit code: $EXIT_CODE${NC}" >&2
fi

exit $EXIT_CODE
