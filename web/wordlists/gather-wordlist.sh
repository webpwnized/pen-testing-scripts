#!/bin/bash
# Generate a JtR-compatible wordlist using CeWL

set -euo pipefail

show_help() {
    cat <<EOF
Usage: $0 -u <URL> [-d <depth>] [-o <output>]

Options:
  -u | --url <URL>         Target website to crawl (required)
  -d | --depth <int>       Crawl depth (default: 3)
  -o | --output <file>     Output file (default: ./cewl-wordlist.txt)
  -h | --help              Show this help message and exit

Example:
  $0 -u https://intranet.examplecorp.local -d 2 -o wordlist.txt
EOF
}

# Defaults
DEPTH=3
OUTPUT="./cewl-wordlist.txt"
URL=""

# Parse arguments
ARGS=$(getopt -o u:d:o:h --long url:,depth:,output:,help -n "$0" -- "$@")
eval set -- "$ARGS"
while true; do
    case "$1" in
        -u|--url) URL="$2"; shift 2 ;;
        -d|--depth) DEPTH="$2"; shift 2 ;;
        -o|--output) OUTPUT="$2"; shift 2 ;;
        -h|--help) show_help; exit 0 ;;
        --) shift; break ;;
        *) echo "Unexpected option: $1" >&2; show_help; exit 1 ;;
    esac
done

# Validate URL
if [[ -z "$URL" ]]; then
    echo "[-] Error: URL is required"
    show_help
    exit 1
fi

# Check cewl dependency
if ! command -v cewl >/dev/null 2>&1; then
    echo "[-] Error: CeWL is not installed. Install it and try again."
    exit 1
fi

# Run CeWL and post-process
echo "[*] Crawling $URL to depth $DEPTH..."
TMP=$(mktemp)
cewl "$URL" -d "$DEPTH" --with-numbers -w "$TMP"

# Clean and deduplicate for JtR compatibility
awk 'length > 3' "$TMP" | tr '[:upper:]' '[:lower:]' | sort -u > "$OUTPUT"
rm "$TMP"

echo "[+] Wordlist saved to: $OUTPUT"

