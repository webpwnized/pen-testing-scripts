#!/bin/bash

TITLE="\nidentify-tcp-services.sh by Jeremy Druin\n"
USAGE="USAGE: $0 [options] <targets or -f file> <ports>

Options:
  -h | --help                    Display this help and exit
  -v | --version                 Display version and exit
  -d | --debug                   Display debug information
  -a | --additional-options OPT  Quoted options passed to NMap
  -l | --scan-localhost          Include localhost in scan
  -n | --project-name NAME       Project name used in output filename (default: my-project)
  -o | --output-directory DIR    Directory for output (default: .)
  -f | --input-file FILE         File with list of targets (used with nmap -iL)
  -r | --resolve                 Enable DNS resolution to show hostnames"

TRUE=1
FALSE=0
RED='\033[1;31m'
NO_COLOR='\033[0m'

SHORTOPTS="hvdln:a:o:f:r"
LONGOPTS="help,version,debug,scan-localhost,project-name:,additional-options:,output-directory:,input-file:,resolve"

PROGNAME="${0##*/}"
PROGVERSION="0.1"

PROJECT_NAME="my-project"
OUTPUT_FILE_PATH="."
INCLUDE_LOCALHOST=$FALSE
DISPLAY_DEBUG_INFORMATION=$FALSE
ADDITIONAL_OPTIONS=""
EXCLUDE_PARAMETER=""
INPUT_FILE=""
IP_ADDRESS_RANGE=""
PORTS=""
RESOLVE_DNS=$FALSE

# Parse arguments
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
    -r|--resolve) RESOLVE_DNS=$TRUE ;;
    --) shift; break ;;
    *) break ;;
  esac
  shift
done

# Remaining args: [target or ports]
if [[ -n "$INPUT_FILE" ]]; then
  if [[ ! -f "$INPUT_FILE" ]]; then
    echo -e "${RED}Error${NO_COLOR}: Input file not found: $INPUT_FILE"
    exit 1
  fi
else
  IP_ADDRESS_RANGE="$1"
  shift
fi

PORTS="$1"
if [[ -z "$PORTS" ]]; then
  echo -e "${RED}Error${NO_COLOR}: Ports required\n\n$USAGE"
  exit 1
fi

# Exclude localhost if requested
if [[ "$INCLUDE_LOCALHOST" -eq "$FALSE" ]]; then
  LOCAL_IPS=$(hostname -I | tr ' ' ',' | sed 's/,$//')
  EXCLUDE_PARAMETER="--exclude ${LOCAL_IPS}"
fi

# DNS resolution toggle
DNS_OPTION="-n"
if [[ "$RESOLVE_DNS" -eq "$TRUE" ]]; then
  DNS_OPTION=""
fi

# Debug output
if [[ "$DISPLAY_DEBUG_INFORMATION" -eq "$TRUE" ]]; then
  echo "Project Name: $PROJECT_NAME"
  echo "Output Dir: $OUTPUT_FILE_PATH"
  echo "Ports: $PORTS"
  echo "Localhost: $INCLUDE_LOCALHOST"
  echo "Exclude: $EXCLUDE_PARAMETER"
  echo "Input File: $INPUT_FILE"
  echo "Direct Target: $IP_ADDRESS_RANGE"
  echo "DNS Resolution: $RESOLVE_DNS"
fi

# Build and run Nmap command
TIMESTAMP=$(date +'%Y-%m-%d-%H-%M')
OUTBASE="$OUTPUT_FILE_PATH/tcp-service-identification-$PROJECT_NAME-$TIMESTAMP"
NMAP_CMD="nmap -Pn -sS -sV -sC $DNS_OPTION -vv --reason --open -p $PORTS $ADDITIONAL_OPTIONS $EXCLUDE_PARAMETER -oA \"$OUTBASE\" --stylesheet=nmap.xsl"

if [[ -n "$INPUT_FILE" ]]; then
  NMAP_CMD="$NMAP_CMD -iL \"$INPUT_FILE\""
else
  NMAP_CMD="$NMAP_CMD $IP_ADDRESS_RANGE"
fi

echo -e "\nRunning Nmap scan..."
echo "$NMAP_CMD"
eval $NMAP_CMD

