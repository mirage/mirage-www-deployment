#!/bin/sh -ex

KERNEL=`pwd`/xen/`cat xen/latest`
sed -e "s,@KERNEL@,$KERNEL/mir-www.xen,g" < xl.conf.in > $KERNEL/xl.conf
cd $KERNEL
rm -f mir-www.xen
bunzip2 -k mir-www.xen.bz2
sudo xl destroy mirage-www || true
sudo xl create xl.conf
