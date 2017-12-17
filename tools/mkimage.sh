#!/usr/bin/env sh

# Create an image of a SD-Card containing a FAT16 partition.

set -e

if [ "$#" -ne "2" ]; then
    echo "Usage: $(basename "$0") <image filename> <size in KiB>" >&2
    exit 1
fi

IMGFILE="$1"
IMGSIZE="$2"
TEMPFILE="$(mktemp --dry-run || echo /tmp/fat.img)"

mkfs.fat -f2 -F16 -C -S512 "$TEMPFILE" "$(( IMGSIZE - 64 ))" > /dev/null
# 2 FATs, FAT16, create image, 20000 * 1024 bytes?

rm -f "$IMGFILE"

dd if=/dev/zero of="$IMGFILE" bs=512 count=128 status=none
cat "$TEMPFILE" >> "$IMGFILE"
rm -f "$TEMPFILE"
parted --script --align none "$IMGFILE" \
	mklabel msdos \
	mkpart primary fat16 128s "$(( IMGSIZE * 2 - 1))"s \
	print
