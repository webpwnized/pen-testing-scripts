#!/bin/bash

# whois.sh
# Simple: Only outputs non-empty name-value pairs from WHOIS
# Usage: ./whois.sh [options] <domain>

source "$(dirname "$0")/../common/common.sh"

check_dependencies whois timeout
parse_args "$@"

[[ "$VERBOSE" -eq 1 ]] && echo "[*] Querying WHOIS for: $TARGET_DOMAIN"

whois_raw=$(timeout 10s whois "$TARGET_DOMAIN" 2>/dev/null || echo "[!] WHOIS query failed or timed out")

# Keep only lines that contain a colon with a non-empty value
filtered=$(echo "$whois_raw" | awk -F: 'NF > 1 && $2 !~ /^[[:space:]]*$/ { print $1 ":" $2 }')

if [[ -n "$OUTPUT_FILE" ]]; then
    echo "$filtered" > "$OUTPUT_FILE"
    [[ "$VERBOSE" -eq 1 ]] && echo "[+] Output saved to: $OUTPUT_FILE"
else
    echo "$filtered"
fi

