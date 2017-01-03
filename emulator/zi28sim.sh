#!/usr/bin/env bash

EXTPTY="/tmp/zi28sim"
INTPTY="/tmp/sim"
ROMIMG="../z80/bios/bios.obj"

#socat PTY,link=$EXTPTY,raw,echo=0 PTY,link=$INTPTY,raw,echo=0 &
#sleep 0.1

./emulator -t $INTPTY -r $ROMIMG

#kill %1
