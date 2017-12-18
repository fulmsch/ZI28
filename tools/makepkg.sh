#!/usr/bin/env sh

set -e

if [ "$#" -ne "2" ]; then
    echo "Usage: $(basename "$0") <build directory> <package name>" >&2
    exit 1
fi

BUILDDIR="$1"
PACKAGENAME="$2"
OUTDIR=$(pwd)

TARFILE="$(mktemp --dry-run || echo "/tmp/$PACKAGENAME.tar")"

cd "$BUILDDIR"
tar -cvf "$TARFILE" -- *
zx7 -f "$TARFILE" "$OUTDIR/$PACKAGENAME.TZ7" > /dev/null
