#!/bin/sh

set -eu

if [ "$#" -ne 2 ]; then
    echo "usage: $(basename "$0") IN-DIR OUT-FILE"
    exit 1
fi

DIR=$1
FILE=$2

echo This uses the 'fat' command-line tool to build a simple FAT
echo filesystem image.

FAT=$(which fat)
if [ ! -x "$FAT" ]; then
  echo I couldn\'t find the 'fat' command-line tool.
  echo Try running 'opam install fat-filesystem'
  exit 1
fi

SIZE=$(du -L -s "$DIR" | cut -f 1)
rm -f "$FILE"
$FAT create "$FILE" "${SIZE}KiB"
cd "$DIR" && ls | xargs "$FAT" add "../$FILE"
echo Created "$FILE"
