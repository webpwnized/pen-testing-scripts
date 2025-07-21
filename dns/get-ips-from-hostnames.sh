#!/bin/bash

PROGNAME=${0##*/}
PROGVERSION="0.1"
USAGE="USAGE: ./$PROGNAME [options] input_file"
SHORTOPTS="hv"
LONGOPTS="help,version"

TITLE="$PROGNAME by Jeremy Druin

Options:
  -h | --help         Display this help and exit
  -v | --version      Display version and exit"

# Parse arguments
ARGS=$(getopt -s bash --options $SHORTOPTS --longoptions $LONGOPTS --name $PROGNAME -- "$@")
eval set -- "$ARGS"

while true; do
  case $1 in
    -h | --help) printf "%s\n\n%s\n" "$TITLE" "$USAGE"; exit 0 ;;
    -v | --version) printf "%s\n" "$PROGVERSION"; exit 0 ;;
    --) shift; break ;;
    *) break ;;
  esac
  shift
done

# Require one input file
if [ $# -ne 1 ]; then
  echo "$USAGE"
  exit 1
fi

INPUT_FILE="$1"

# Validate input file exists and is readable
if [ ! -r "$INPUT_FILE" ]; then
  echo "Error: Cannot read input file '$INPUT_FILE'" >&2
  exit 2
fi

# Process each domain line by line
while IFS='' read -r line || [ -n "$line" ]; do
  [ -z "$line" ] && continue  # Skip empty lines
  host "$line" | grep "has address" | sed 's/ has address /:/'
done < "$INPUT_FILE"

