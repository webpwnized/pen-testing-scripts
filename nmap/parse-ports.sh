#!/bin/bash
# parse-ports.sh
# Extracts open TCP ports from an Nmap .gnmap file and outputs as a comma-separated list.

set -euo pipefail

print_help() {
    cat <<EOF
Usage: $(basename "$0") <file.gnmap>

Description:
  Extracts all unique open TCP ports from the specified Nmap grepable output (.gnmap)
  and returns them as a comma-separated list.

Arguments:
  file.gnmap       Path to the Nmap grepable output file.

Example:
  $(basename "$0") scan.gnmap
EOF
}

# Show help if no argument or help requested
if [[ $# -ne 1 || "$1" == "-h" || "$1" == "--help" ]]; then
    print_help
    exit 0
fi

GNMAP_FILE="$1"

if [[ ! -f "$GNMAP_FILE" ]]; then
    echo "[-] Error: File not found: $GNMAP_FILE"
    exit 1
fi

# Extract open ports and format as comma-separated list
grep "Ports:" "$GNMAP_FILE" \
    | sed 's/.*Ports: //' \
    | tr ',' '\n' \
    | grep '/open/' \
    | cut -d'/' -f1 \
    | sort -n \
    | uniq \
    | paste -sd, -

