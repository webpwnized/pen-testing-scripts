#!/bin/bash

# Convert Nmap XML output to styled HTML using xsltproc

set -euo pipefail

print_usage() {
    echo "Usage: $0 <nmap-xml-file>"
    echo "Converts Nmap XML output to HTML using xsltproc and nmap.xsl."
    echo
    echo "Options:"
    echo "  -h, --help    Show this help message"
    echo
    echo "Example:"
    echo "  $0 tcp-scan.xml"
    exit 1
}

# Help flag support
if [[ $# -eq 0 || "$1" == "-h" || "$1" == "--help" ]]; then
    print_usage
fi

XML_FILE="$1"
BASENAME="$(basename "$XML_FILE" .xml)"
OUTPUT_FILE="${BASENAME}.html"

# Check for xsltproc
if ! command -v xsltproc &>/dev/null; then
    echo "[-] Error: xsltproc is not installed. Please install it and try again."
    exit 1
fi

# Verify the XML file exists
if [[ ! -f "$XML_FILE" ]]; then
    echo "[-] Error: File not found: $XML_FILE"
    exit 1
fi

# Try to locate nmap.xsl in common locations
XSL_PATHS=(
    "./nmap.xsl"
    "$(dirname "$XML_FILE")/nmap.xsl"
    "/usr/share/nmap/nmap.xsl"
    "/usr/local/share/nmap/nmap.xsl"
)

FOUND_XSL=""

for path in "${XSL_PATHS[@]}"; do
    if [[ -f "$path" ]]; then
        FOUND_XSL="$path"
        break
    fi
done

if [[ -z "$FOUND_XSL" ]]; then
    echo "[-] Error: Could not find nmap.xsl. Please place it in the same folder or install nmap."
    exit 1
fi

echo "[*] Using XSL stylesheet: $FOUND_XSL"
echo "[*] Converting $XML_FILE to $OUTPUT_FILE"

xsltproc "$FOUND_XSL" "$XML_FILE" > "$OUTPUT_FILE"

echo "[+] Done. Open $OUTPUT_FILE in a browser to view the report."

