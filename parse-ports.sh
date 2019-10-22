#!/bin/bash

GNMAP_FILE=$1

egrep -v "^#|Status: Up" $GNMAP_FILE | cut -d' ' -f4- | sed -n -e 's/Ignored.*//p' | tr ',' '\n' | sed -e 's/^[ \t]*//' | sort -n | uniq | cut -d"/" -f1 | tr '\n' ',' | sed 's/,$//'