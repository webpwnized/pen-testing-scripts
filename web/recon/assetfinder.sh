#!/bin/bash
# assetfinder.sh
source "$(dirname "$0")/common.sh"
parse_args "$@"

check_dependencies assetfinder

OUTPUT="assetfinder.txt"
assetfinder --subs-only "$TARGET_DOMAIN" > "$OUTPUT"

if [[ $VERBOSE -eq 1 ]]; then
    echo "[+] assetfinder complete: $OUTPUT"
fi

