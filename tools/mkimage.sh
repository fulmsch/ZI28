#!/usr/bin/env sh

# Create an image of a SD-Card containing a FAT16 partition.
# Uses sparse files on supported filesystems to save creation time and
# disk space.

set -e

if [ "$#" -ne "2" ]; then
    echo "Usage: $(basename "$0") <image filename> <size in KiB>" >&2
    exit 1
fi

IMGFILE="$1"
IMGSIZE="$2"
TEMPFILE="$(mktemp --dry-run || echo /tmp/fat.img)"

dd if=/dev/zero of="$TEMPFILE" bs=512 count=0 seek="$(( IMGSIZE * 2 - 128 ))" status=none
sudo mkfs.fat -f2 -F16 -S512 "$TEMPFILE" > /dev/null
# 2 FATs, FAT16

rm -f "$IMGFILE"

dd if=/dev/zero of="$IMGFILE" bs=512 count=0 seek=128 status=none
dd if="$TEMPFILE" of="$IMGFILE" bs=512 seek=128 conv=notrunc,sparse
rm -f "$TEMPFILE"
sudo parted --script --align none "$IMGFILE" \
	mklabel msdos \
	mkpart primary fat16 128s "$(( IMGSIZE * 2 - 1))"s \
	print
