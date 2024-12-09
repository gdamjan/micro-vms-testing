#! /bin/bash

podman build -t initramfs.img .
CTR_ID=`podman create initramfs.img`

podman export $CTR_ID | bsdtar -cf - --format newc @- | lz4c -l > run/initramfs.img.lz4

podman rm $CTR_ID
podman rmi initramfs.img
