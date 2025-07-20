#!/bin/bash

# common.sh
# Shared utilities for recon scripts

set -euo pipefail

SCRIPT_NAME="$(basename "$0")"

VERBOSE=0
OUTPUT_FILE=""
TARGET_DOMAIN=""

check_dependencies() {
    for dep in "$@"; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            echo "[-] Error: '$dep' is required but not installed."
            exit 1
        fi
    done
}

validate_domain() {
    local domain="$1"
    if ! [[ "$domain" =~ ^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        echo "[-] Error: Invalid domain format: $domain"
        exit 1
    fi
}

print_help() {
    cat <<EOF
Usage: $SCRIPT_NAME [OPTIONS] <domain>

Options:
  -h, --help          Show this help message and exit
  -o, --output FILE   Save results to the specified file
  -v, --verbose       Enable verbose output

Examples:
  $SCRIPT_NAME example.com
  $SCRIPT_NAME -v -o results.txt example.com
EOF
}

parse_args() {
    local args=()
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                print_help; exit 0;;
            -o|--output)
                OUTPUT_FILE="$2"; shift 2;;
            -v|--verbose)
                VERBOSE=1; shift;;
            -*)
                echo "[-] Unknown option: $1"; exit 1;;
            *)
                args+=("$1"); shift;;
        esac
    done

    if [[ ${#args[@]} -ne 1 ]]; then
        echo "[-] Error: Missing required domain argument"
        echo "Try '$SCRIPT_NAME --help' for usage."
        exit 1
    fi

    TARGET_DOMAIN="${args[0]}"
    validate_domain "$TARGET_DOMAIN"
}

