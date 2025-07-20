#!/bin/bash
# amass.sh
source "$(dirname "$0")/common.sh"
parse_args "$@"

check_dependencies amass

OUTPUT="amass.txt"
amass enum -d "$TARGET_DOMAIN" -o "$OUTPUT"

if [[ $VERBOSE -eq 1 ]]; then
    echo "[+] amass complete: $OUTPUT"
fi

