#!/bin/bash

PROGNAME=${0##*/}
PROGVERSION="0.1"
USAGE="USAGE: ./$PROGNAME [options] smtp_hostname smtp_port username_file"
SHORTOPTS="hv"
LONGOPTS="help,version"

TITLE="\n$PROGNAME by Jeremy Druin\n
Options:
\t-h | --help\t\tDisplay this help and exit
\t-v | --version\t\tDisplay version and exit"

if [ $# != 3 ]
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
SMTP_HOST=$1
SMTP_PORT=$2
USERS_FILE=$3

while IFS='' read -r line || [[ -n "$line" ]]; do
  echo VRFY $line | nc -nv -w 1 $SMTP_HOST $SMTP_PORT 2>/dev/null | grep ^"250"
done < $USERS_FILE