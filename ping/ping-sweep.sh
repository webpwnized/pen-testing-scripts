#!/bin/bash

for i in {1..254}; do ping -c 1 10.11.1.$i | grep "bytes from" | cut -d " " -f 4 | cut -d: -f1 2>/dev/null & disown; done > ip-addresses.txt
