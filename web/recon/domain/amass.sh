#!/bin/bash
# amass.sh

source "$(dirname "$0")/../common/common.sh"
parse_args "$@"
check_dependencies amass

if [[ -n "$OUTPUT_FILE" ]]; then
    amass enum -d "$TARGET_DOMAIN" -o "$OUTPUT_FILE"
    [[ $VERBOSE -eq 1 ]] && echo "[+] amass complete: $OUTPUT_FILE"
else
    amass enum -d "$TARGET_DOMAIN"
fi

