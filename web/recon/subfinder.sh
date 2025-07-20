#!/bin/bash
# subfinder.sh
source "$(dirname "$0")/common.sh"
parse_args "$@"

check_dependencies subfinder

OUTPUT="subfinder.txt"
subfinder -d "$TARGET_DOMAIN" -silent -o "$OUTPUT"

if [[ $VERBOSE -eq 1 ]]; then
    echo "[+] subfinder complete: $OUTPUT"
fi

