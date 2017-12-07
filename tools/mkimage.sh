#!/usr/bin/env sh

# Create an image of a SD-Card containing a FAT16 partition.

if [ "$#" -ne "1" ]; then
    echo "Usage: $(basename "$0") <image_filename>" >&2
    exit 1
fi

IMGFILE="$1"
TEMPFILE="$(mktemp --dry-run || echo /tmp/fat.img)"

mkfs.fat -f2 -F16 -C -S512 "$TEMPFILE" 20000 > /dev/null || exit 1
# 2 FATs, FAT16, create image, 20000 blocks?

rm -f "$IMGFILE"

dd if=/dev/zero of="$IMGFILE" bs=512 count=128 status=none || exit 2
cat "$TEMPFILE" >> "$IMGFILE" || exit 3
rm -f "$TEMPFILE"
parted --script --align none "$IMGFILE" \
	mklabel msdos \
	mkpart primary fat16 128s 40127s \
	print
