#!/bin/bash

# crt.sh
# Pulls subdomains from Certificate Transparency logs using crt.sh
# Usage: ./crt.sh [options] <domain>

source "$(dirname "$0")/common.sh"

check_dependencies curl jq
parse_args "$@"

[[ "$VERBOSE" -eq 1 ]] && echo "[*] Querying crt.sh for domain: $TARGET_DOMAIN"

result=$(curl -s "https://crt.sh/?q=%25.$TARGET_DOMAIN&output=json" |
    jq -r '.[].name_value' |
    sed 's/\*\.//g' |
    sort -u)

if [[ "$VERBOSE" -eq 1 ]]; then
    count=$(echo "$result" | wc -l)
    echo "[*] Found $count unique subdomains"
fi

if [[ -n "$OUTPUT_FILE" ]]; then
    echo "$result" > "$OUTPUT_FILE"
    [[ "$VERBOSE" -eq 1 ]] && echo "[+] Results saved to: $OUTPUT_FILE"
else
    echo "$result"
fi

