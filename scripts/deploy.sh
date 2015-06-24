#!/usr/bin/env bash
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

# Assumption: the FAT image containing the certificate is at the root
# of the Git repository

set -e

XL=xl
ROOT=$(git rev-parse --show-toplevel)
KERNEL=$ROOT/xen/`cat xen/latest`
KEYS=$ROOT/keys.img

function destroy_vm {
    VM=$1
    cd $KERNEL
    rm -f $VM.xen
    bunzip2 -k $VM.xen.bz2
    sudo $XL destroy ${VM#mir-} || true
}

function create_vm {
    VM=$1
    cd $KERNEL
    sudo $XL create $VM.$XL
}

function prepare_config {
    DISK=$1
    cd $ROOT
    sed -e "s,@VM@,$VM,g; s,@KERNEL@,$KERNEL/$VM.xen,g; s:@DISK@:$DISK:g" \
	< $XL.conf.in \
	>| $KERNEL/$NAME.$XL
}

function deploy {
    NAME=$1
    VM=mir-${NAME}
    prepare_config ""
    destroy_vm $VM
    create_vm $VM
}

function deploy_tls {
    NAME=$1
    VM=mir-${NAME}
    XL=xl
    OLD_LOSETUP=`sudo losetup -j ${KEYS} -v | cut -f 1 -d ':'`
    # there is a race here
    NEW_LOSETUP=`sudo losetup -f`
    DISK="disk = [ '${NEW_LOSETUP},,xvda' ]"
    prepare_config "$DISK"
    destroy_vm ${VM}
    if ! [ -z $OLD_LOSETUP ]; then sudo losetup -d ${OLD_LOSETUP}; fi
    if ! [ -z $NEW_LOSETUP ]; then sudo losetup ${NEW_LOSETUP} ${KEYS}; fi
    create_vm ${VM}
}

deploy_tls mirage.io
deploy openmirage.org
