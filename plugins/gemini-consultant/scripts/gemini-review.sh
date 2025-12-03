#!/usr/bin/env bash
# gemini-review.sh - Helper script for gemini consultations (READ-ONLY)
# Part of somepulp-agents plugin for Claude Code

set -euo pipefail

# Colors for output (only if stderr is a terminal)
if [[ -t 2 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    NC='\033[0m' # No Color
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    NC=''
fi

# Handle interrupts gracefully
trap 'echo -e "\n${YELLOW}Interrupted${NC}" >&2; exit 130' INT TERM

# Default values - ALWAYS sandbox (read-only)
OUTPUT_FORMAT=""
PROMPT=""

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
    • Requires Gemini CLI: ${BLUE}https://github.com/google-gemini/gemini-cli${NC}

EOF
}

# Check if gemini command is available - do this early with helpful message
check_gemini_installed() {
    if ! command -v gemini &> /dev/null; then
        echo -e "${RED}ERROR: Gemini CLI is not installed${NC}" >&2
        echo -e "See: ${BLUE}https://github.com/google-gemini/gemini-cli${NC}" >&2
        return 1
    fi
    return 0
}

# Array to hold additional directories
declare -a INCLUDE_DIRS_ARRAY=()

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--dir)
            if [[ $# -lt 2 || "$2" == -* ]]; then
                echo -e "${RED}Error: -d/--dir requires a directory path${NC}" >&2
                exit 1
            fi
            if [[ ! -d "$2" ]]; then
                echo -e "${RED}Error: Directory does not exist: $2${NC}" >&2
                exit 1
            fi
            INCLUDE_DIRS_ARRAY+=("$2")
            shift 2
            ;;
        -o|--output)
            if [[ $# -lt 2 || "$2" == -* ]]; then
                echo -e "${RED}Error: -o/--output requires a format (text, json, stream-json)${NC}" >&2
                exit 1
            fi
            OUTPUT_FORMAT="$2"
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
            # Collect all remaining positional arguments as the prompt
            PROMPT="$*"
            break
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
printf '  Directory:  %s\n' "$(pwd)" >&2
printf '  Sandbox:    %s\n' "enabled (read-only)" >&2
if [[ ${#INCLUDE_DIRS_ARRAY[@]} -gt 0 ]]; then
    printf '  Include:    %s\n' "${INCLUDE_DIRS_ARRAY[*]}" >&2
fi
if [[ -n "$OUTPUT_FORMAT" ]]; then
    printf '  Output:     %s\n' "$OUTPUT_FORMAT" >&2
fi
printf '  Prompt:     "%s"\n' "$PROMPT" >&2
echo "" >&2

# Build command array - ALWAYS sandbox (read-only, no eval, no injection possible)
cmd=(gemini --yolo --sandbox)

if [[ -n "$OUTPUT_FORMAT" ]]; then
    cmd+=(-o "$OUTPUT_FORMAT")
fi

# Add each include directory separately (safe for empty array with set -u)
if [[ ${#INCLUDE_DIRS_ARRAY[@]} -gt 0 ]]; then
    for dir in "${INCLUDE_DIRS_ARRAY[@]}"; do
        cmd+=(--include-directories "$dir")
    done
fi

# Use -- to prevent prompt from being interpreted as options
cmd+=(-- "$PROMPT")

echo -e "${GREEN}Executing gemini...${NC}" >&2
echo "" >&2

# Execute the command safely using array expansion
"${cmd[@]}"

# Capture exit code
EXIT_CODE=$?

echo "" >&2
if [[ $EXIT_CODE -eq 0 ]]; then
    echo -e "${GREEN}✓ Gemini consultation completed successfully${NC}" >&2
else
    echo -e "${RED}✗ Gemini consultation failed with exit code: $EXIT_CODE${NC}" >&2
fi

exit $EXIT_CODE
