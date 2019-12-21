#!/usr/bin/env python3

# Adapted from https://stackoverflow.com/questions/21225464/fast-ping-sweep-in-python in combination with other sites
import os
import time
from subprocess import Popen, DEVNULL

p = {} # dictionary of calls to popen
for n in range(1, 254):
    ip = "10.11.1.%d" % n
    p[ip] = Popen(['ping', '-n', '-w5', '-c3', ip], stdout=DEVNULL)

while p:
    for ip, proc in p.items():
        if proc.poll() is not None:
            del p[ip] # remove job from from the process list
            if proc.returncode == 0:
                print(ip)
            break
