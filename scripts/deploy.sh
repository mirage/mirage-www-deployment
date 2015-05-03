#!/bin/sh -ex
#
# Copyright (c) 2015 Richard Mortier <mort@cantab.net>. All Rights Reserved.
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

VM=mir-www
XM=xl

ROOT=$(git rev-parse --show-toplevel)
cd $ROOT

KERNEL=$ROOT/xen/`cat xen/latest`
sed -e "s,@VM@,$VM,g; s,@KERNEL@,$KERNEL/$VM.xen,g" \
    < $XM.conf.in \
    >| $KERNEL/$XM.conf

cd $KERNEL
rm -f $VM.xen
bunzip2 -k $VM.xen.bz2

sudo $XM destroy $VM || true
sudo $XM create $XM.conf
