#!/bin/bash

# Find differences between two files (lines only in one file or the other)

set -euo pipefail

# Usage check
if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <file1> <file2>"
    exit 1
fi

FILE1="$1"
FILE2="$2"

# Ensure both files exist
for file in "$FILE1" "$FILE2"; do
    if [[ ! -f "$file" ]]; then
        echo "Error: File not found - $file"
        exit 1
    fi
done

# Normalize input: remove CRLF, trim whitespace, and sort uniquely
normalize() {
    sed 's/\r$//' "$1" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | grep -v '^$' | sort -u
}

echo "[+] Lines in $FILE1 but not in $FILE2:"
comm -23 <(normalize "$FILE1") <(normalize "$FILE2")
echo

echo "[+] Lines in $FILE2 but not in $FILE1:"
comm -13 <(normalize "$FILE1") <(normalize "$FILE2")

