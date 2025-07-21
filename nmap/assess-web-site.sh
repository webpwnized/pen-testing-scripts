#!/bin/bash

TITLE="\nassess-web-site.sh by Jeremy Druin\n"
USAGE="USAGE: $0 [options] <target(s)> <ports>

Options:
  -h | --help                      Display this help and exit
  -v | --version                   Display version and exit
  -d | --debug                     Display debug information
  -a | --additional-options OPT    Quoted options passed to NMap
  -l | --scan-localhost            Include localhost in scan
  -n | --project-name NAME         Project name used in output filename (default: my-project)
  -o | --output-directory DIR      Directory for output (default: .)
  -f | --input-file FILE           File with list of targets (used with nmap -iL)"

TRUE=1
FALSE=0
RED='\033[1;31m'
YELLOW='\033[1;33m'
NO_COLOR='\033[0m'

SHORTOPTS="hvdln:a:o:f:"
LONGOPTS="help,version,debug,scan-localhost,project-name:,additional-options:,output-directory:,input-file:"

PROGNAME="${0##*/}"
PROGVERSION="0.4"
PROJECT_NAME="my-project"
OUTPUT_FILE_PATH="."
INCLUDE_LOCALHOST=$FALSE
DISPLAY_DEBUG_INFORMATION=$FALSE
ADDITIONAL_OPTIONS=""
EXCLUDE_PARAMETER=""
INPUT_FILE=""
IP_ADDRESS_RANGE=""
PORTS=""

ARGS=$(getopt -o "$SHORTOPTS" -l "$LONGOPTS" -- "$@") || { echo "$USAGE"; exit 1; }
eval set -- "$ARGS"
while true; do
  case "$1" in
    -h|--help) echo -e "$TITLE"; echo "$USAGE"; exit 0 ;;
    -v|--version) echo "$PROGVERSION"; exit 0 ;;
    -d|--debug) DISPLAY_DEBUG_INFORMATION=$TRUE ;;
    -l|--scan-localhost) INCLUDE_LOCALHOST=$TRUE ;;
    -n|--project-name) PROJECT_NAME="$2"; shift ;;
    -a|--additional-options) ADDITIONAL_OPTIONS="$2"; shift ;;
    -o|--output-directory) OUTPUT_FILE_PATH="$2"; shift ;;
    -f|--input-file) INPUT_FILE="$2"; shift ;;
    --) shift; break ;;
    *) break ;;
  esac
  shift
done

# Input target or file
if [[ -n "$INPUT_FILE" ]]; then
  [[ ! -f "$INPUT_FILE" ]] && { echo -e "${RED}Error${NO_COLOR}: Input file not found: $INPUT_FILE"; exit 1; }
else
  IP_ADDRESS_RANGE="$1"
  shift
fi

# Ports
PORTS="$1"
if [[ -z "$PORTS" ]]; then
  echo -e "${YELLOW}Warning${NO_COLOR}: Ports required. Setting ports to 80 and 443"
  PORTS="80,443"
fi

# Exclude localhost unless told otherwise
if [[ "$INCLUDE_LOCALHOST" -eq "$FALSE" ]]; then
  LOCAL_IPS=$(hostname -I | tr ' ' ',' | sed 's/,$//')
  EXCLUDE_PARAMETER="--exclude ${LOCAL_IPS}"
fi

[[ "$DISPLAY_DEBUG_INFORMATION" -eq "$TRUE" ]] && {
  echo "Project Name: $PROJECT_NAME"
  echo "Output Dir: $OUTPUT_FILE_PATH"
  echo "Ports: $PORTS"
  echo "Input File: $INPUT_FILE"
  echo "Direct Target: $IP_ADDRESS_RANGE"
  echo "Exclude: $EXCLUDE_PARAMETER"
}

# Safe web-focused scripts (no args, no brute force, useful to HTTP/SSL)
SAFE_WEB_SCRIPTS=(
  http-title
  http-methods
  http-server-header
  http-headers
  http-security-headers
  http-cookie-flags
  http-robots.txt
  http-favicon
  http-cors
  http-php-version
  http-trace
  ssl-cert
  ssl-date
  http-date
  http-ntlm-info
)

SCRIPT_ARG="--script=$(IFS=,; echo "${SAFE_WEB_SCRIPTS[*]}")"

TIMESTAMP=$(date +'%Y-%m-%d-%H-%M')
OUTBASE="$OUTPUT_FILE_PATH/web-site-vulnerabilities-$PROJECT_NAME-$TIMESTAMP"

NMAP_CMD="nmap -Pn -sS -sV -n -vv --reason --open -p $PORTS $SCRIPT_ARG $ADDITIONAL_OPTIONS $EXCLUDE_PARAMETER -oA \"$OUTBASE\" --stylesheet=nmap.xsl"

if [[ -n "$INPUT_FILE" ]]; then
  NMAP_CMD="$NMAP_CMD -iL \"$INPUT_FILE\""
else
  NMAP_CMD="$NMAP_CMD $IP_ADDRESS_RANGE"
fi

echo -e "\n[*] Running Nmap command:"
echo "$NMAP_CMD"
eval "$NMAP_CMD"

