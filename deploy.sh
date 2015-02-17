#!/bin/sh -ex

VM=mir-www

XM=xm
KERNEL=`pwd`/xen/`cat xen/latest`
sed -e "s,@VM@,$VM,g; s,@KERNEL@,$KERNEL/$VM.xen,g" \
    < $XM.conf.in \
    > $KERNEL/$XM.conf

cd $KERNEL
rm -f $VM.xen
bunzip2 -k $VM.xen.bz2

sudo $XM destroy $VM || true
sudo $XM create $XM.conf
