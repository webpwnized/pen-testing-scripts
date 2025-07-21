#!/bin/bash

set -u

echo
echo "========== STEP: Validating input =========="

if [ $# -lt 1 ]; then
    echo "[ERROR] $(date '+%Y-%m-%d %H:%M:%S') - Usage: $0 <URL> [--keep]"
    exit 1
fi

TARGET_URL="$1"
KEEP_TEMP=false
if [[ "${2:-}" == "--keep" ]]; then
    KEEP_TEMP=true
fi

echo "[DEBUG] $(date '+%Y-%m-%d %H:%M:%S') - Provided URL: $TARGET_URL"

echo
echo "========== STEP: Extracting domain =========="

DOMAIN=$(echo "$TARGET_URL" | awk -F[/:] '{print $4}')
if [ -z "$DOMAIN" ]; then
    echo "[ERROR] $(date '+%Y-%m-%d %H:%M:%S') - Could not extract domain from: $TARGET_URL"
    exit 1
fi
echo "[DEBUG] $(date '+%Y-%m-%d %H:%M:%S') - Extracted domain: $DOMAIN"

echo
echo "========== STEP: Creating temporary directory =========="

TEMP_DIR=$(mktemp -d "/tmp/tmp.XXXXXX.$DOMAIN")
if [ ! -d "$TEMP_DIR" ]; then
    echo "[ERROR] $(date '+%Y-%m-%d %H:%M:%S') - Failed to create temp dir"
    exit 1
fi
echo "[DEBUG] $(date '+%Y-%m-%d %H:%M:%S') - Created temp dir: $TEMP_DIR"

echo
echo "========== STEP: Changing into temp directory =========="

cd "$TEMP_DIR" 2>/dev/null
if [ "$PWD" != "$TEMP_DIR" ]; then
    echo "[ERROR] $(date '+%Y-%m-%d %H:%M:%S') - Failed to cd into $TEMP_DIR"
    exit 1
fi
echo "[DEBUG] $(date '+%Y-%m-%d %H:%M:%S') - Current directory: $PWD"

echo
echo "========== STEP: Starting wget crawl of $TARGET_URL =========="
echo "[INFO]  $(date '+%Y-%m-%d %H:%M:%S') - Crawling site: $TARGET_URL"

WGET_LOG="$TEMP_DIR/wget.log"

wget \
  --recursive \
  --level=2 \
  --no-parent \
  --convert-links \
  --adjust-extension \
  --user-agent="Mozilla/5.0 (X11; Linux x86_64)" \
  --timeout=15 \
  --wait=1 \
  --accept=html,htm,js,css \
  "$TARGET_URL" >"$WGET_LOG" 2>&1

WGET_CODE=$?

echo
echo "========== STEP: Checking wget outcome =========="
if [ "$WGET_CODE" -ne 0 ]; then
    echo "[WARN]  $(date '+%Y-%m-%d %H:%M:%S') - wget exited with code $WGET_CODE"
    echo "[INFO]  $(date '+%Y-%m-%d %H:%M:%S') - wget.log output:"
    sed 's/^/[wget] /' "$WGET_LOG"
else
    echo "[INFO]  $(date '+%Y-%m-%d %H:%M:%S') - wget completed with code 0"
fi

MATCHED=$(find . -type f \( -iname '*.html' -o -iname '*.htm' \) | wc -l)
if [ "$MATCHED" -eq 0 ]; then
    echo "[ERROR] $(date '+%Y-%m-%d %H:%M:%S') - No HTML files were downloaded. Aborting."
    $KEEP_TEMP || rm -rf "$TEMP_DIR"
    exit 1
fi

echo "[DEBUG] $(date '+%Y-%m-%d %H:%M:%S') - Matching files downloaded: $MATCHED"

echo
echo "========== STEP: Searching for HTML comments =========="

FOUND=false
while IFS= read -r -d '' file; do
    echo
    echo "=== $(realpath "$file") ==="
    grep -Eo '<!--.*?-->' "$file" && FOUND=true
done < <(find . -type f \( -iname '*.html' -o -iname '*.htm' \) -print0)

$FOUND || echo "[INFO] $(date '+%Y-%m-%d %H:%M:%S') - No HTML comments found"

echo
echo "========== STEP: Cleanup =========="

if [ "$KEEP_TEMP" = true ]; then
    echo "[INFO] $(date '+%Y-%m-%d %H:%M:%S') - Temp directory preserved: $TEMP_DIR"
else
    rm -rf "$TEMP_DIR"
    echo "[INFO] $(date '+%Y-%m-%d %H:%M:%S') - Temp directory removed"
fi

