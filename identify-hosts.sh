#!/bin/sh

TITLE="\nidentify-hosts.sh by Jeremy Druin\n"
USAGE="USAGE: ./identify-hosts.sh [options] [target(s) or range(s)]"

Options:
\t-h | --help\t\tDisplay this help and exit
\t-v | --version\t\tDisplay version and exit
\t-d | --debug\t\tDisplay debug information
\t-l | --scan-localhost\tInclude localhost in scan
\t-n | --project-name <project name>\tProject name used in output file name
\t-o | --output-directory <output file path>\tDirectory in which output will be saved\n"

TRUE=-1
FALSE=0
RED='\033[1;31m'
NO_COLOR='\033[0m'

SHORTOPTS="hvdln:o:"
LONGOPTS="help,version,debug,scan-localhost,project-name:,output-directory:"
PROGNAME=${0##*/}
PROGVERSION=0.1
IP_ADDRESS_RANGE=""
PROJECT_NAME="my-project"
OUTPUT_FILE_PATH="."	# If output file path is not provided, default to current directory
INCLUDE_LOCALHOST=$FALSE
DISPLAY_DEBUG_INFORMATION=$FALSE
EXCLUDE_PARAMETER=""

ARGS=$(getopt -s bash --options $SHORTOPTS --longoptions $LONGOPTS --name $PROGNAME -- "$@" )

eval set -- "$ARGS"

while true; do
case $1 in
-h | --help) echo "${TITLE}"; echo "${USAGE}"; exit 0;;
-v | --version) echo "${PROGVERSION}"; exit 0;;
-d | --debug) DISPLAY_DEBUG_INFORMATION=$TRUE;;
-l | --scan-localhost) INCLUDE_LOCALHOST=$TRUE;;
-n | --project-name) PROJECT_NAME=$2; shift;;
-o | --output-directory) OUTPUT_FILE_PATH=$2; shift;;
--) shift; break;;
*) break;;
esac
shift
done

#Final argument is required to be the target(s)
shift $(($OPTIND - 1))
IP_ADDRESS_RANGE=$1

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

# nmap host discovery
# Top 100 TCP ports discovered with "nmap --top-ports 20 localhost -v -oG -"
# Top 20 UDP ports discovered with "nmap --top-ports 20 -sU localhost -v -oG -"

echo "Running the following nmap command..."
echo "nmap -sn -n -v --reason --open ${EXCLUDE_PARAMETER} -PS7,9,13,21-23,25-26,37,53,79-81,88,106,110-111,113,119,135,139,143-144,179,199,389,427,443-445,465,513-515,543-544,548,554,587,631,646,873,990,993,995,1025-1029,1110,1433,1720,1723,1755,1900,2000-2001,2049,2121,2717,3000,3128,3306,3389,3986,4899,5000,5009,5051,5060,5101,5190,5357,5432,5631,5666,5800,5900,6000-6001,6646,7070,8000,8008-8009,8080-8081,8443,8888,9100,9999-10000,32768,49152-49157 -PU53,67-69,123,135,137-139,161-162,445,500,514,520,631,1434,1900,4500,49152 -oA $OUTPUT_FILE_PATH/host-identification-$PROJECT_NAME-$(date +'%Y-%m-%d-%H-%M') --stylesheet=nmap.xsl $IP_ADDRESS_RANGE"

nmap -sn -n -v --reason --open ${EXCLUDE_PARAMETER} -PS7,9,13,21-23,25-26,37,53,79-81,88,106,110-111,113,119,135,139,143-144,179,199,389,427,443-445,465,513-515,543-544,548,554,587,631,646,873,990,993,995,1025-1029,1110,1433,1720,1723,1755,1900,2000-2001,2049,2121,2717,3000,3128,3306,3389,3986,4899,5000,5009,5051,5060,5101,5190,5357,5432,5631,5666,5800,5900,6000-6001,6646,7070,8000,8008-8009,8080-8081,8443,8888,9100,9999-10000,32768,49152-49157 -PU53,67-69,123,135,137-139,161-162,445,500,514,520,631,1434,1900,4500,49152 -oA $OUTPUT_FILE_PATH/host-identification-$PROJECT_NAME-$(date +'%Y-%m-%d-%H-%M') --stylesheet=nmap.xsl $IP_ADDRESS_RANGE
