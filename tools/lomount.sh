#!/usr/bin/env sh

# Mount partitions within a disk image file

# License: LGPLv2
# Author: P@adraigBrady.com

# Based on lomount.sh from https://github.com/pixelb/scripts.

# V1.0      29 Jun 2005     Initial release
# V1.1      01 Dec 2005     Handle bootable (DOS) parititons
# v1.2      25 Jan 2013     Glen Gray: Handle GPT partitions
# v1.3      07 Dec 2017     Florian Ulmschneider: Adapt for ZI-28 project

set -e

if [ "$#" -ne "3" ]; then
    echo "Usage: $(basename "$0") <image_filename> <partition # (1,2,...)> <mount point>" >&2
    exit 1
fi

FILE=$1
PART=$2
DEST=$3

if parted --version >/dev/null 2>&1; then # Prefer as supports GPT partitions
  UNITS=$(parted -s "$FILE" unit s print 2>/dev/null | grep " $PART " |
          tr -d 's' | awk '{print $2}')
elif fdisk -v >/dev/null 2>&1; then
  UNITS=$(fdisk -lu "$FILE" 2>/dev/null | grep "$FILE$PART " |
          tr -d '*' | awk '{print $2}')
else
  echo "Can't find the fdisk or parted utils." >&2
  exit 1
fi

OFFSET=$(( 512 * $UNITS ))
sudo mount -o loop,sync,offset="$OFFSET",gid="$(id -g)",uid="$(id -u)" "$FILE" "$DEST"
