#!/bin/bash
# assetfinder.sh

source "$(dirname "$0")/../common/common.sh"
parse_args "$@"
check_dependencies assetfinder

if [[ -n "$OUTPUT_FILE" ]]; then
    assetfinder --subs-only "$TARGET_DOMAIN" > "$OUTPUT_FILE"
    [[ $VERBOSE -eq 1 ]] && echo "[+] assetfinder complete: $OUTPUT_FILE"
else
    assetfinder --subs-only "$TARGET_DOMAIN"
fi

