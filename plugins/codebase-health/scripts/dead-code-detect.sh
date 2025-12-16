#!/usr/bin/env bash
# dead-code-detect.sh - Helper script for dead code detection
# Part of codebase-health plugin for Claude Code

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

# Default values
DIR="$(pwd)"
MODE="detect"
FORMAT="text"
PROJECT_TYPE=""

# Function to show help
show_help() {
    cat << EOF
${GREEN}dead-code-detect.sh${NC} - Auto-detect project type and run dead code analysis

${YELLOW}USAGE:${NC}
    dead-code-detect.sh [OPTIONS]

${YELLOW}OPTIONS:${NC}
    -d, --dir DIR       Project directory (default: current directory)
    -m, --mode MODE     Mode: 'detect' (default) or 'fix'
    -f, --format FMT    Output format: 'text' (default) or 'json'
    -t, --type TYPE     Force project type: 'nodejs', 'python', or 'auto' (default)
    -h, --help          Show this help message

${YELLOW}EXAMPLES:${NC}
    ${GREEN}# Detect dead code in current directory${NC}
    dead-code-detect.sh

    ${GREEN}# Get JSON output for parsing${NC}
    dead-code-detect.sh --format json

    ${GREEN}# Run in specific directory${NC}
    dead-code-detect.sh -d /path/to/project

    ${GREEN}# Fix dead code (after user approval)${NC}
    dead-code-detect.sh --mode fix

${YELLOW}SUPPORTED PROJECT TYPES:${NC}
    • Node.js/TypeScript: Uses knip (npm install -g knip)
    • Python: Uses deadcode (pip install deadcode)

${YELLOW}NOTES:${NC}
    • In detect mode, no files are modified
    • Fix mode requires explicit user approval before running
    • JSON format is recommended for programmatic parsing

EOF
}

# Detect project type
detect_project_type() {
    local dir="$1"
    local has_nodejs=false
    local has_python=false

    # Check for Node.js/TypeScript
    if [[ -f "$dir/package.json" ]] || [[ -f "$dir/tsconfig.json" ]]; then
        has_nodejs=true
    fi

    # Check for Python
    if [[ -f "$dir/requirements.txt" ]] || [[ -f "$dir/setup.py" ]] || [[ -f "$dir/pyproject.toml" ]]; then
        has_python=true
    fi

    # Also check for .py files if no config found
    # Note: Use subshell to avoid pipefail issues when no .py files exist
    if [[ "$has_python" == "false" ]]; then
        if (set +o pipefail; find "$dir" -maxdepth 3 -name "*.py" -type f 2>/dev/null | head -1 | grep -q .); then
            has_python=true
        fi
    fi

    if [[ "$has_nodejs" == "true" ]] && [[ "$has_python" == "true" ]]; then
        echo "mixed"
    elif [[ "$has_nodejs" == "true" ]]; then
        echo "nodejs"
    elif [[ "$has_python" == "true" ]]; then
        echo "python"
    else
        echo "unknown"
    fi
}

# Check if knip is available
check_knip() {
    if command -v knip &> /dev/null; then
        return 0
    fi
    # Check if npx can run it
    if command -v npx &> /dev/null; then
        return 0
    fi
    return 1
}

# Check if deadcode is available
check_deadcode() {
    if command -v deadcode &> /dev/null; then
        return 0
    fi
    # Check via python module
    if python3 -c "import deadcode" 2>/dev/null; then
        return 0
    fi
    return 1
}

# Run knip for Node.js/TypeScript projects
run_knip() {
    local dir="$1"
    local mode="$2"
    local format="$3"

    local -a cmd

    # Prefer npx for portability - use array to handle spaces safely
    if command -v npx &> /dev/null; then
        cmd=(npx knip)
    else
        cmd=(knip)
    fi

    if [[ "$mode" == "fix" ]]; then
        echo -e "${YELLOW}Running knip --fix in $dir${NC}" >&2
        (cd "$dir" && "${cmd[@]}" --fix)
    else
        if [[ "$format" == "json" ]]; then
            (cd "$dir" && "${cmd[@]}" --reporter json 2>/dev/null) || {
                echo -e "${RED}Error: knip failed. Run 'npx knip' manually to see details.${NC}" >&2
                return 1
            }
        else
            (cd "$dir" && "${cmd[@]}")
        fi
    fi
}

