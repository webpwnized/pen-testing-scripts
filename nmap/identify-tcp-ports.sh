#!/bin/sh

TITLE="\nidentify-tcp-ports.sh by Jeremy Druin\n"
USAGE="USAGE: ./identify-tcp-ports.sh [options] [target(s) or range(s)]

Options:
  -h | --help                    Display this help and exit
  -v | --version                 Display version and exit
  -d | --debug                   Display debug information
  -a | --additional-options OPT  Quoted options passed to Nmap
  -l | --scan-localhost          Include localhost in scan
  -n | --project-name NAME       Project name used in output file name (default: my-project)
  -o | --output-directory DIR    Output directory (default: current directory)
  -f | --input-file FILE         Read list of IPs/domains from file
       --full-port-scan          Scan all 65535 ports instead of top 1000
"

TRUE=-1
FALSE=0
RED='\033[1;31m'
NO_COLOR='\033[0m'

SHORTOPTS="hvdln:a:o:f:"
LONGOPTS="help,version,debug,scan-localhost,project-name:,additional-options:,output-directory:,input-file:,full-port-scan"
PROGNAME=${0##*/}
PROGVERSION="0.3"

# Defaults
PROJECT_NAME="my-project"
OUTPUT_FILE_PATH="."
INCLUDE_LOCALHOST=$FALSE
DISPLAY_DEBUG_INFORMATION=$FALSE
EXCLUDE_PARAMETER=""
ADDITIONAL_OPTIONS=""
FULL_PORT_SCAN=$FALSE
INPUT_FILE=""
TARGET_ARG=""

# Parse arguments
ARGS=$(getopt -s bash --options $SHORTOPTS --longoptions $LONGOPTS --name $PROGNAME -- "$@")
if [ $? != 0 ]; then echo "$USAGE"; exit 1; fi
eval set -- "$ARGS"

while true; do
  case "$1" in
    -h|--help) echo "$TITLE"; echo "$USAGE"; exit 0;;
    -v|--version) echo "$PROGVERSION"; exit 0;;
    -d|--debug) DISPLAY_DEBUG_INFORMATION=$TRUE;;
    -l|--scan-localhost) INCLUDE_LOCALHOST=$TRUE;;
    -n|--project-name) PROJECT_NAME="$2"; shift;;
    -a|--additional-options) ADDITIONAL_OPTIONS="$2"; shift;;
    -o|--output-directory) OUTPUT_FILE_PATH="$2"; shift;;
    -f|--input-file) INPUT_FILE="$2"; shift;;
    --full-port-scan) FULL_PORT_SCAN=$TRUE;;
    --) shift; break;;
    *) break;;
  esac
  shift
done

# If no input file, treat last argument as target
if [ -z "$INPUT_FILE" ]; then
  if [ $# -lt 1 ]; then
    echo "\n${RED}Error${NO_COLOR}: IP address, hostname, or input file is required\n"
    echo "$USAGE"
    exit 1
  fi
  TARGET_ARG="$1"
else
  if [ ! -f "$INPUT_FILE" ]; then
    echo "${RED}Error${NO_COLOR}: input file '$INPUT_FILE' not found"
    exit 1
  fi
  TARGET_ARG="-iL $INPUT_FILE"
fi

# Exclude localhost unless requested
if [ $INCLUDE_LOCALHOST -eq $FALSE ]; then
  THIS_HOSTS_IP_ADDRESSES=$(hostname -I | sed -e 's/[[:space:]]*$//' | tr " " ",")
  EXCLUDE_PARAMETER="--exclude ${THIS_HOSTS_IP_ADDRESSES}"
fi

# Determine port scan type
NMAP_PORT_ARGUMENT="--top-ports 1000"
[ $FULL_PORT_SCAN -eq $TRUE ] && NMAP_PORT_ARGUMENT="-p-"

# Timestamp for output
TIMESTAMP=$(date +'%Y-%m-%d-%H-%M')
OUTPUT_FILE="$OUTPUT_FILE_PATH/tcp-port-identification-$PROJECT_NAME-$TIMESTAMP"

# Debug output
if [ $DISPLAY_DEBUG_INFORMATION -eq $TRUE ]; then
  echo ""
  echo "Project Name: $PROJECT_NAME"
  echo "Output Directory: $OUTPUT_FILE_PATH"
  echo "Target Source: ${INPUT_FILE:-direct argument}"
  echo "Target: $TARGET_ARG"
  echo "Exclude Localhost: $([ $INCLUDE_LOCALHOST -eq $TRUE ] && echo "No" || echo "Yes - $THIS_HOSTS_IP_ADDRESSES")"
  echo "Full Port Scan: $([ $FULL_PORT_SCAN -eq $TRUE ] && echo "Yes" || echo "No")"
  echo "Additional Options: $ADDITIONAL_OPTIONS"
  echo "Output File: $OUTPUT_FILE"
  echo ""
fi

# Announce and run scan
echo ""
echo "Running Nmap..."
echo "nmap -Pn -sS -n -vv --reason --open $NMAP_PORT_ARGUMENT $ADDITIONAL_OPTIONS $EXCLUDE_PARAMETER -oA \"$OUTPUT_FILE\" --stylesheet=nmap.xsl $TARGET_ARG"
echo ""

nmap -Pn -sS -n -vv --reason --open $NMAP_PORT_ARGUMENT $ADDITIONAL_OPTIONS $EXCLUDE_PARAMETER -oA "$OUTPUT_FILE" --stylesheet=nmap.xsl $TARGET_ARG

