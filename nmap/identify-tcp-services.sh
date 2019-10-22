#!/bin/sh

TITLE="\identify-tcp-services.sh by Jeremy Druin\n"
USAGE="USAGE: ./identify-tcp-services.sh [options] [target(s) or range(s)] [ports]

Options:
\t-h | --help\t\tDisplay this help and exit
\t-v | --version\t\tDisplay version and exit
\t-d | --debug\t\tDisplay debug information
\t-a | --additional-options\tEscaped/quoted options passed to NMap
\t-l | --scan-localhost\tInclude localhost in scan
\t-n | --project-name <project name>\tProject name used in output file name
\t-o | --output-directory <output file path>\tDirectory in which output will be saved\n"

TRUE=-1
FALSE=0
RED='\033[1;31m'
NO_COLOR='\033[0m'

SHORTOPTS="hvdln:a:o:"
LONGOPTS="help,version,debug,scan-localhost,project-name:,additional-options:,output-directory:"
PROGNAME=${0##*/}
PROGVERSION=0.1
IP_ADDRESS_RANGE=""
PROJECT_NAME="my-project"
OUTPUT_FILE_PATH="."
INCLUDE_LOCALHOST=$FALSE
DISPLAY_DEBUG_INFORMATION=$FALSE
EXCLUDE_PARAMETER=""
ADDITIONAL_OPTIONS=""
PORTS=""

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
-l | --scan-localhost) INCLUDE_LOCALHOST=$TRUE;;
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
IP_ADDRESS_RANGE=$1
PORTS=$2

#Debug info
if [ $DISPLAY_DEBUG_INFORMATION -eq $TRUE ]; then
echo ""
echo "IP Address Range: ${IP_ADDRESS_RANGE}"
echo "Project Name: ${PROJECT_NAME}"
echo "Output File Path: ${OUTPUT_FILE_PATH}"
echo "Include Localhost: ${INCLUDE_LOCALHOST}"
echo "Exclude Parameter: ${EXCLUDE_PARAMETER}"
fi

# Verify ip address range provided
if [ -z "$IP_ADDRESS_RANGE" ]; then
echo "\n${RED}Error${NO_COLOR}: IP address range or hostname required\n"
echo "$USAGE"
exit 1;
fi

# Verify ip address range provided
if [ -z "$PORTS" ]; then
echo "\n${RED}Error${NO_COLOR}: Ports required\n"
echo "$USAGE"
exit 1;
fi

# By default we exclude localhost (this computer) from the scan
if [ $INCLUDE_LOCALHOST -eq $FALSE ]; then
# Determine the IP addresses of this host
THIS_HOSTS_IP_ADDRESSES=$(hostname -I | sed -e 's/[[:space:]]*$//' | tr " " ",")
EXCLUDE_PARAMETER="--exclude ${THIS_HOSTS_IP_ADDRESSES}"
fi

# Beginning of output
echo ""
echo "Scanning subnet ${IP_ADDRESS_RANGE}"
if [ $INCLUDE_LOCALHOST -eq $FALSE ]; then
echo "Excluding IP address ranges ${THIS_HOSTS_IP_ADDRESSES}"
fi
echo ""

echo "Running the following nmap command..."
echo "nmap -Pn -sS -sV -sC -n -vv --reason --open -p ${PORTS} ${ADDITIONAL_OPTIONS} ${EXCLUDE_PARAMETER} -oA $OUTPUT_FILE_PATH/tcp-service-identification-$PROJECT_NAME-$(date +'%Y-%m-%d-%H-%M') --stylesheet=nmap.xsl $IP_ADDRESS_RANGE"

nmap -Pn -sS -sV -sC -n -vv --reason --open -p ${PORTS} ${ADDITIONAL_OPTIONS} ${EXCLUDE_PARAMETER} -oA $OUTPUT_FILE_PATH/tcp-service-identification-$PROJECT_NAME-$(date +'%Y-%m-%d-%H-%M') --stylesheet=nmap.xsl $IP_ADDRESS_RANGE
