#!/usr/bin/env bash
#
# Copyright (c) 2015 Richard Mortier <mort@cantab.net>. All Rights Reserved.
# Copyright (c) 2015 Thomas Gazagnaire <thomas@gazagnaire.org>.
#
# Permission to use, copy, modify, and distribute this software for any purpose
# with or without fee is hereby granted, provided that the above copyright
# notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
# REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
# AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
# INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
# LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
# OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
# PERFORMANCE OF THIS SOFTWARE.

set -eu

if [ "$#" -eq 0 ]; then
    echo "usage: $(basename "$0") NAME KEY-FILE"
    exit 1
fi
NAME=$1

if [ "$#" -eq 1 ] || ! [ -f "$2" ]; then
    echo "The FAT image containting the certificates is missing or invalid."
    echo "usage: $(basename "$0") NAME KEY-FILE"
    exit 1
fi
FILE=$2

ROOT=$(git rev-parse --show-toplevel)
SCRIPTS="$ROOT/scripts"

"$SCRIPTS/destroy-vm.sh" "$NAME"

# Note: bash lazily evaluates the variables, so it's important to keep the
# **use** of OLD_LOSETUP and NEW_LOSETUP in the right order:
# need to umount the old loopback device first -- and there is a small race
# between the two invocations of losetup
OLD_LOSETUP=$(sudo losetup -j "$FILE" -v | cut -f 1 -d ':')
NEW_LOSETUP=$(sudo losetup -f)
if ! [ -z "$OLD_LOSETUP" ]; then sudo losetup -d "$OLD_LOSETUP"; fi
if ! [ -z "$NEW_LOSETUP" ]; then sudo losetup "$NEW_LOSETUP" "$FILE"; fi

"$SCRIPTS/prepare-config.sh" "$NAME" "disk = [ '$NEW_LOSETUP,,xvda' ]"
"$SCRIPTS/create-vm.sh" "$NAME"
