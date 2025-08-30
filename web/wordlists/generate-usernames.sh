#!/bin/bash

set -u
set -o pipefail

# Ensure exactly one argument
if [[ $# -ne 1 ]]; then
    echo "[ERROR] Usage: $0 names.txt" >&2
    exit 1
fi

INPUT_FILE="$1"

# Validate input file exists
if [[ ! -f "$INPUT_FILE" ]]; then
    echo "[ERROR] File not found: $INPUT_FILE" >&2
    exit 1
fi

declare -A seen

while IFS= read -r line || [[ -n "$line" ]]; do
    # Trim whitespace
    line="$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"

    # Skip empty lines or lines with < 2 words
    if [[ -z "$line" || "$line" =~ ^# ]]; then
        continue
    fi

    word_count=$(echo "$line" | wc -w)
    if [[ "$word_count" -lt 2 ]]; then
        echo "[WARN] Skipping malformed line: '$line'" >&2
        continue
    fi

    first=$(echo "$line" | awk '{print tolower($1)}')
    last=$(echo "$line" | awk '{print tolower($NF)}')

    f=${first:0:1}
    l=${last:0:1}

    for u in \
        "${first}${last}" \
        "${first}.${last}" \
        "${first}_${last}" \
        "${f}${last}" \
        "${first}${l}" \
        "${last}${f}" \
        "${last}.${first}" \
        "${last}${first}" \
        "${f}.${last}" \
        "${first}" \
        "${last}"
    do
        if [[ -z "${seen[$u]+_}" ]]; then
            echo "$u"
            seen["$u"]=1
        fi
    done
done < "$INPUT_FILE"

