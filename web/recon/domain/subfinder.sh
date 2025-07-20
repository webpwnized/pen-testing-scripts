#!/bin/bash
# subfinder.sh

source "$(dirname "$0")/../common/common.sh"
parse_args "$@"
check_dependencies subfinder

if [[ -n "$OUTPUT_FILE" ]]; then
    subfinder -d "$TARGET_DOMAIN" -silent -o "$OUTPUT_FILE"
    [[ $VERBOSE -eq 1 ]] && echo "[+] subfinder complete: $OUTPUT_FILE"
else
    subfinder -d "$TARGET_DOMAIN" -silent
fi

