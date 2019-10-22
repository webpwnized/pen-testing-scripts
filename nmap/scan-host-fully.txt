#!/bin/sh

TITLE="\scan-host-fully.sh by Jeremy Druin\n"
USAGE="USAGE: ./scan-host-fully.sh [options] [ip-address | hostname]

Options:
\t-h | --help\t\tDisplay this help and exit
\t-v | --version\t\tDisplay version and exit
\t-d | --debug\t\tDisplay debug information
\t-a | --additional-options\tEscaped/quoted options passed to NMap
\t-n | --project-name <project name>\tProject name used in output file name
\t-o | --output-directory <output file path>\tDirectory in which output will be saved\n"

TRUE=-1
FALSE=0
RED='\033[1;31m'
NO_COLOR='\033[0m'

SHORTOPTS="hvdn:a:o:"
LONGOPTS="help,version,debug,project-name:,additional-options:,output-directory:"
PROGNAME=${0##*/}
PROGVERSION=0.1
IP_ADDRESS
PROJECT_NAME="my-project"
OUTPUT_FILE_PATH="."
DISPLAY_DEBUG_INFORMATION=$FALSE
EXCLUDE_PARAMETER=""
ADDITIONAL_OPTIONS=""

if [ $? != 0 ]; then
echo "$USAGE"
exit 1
fi

ARGS=$(getopt -s bash --options $SHORTOPTS --longoptions $LONGOPTS --name $PROGNAME -- "$@" )

eval set -- "$ARGS"

while true; do
case $1 in
-h | --help) echo "${TITLE}"; echo "${USAGE}"; exit 0;;
-v | --version) echo "${PROGVERSION}"; exit 0;;
-d | --debug) DISPLAY_DEBUG_INFORMATION=$TRUE;;
-n | --project-name) PROJECT_NAME=$2; shift;;
-a | --additional-options) ADDITIONAL_OPTIONS=$2; shift;;
-o | --output-directory) OUTPUT_FILE_PATH=$2; shift;;
--) shift; break;;
*) break;;
esac
shift
done

#Final argument is required to be the target(s)
shift $(($OPTIND - 1))
IP_ADDRESS=$1

#Debug info
if [ $DISPLAY_DEBUG_INFORMATION -eq $TRUE ]; then
echo ""
echo "IP Address Range: ${IP_ADDRESS}"
echo "Project Name: ${PROJECT_NAME}"
echo "Output File Path: ${OUTPUT_FILE_PATH}"
fi

# Verify ip address provided
if [ -z "$IP_ADDRESS" ]; then
echo "\n${RED}Error${NO_COLOR}: IP address or hostname required\n"
echo "$USAGE"
exit 1;
fi

# Beginning of output
echo ""
echo "Scanning ${IP_ADDRESS}"
echo ""

echo "Running the following nmap command..."
echo "nmap -Pn -sS -sV -sC -vv --reason --open -p- ${ADDITIONAL_OPTIONS} -oA $OUTPUT_FILE_PATH/full-tcp-scan-$PROJECT_NAME-$(date +'%Y-%m-%d-%H-%M') --stylesheet=nmap.xsl $IP_ADDRESS"

nmap -Pn -sS -sV -sC -vv --reason --open -p- ${ADDITIONAL_OPTIONS} -oA $OUTPUT_FILE_PATH/full-tcp-scan-$PROJECT_NAME-$(date +'%Y-%m-%d-%H-%M') --stylesheet=nmap.xsl $IP_ADDRESS

echo "Running the following nmap command..."
echo "nmap -Pn -sU -sV -sC -vv --reason --open ${ADDITIONAL_OPTIONS} -oA $OUTPUT_FILE_PATH/full-udp-scan-$PROJECT_NAME-$(date +'%Y-%m-%d-%H-%M') --stylesheet=nmap.xsl $IP_ADDRESS"

nmap -Pn -sU -sV -sC -vv --reason --open ${ADDITIONAL_OPTIONS} -oA $OUTPUT_FILE_PATH/full-udp-scan-$PROJECT_NAME-$(date +'%Y-%m-%d-%H-%M') --stylesheet=nmap.xsl $IP_ADDRESS



