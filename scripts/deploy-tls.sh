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

if [ "$#" -ne 2 ]; then
    echo "usage: $(basename "$0") NAME DIR"
    exit 1
fi
NAME=$1

if [ "$#" -eq 1 ] || ! [ -f "$2/tls/server.key" ] || ! [ -f "$2/tls/server.pem" ];
then
    echo "usage: $(basename "$0") NAME DIR"
    echo "DIR should contain 'tls/server.key' and 'tls/server.pem'."
    exit 1
fi
DIR=$2

ROOT=$(git rev-parse --show-toplevel)
SCRIPTS="$ROOT/scripts"
FILE="$ROOT/fat.img"

"$SCRIPTS/destroy-vm.sh" "$NAME"

# Note: bash lazily evaluates the variables, so it's important to keep
# the **use** of OLD_LOSETUP and NEW_LOSETUP in the right order: need
# to umount the old loopback device first
OLD_LOSETUP=$(sudo losetup -j "$FILE" -v | cut -f 1 -d ':')
if ! [ -z "$OLD_LOSETUP" ]; then sudo losetup -d "$OLD_LOSETUP"; fi

"$SCRIPTS/make-fat-image.sh" "$DIR"

# there is a small race between the two invocations of losetup here,
# as evaluating $NEW_LOSETUP will call `losetup -f` first.
NEW_LOSETUP=$(sudo losetup -f)
sudo losetup "$NEW_LOSETUP" "$FILE"

"$SCRIPTS/prepare-config.sh" "$NAME" "disk = [ '$NEW_LOSETUP,,xvdb' ]"
"$SCRIPTS/create-vm.sh" "$NAME"
