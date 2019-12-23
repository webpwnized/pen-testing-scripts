#!/bin/bash
	
PROGNAME=${0##*/}
PROGVERSION="0.1"
USAGE="USAGE: ./$PROGNAME [options] domain"
SHORTOPTS="hv"
LONGOPTS="help,version"

TITLE="\n$PROGNAME by Jeremy Druin\n
Options:
\t-h | --help\t\tDisplay this help and exit
\t-v | --version\t\tDisplay version and exit"

if [ $# != 1 ]
then
	echo "$USAGE"
	exit 1
fi

ARGS=$(getopt -s bash --options $SHORTOPTS --longoptions $LONGOPTS --name $PROGNAME -- "$@" )

eval set -- "$ARGS"

while true; do
case $1 in
-h | --help) printf "${TITLE}\n\n"; printf "${USAGE}\n\n"; exit 0;;
-v | --version) printf "${PROGVERSION}\n"; exit 0;;
--) shift; break;;
*) break;;
esac
shift
done

#Final argument is required to be the input file
shift $(($OPTIND - 1))
DOMAIN=$1

echo "------------"
echo "Name Servers"
echo "------------"
host -t ns $DOMAIN | cut -d" " -f4
echo
echo "-------------"
echo "Zone Transfer"
echo "-------------"
for ns in $(host -t ns $DOMAIN | cut -d" " -f4);do host -l $DOMAIN $ns | grep "has address" | cut -d" " -f1,4; done
echo
