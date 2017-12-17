#!/usr/bin/env sh

set -e

if [ "$#" -ne "2" ]; then
    echo "Usage: $(basename "$0") <sysroot> <package list>" >&2
    exit 1
fi

SYSROOT="$1"
PKGLIST="$2"

SCRIPTDIR="$(dirname $(realpath "$0"))"

PARSE_PKGLIST="
import sys

def read_list(filename):
	pkglist = []
	with open(filename, 'r') as f:
		for line in f:
			line = line.strip()
			if len(line) == 0 or line[0] == '#':
				#ignore line
				pass
			elif line[0] == '@':
				#recurse
				for listfile in line[1:].split():
					pkglist.extend(read_list(listfile))
			elif line[0] == '!':
				#remove package
				for pkg in line[1:].split():
					if pkg in pkglist:
						pkglist.remove(pkg)
			else:
				#add to pkg list
				for pkg in line.split():
					pkglist.append(pkg)
	return pkglist

if len(sys.argv) != 3:
	sys.exit(-1)

sysroot_dir = sys.argv[1]
package_list_file = sys.argv[2]

for pkg in read_list(package_list_file):
	print(pkg)
"

PACKAGES=$(python3 -c "$PARSE_PKGLIST" "$SYSROOT" "$PKGLIST")

for P in $PACKAGES
do
	echo $P
	"$SCRIPTDIR/installpkg.sh" "$P" "$SYSROOT"
done

