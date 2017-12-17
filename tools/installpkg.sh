#!/usr/bin/env sh

set -e

if [ "$#" -ne "2" ]; then
    echo "Usage: $(basename "$0") <package name> <install directory>" >&2
    exit 1
fi

PACKAGENAME="$(echo "$1" | tr "[:lower:]" "[:upper:]")"
INSTALLDIR="$2"

PACKAGEFILE="$(find . -iname "$PACKAGENAME.TZ7")"

TARFILE="$(mktemp --dry-run || echo "/tmp/$PACKAGENAME.tar")"

dzx7 "$PACKAGEFILE" "$TARFILE"
cd "$INSTALLDIR"
tar -xvf "$TARFILE"
tar -tf "$TARFILE" > "VAR/LOG/PACKAGES/$PACKAGENAME.PKG"
