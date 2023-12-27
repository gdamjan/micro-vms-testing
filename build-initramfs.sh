#! /bin/bash

set -eEuo pipefail

ARCH=x86_64
VER=3.19.0
MAJOR=v${VER%.*}
TAR=alpine-minirootfs-${VER}-${ARCH}.tar.gz
URL=https://dl-cdn.alpinelinux.org/alpine/${MAJOR}/releases/${ARCH}/${TAR}

wget -c $URL

WORK_DIR=`mktemp -d`
tar xf ${TAR} -C $WORK_DIR

# setup the rootfs
sudo systemd-nspawn --quiet -D $WORK_DIR /sbin/apk add python3 --update-cache
cp ./init ./vsock-demo.py $WORK_DIR

# make the initramfs
(
    find $WORK_DIR -printf "%P\0" |
    cpio --directory=$WORK_DIR --null --create --verbose --owner root:root --format=newc ) |
    lz4c -l > initramfs.img.lz4

sudo rm -rf "$WORK_DIR"