# Run deadcode for Python projects
run_deadcode() {
    local dir="$1"
    local mode="$2"
    local format="$3"

    local -a cmd

    # Try direct command first, then python module - use array for safety
    if command -v deadcode &> /dev/null; then
        cmd=(deadcode)
    else
        cmd=(python3 -m deadcode)
    fi

    if [[ "$mode" == "fix" ]]; then
        echo -e "${YELLOW}Running deadcode --fix in $dir${NC}" >&2
        (cd "$dir" && "${cmd[@]}" . --fix)
    else
        # Deadcode doesn't have JSON output, so we just run it
        (cd "$dir" && "${cmd[@]}" .)
    fi
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
        -m|--mode)
            if [[ $# -lt 2 || "$2" == -* ]]; then
                echo -e "${RED}Error: -m/--mode requires 'detect' or 'fix'${NC}" >&2
                exit 1
            fi
            MODE="$2"
            if [[ "$MODE" != "detect" && "$MODE" != "fix" ]]; then
                echo -e "${RED}Error: Mode must be 'detect' or 'fix'${NC}" >&2
                exit 1
            fi
            shift 2
            ;;
        -f|--format)
            if [[ $# -lt 2 || "$2" == -* ]]; then
                echo -e "${RED}Error: -f/--format requires 'text' or 'json'${NC}" >&2
                exit 1
            fi
            FORMAT="$2"
            if [[ "$FORMAT" != "text" && "$FORMAT" != "json" ]]; then
                echo -e "${RED}Error: Format must be 'text' or 'json'${NC}" >&2
                exit 1
            fi
            shift 2
            ;;
        -t|--type)
            if [[ $# -lt 2 || "$2" == -* ]]; then
                echo -e "${RED}Error: -t/--type requires 'nodejs', 'python', or 'auto'${NC}" >&2
                exit 1
            fi
            PROJECT_TYPE="$2"
            if [[ "$PROJECT_TYPE" != "nodejs" && "$PROJECT_TYPE" != "python" && "$PROJECT_TYPE" != "auto" ]]; then
                echo -e "${RED}Error: Type must be 'nodejs', 'python', or 'auto'${NC}" >&2
                exit 1
            fi
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
            echo -e "${RED}Error: Unexpected argument: $1${NC}" >&2
            exit 1
            ;;
    esac
done

# Validate directory exists
if [[ ! -d "$DIR" ]]; then
    echo -e "${RED}Error: Directory does not exist: $DIR${NC}" >&2
    exit 1
fi

# Auto-detect project type if not specified
if [[ -z "$PROJECT_TYPE" || "$PROJECT_TYPE" == "auto" ]]; then
    PROJECT_TYPE=$(detect_project_type "$DIR")
fi

# Output project info (to stderr so it doesn't interfere with JSON output)
if [[ "$FORMAT" != "json" ]]; then
    echo -e "${GREEN}Dead Code Detection${NC}" >&2
    echo -e "  Directory:    $DIR" >&2
    echo -e "  Project type: $PROJECT_TYPE" >&2
    echo -e "  Mode:         $MODE" >&2
    echo "" >&2
fi

# Handle each project type
case "$PROJECT_TYPE" in
    nodejs)
        if ! check_knip; then
            echo -e "${RED}Error: knip is not installed${NC}" >&2
            echo -e "Install with: ${BLUE}npm install -g knip${NC}" >&2
            echo -e "Or use via npx: ${BLUE}npx knip${NC}" >&2
            exit 1
        fi
        run_knip "$DIR" "$MODE" "$FORMAT"
        ;;
    python)
        if ! check_deadcode; then
            echo -e "${RED}Error: deadcode is not installed${NC}" >&2
            echo -e "Install with: ${BLUE}pip install deadcode${NC}" >&2
            exit 1
        fi
        run_deadcode "$DIR" "$MODE" "$FORMAT"
        ;;
    mixed)
        echo -e "${YELLOW}Mixed project detected (Node.js + Python)${NC}" >&2
        echo "" >&2

        NODEJS_OK=true
        PYTHON_OK=true

        if ! check_knip; then
            echo -e "${YELLOW}Warning: knip not available, skipping Node.js analysis${NC}" >&2
            NODEJS_OK=false
        fi

        if ! check_deadcode; then
            echo -e "${YELLOW}Warning: deadcode not available, skipping Python analysis${NC}" >&2
            PYTHON_OK=false
        fi

        if [[ "$NODEJS_OK" == "false" && "$PYTHON_OK" == "false" ]]; then
            echo -e "${RED}Error: No dead code tools available${NC}" >&2
            exit 1
        fi

        if [[ "$NODEJS_OK" == "true" ]]; then
            echo -e "${GREEN}=== Node.js/TypeScript Analysis ===${NC}" >&2
            run_knip "$DIR" "$MODE" "$FORMAT" || true
            echo "" >&2
        fi

        if [[ "$PYTHON_OK" == "true" ]]; then
            echo -e "${GREEN}=== Python Analysis ===${NC}" >&2
            run_deadcode "$DIR" "$MODE" "$FORMAT" || true
        fi
        ;;
    unknown)
        echo -e "${RED}Error: Could not detect project type${NC}" >&2
        echo -e "No package.json, tsconfig.json, requirements.txt, setup.py, or pyproject.toml found." >&2
        echo -e "Use ${BLUE}-t/--type${NC} to specify project type manually." >&2
        exit 1
        ;;
esac

if [[ "$FORMAT" != "json" ]]; then
    echo "" >&2
    echo -e "${GREEN}Done.${NC}" >&2
fi
