#!/bin/bash

set -u
set -o pipefail

print_help() {
    cat <<EOF

Usage: $(basename "$0") [OPTIONS] <URL>

Downloads a website and extracts from .html and .htm files:
  - HTML comments
  - Email addresses
  - Twitter handles
  - Absolute URLs

OPTIONS:
  -k, --keep-files     Keep temporary directory after script completes
  -d, --debug          Show debug, info, and wget output
  -h, --help           Show this help message and exit

EXAMPLES:
  $(basename "$0") https://example.com
      Crawl https://example.com and print findings.

  $(basename "$0") -k -d https://example.com
      Crawl with debug output and preserve temp directory.

EOF
}

# ========= Parse arguments =========
KEEP_TEMP=false
DEBUG=false
POSITIONAL_ARGS=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        -k|--keep-files)
            KEEP_TEMP=true
            shift
            ;;
        -d|--debug)
            DEBUG=true
            shift
            ;;
        -h|--help)
            print_help
            exit 0
            ;;
        -*)
            echo "[ERROR] Unknown option: $1" >&2
            print_help
            exit 1
            ;;
        *)
            POSITIONAL_ARGS+=("$1")
            shift
            ;;
    esac
done

if [ ${#POSITIONAL_ARGS[@]} -lt 1 ]; then
    echo "[ERROR] No URL provided." >&2
    print_help
    exit 1
fi

TARGET_URL="${POSITIONAL_ARGS[0]}"

log_debug() {
    if [ "$DEBUG" = true ]; then
        echo "[DEBUG] $(date '+%Y-%m-%d %H:%M:%S') - $*"
    fi
}

log_info() {
    if [ "$DEBUG" = true ]; then
        echo "[INFO]  $(date '+%Y-%m-%d %H:%M:%S') - $*"
    fi
}

log_wget() {
    if [ "$DEBUG" = true ]; then
        sed 's/^/[wget] /' "$1"
    fi
}

log_error() {
    echo "[ERROR] $(date '+%Y-%m-%d %H:%M:%S') - $*" >&2
}

log_debug "Provided URL: $TARGET_URL"

# ========= Extract domain =========
DOMAIN=$(echo "$TARGET_URL" | awk -F[/:] '{print $4}')
if [ -z "$DOMAIN" ]; then
    log_error "Could not extract domain from: $TARGET_URL"
    exit 1
fi
log_debug "Extracted domain: $DOMAIN"

# ========= Create temp directory =========
TEMP_DIR=$(mktemp -d "/tmp/tmp.XXXXXX.$DOMAIN")
if [ ! -d "$TEMP_DIR" ]; then
    log_error "Failed to create temp dir"
    exit 1
fi
log_debug "Created temp dir: $TEMP_DIR"

cd "$TEMP_DIR" 2>/dev/null
if [ "$PWD" != "$TEMP_DIR" ]; then
    log_error "Failed to cd into $TEMP_DIR"
    exit 1
fi
log_debug "Changed into directory: $PWD"

# ========= Start wget crawl =========
WGET_LOG="$TEMP_DIR/wget.log"
log_info "Crawling site: $TARGET_URL"

wget \
  --recursive \
  --level=2 \
  --no-parent \
  --convert-links \
  --adjust-extension \
  --user-agent="Mozilla/5.0 (X11; Linux x86_64)" \
  --timeout=15 \
  --wait=1 \
  --accept=html,htm \
  "$TARGET_URL" >"$WGET_LOG" 2>&1

WGET_CODE=$?
if [ "$WGET_CODE" -ne 0 ]; then
    log_info "wget exited with code $WGET_CODE"
    log_wget "$WGET_LOG"
else
    log_debug "wget completed successfully"
fi

MATCHED=$(find . -type f \( -iname '*.html' -o -iname '*.htm' \) | wc -l)
if [ "$MATCHED" -eq 0 ]; then
    log_error "No HTML files were downloaded. Aborting."
    $KEEP_TEMP || rm -rf "$TEMP_DIR"
    exit 1
fi
log_debug "Matching HTML files downloaded: $MATCHED"

# ========= Extract useful data =========
FOUND=false
while IFS= read -r -d '' file; do
    COMMENTS=$(grep -Eo '<!--.*?-->' "$file" || true)
    EMAILS=$(grep -Eoi '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}' "$file" | sort -u || true)
    TWITTERS=$(grep -Eo '@[A-Za-z0-9_]{1,15}' "$file" | grep -v '^@import' | sort -u || true)
    URLS=$(grep -Eo 'https?://[^"]+' "$file" | sort -u || true)

    if [[ -n "$COMMENTS" || -n "$EMAILS" || -n "$TWITTERS" || -n "$URLS" ]]; then
        FOUND=true
        echo
        echo "=== $(realpath "$file") ==="

        [[ -n "$COMMENTS" ]]  && echo && echo "[COMMENTS]" && echo "$COMMENTS"
        [[ -n "$EMAILS" ]]    && echo && echo "[EMAILS]" && echo "$EMAILS"
        [[ -n "$TWITTERS" ]]  && echo && echo "[TWITTER HANDLES]" && echo "$TWITTERS"
        [[ -n "$URLS" ]]      && echo && echo "[URLS]" && echo "$URLS"
    fi
done < <(find . -type f \( -iname '*.html' -o -iname '*.htm' \) -print0)

if [ "$FOUND" = false ] && [ "$DEBUG" = true ]; then
    log_info "No interesting content found"
fi

# ========= Cleanup =========
if [ "$KEEP_TEMP" = true ]; then
    log_info "Temp directory preserved: $TEMP_DIR"
else
    rm -rf "$TEMP_DIR"
    log_debug "Temp directory removed"
fi

