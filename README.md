## Quickstart

```
firecracker --config-file vm.json --no-api
```

## Sources

- https://raw.githubusercontent.com/firecracker-microvm/firecracker/master/tests/framework/vm_config.json
- https://github.com/firecracker-microvm/firecracker/blob/master/tests/framework/vm_config.json
- https://dl-cdn.alpinelinux.org/alpine/v3.13/releases/x86_64/alpine-minirootfs-3.13.5-x86_64.tar.gz

```
pushd alpine-minirootfs
find . -print0 |
    cpio --null --create --verbose --owner root:root --format=newc |
    lz4c -l > ../initramfs.img.lz4

popd
```

```
cloud-hypervisor --cpus boot=2 --memory "size=512M" --rng \
    --kernel ./bzImage \
    --initramfs ./initramfs.img.lz4 \
    --cmdline "console=hvc0 quiet reboot=k panic=1 i8042.noaux i8042.nomux i8042.nopnp i8042.dumbkbd" \
    --vsock cid=10,sock=/tmp/cid10.sock
```
