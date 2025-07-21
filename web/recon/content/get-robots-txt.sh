#!/bin/bash

# get-robots.sh - Safely fetch robots.txt from a domain or full URL

USAGE="Usage: $0 <domain or full URL>"

# Colors
RED='\033[1;31m'
YELLOW='\033[1;33m'
NO_COLOR='\033[0m'

if [[ -z "$1" ]]; then
  echo -e "${RED}Error:${NO_COLOR} No domain or URL provided."
  echo "$USAGE"
  exit 1
fi

INPUT="$1"

# Normalize domain to strip scheme
if [[ "$INPUT" =~ ^https?:// ]]; then
  DOMAIN="${INPUT#http://}"
  DOMAIN="${DOMAIN#https://}"
else
  DOMAIN="$INPUT"
fi

# Try HTTPS first
URL_HTTPS="https://$DOMAIN/robots.txt"
URL_HTTP="http://$DOMAIN/robots.txt"

echo "[*] Trying HTTPS: $URL_HTTPS"
if curl -fsSL --max-time 5 "$URL_HTTPS"; then
  exit 0
fi

# Fall back to HTTP
echo -e "${YELLOW}[!] HTTPS failed. Trying HTTP: $URL_HTTP${NO_COLOR}"
if curl -fsSL --max-time 5 "$URL_HTTP"; then
  exit 0
else
  echo -e "${RED}[-] Failed to retrieve robots.txt from $DOMAIN over both HTTPS and HTTP.${NO_COLOR}" >&2
  exit 2
fi

