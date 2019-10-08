#!/usr/bin/env python3

import sys

lines = 0

with open(sys.argv[1], 'r') as f:
    for line in f:
        lines += 1
        line = line.rstrip()
        if len(line) > 64:
            sys.stderr.write("Line " + lines + ": too long\n")
            exit(-1)
        line = line.ljust(64)
        sys.stdout.write(line)
    padding = ''.ljust(64)
    if lines % 16 != 0:
        for i in range(0, 16 - lines % 16):
            sys.stdout.write(padding)
