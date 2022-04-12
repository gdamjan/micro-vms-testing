## Quickstart

```
firecracker --no-api --config-file firecracker.json
```

similar with cloud-hypervisor:

```
cloud-hypervisor --seccomp=false --cpus boot=2 \
    --kernel ./vmlinux.bin --initramfs ./initramfs.img.lz4 \
    --console tty \
    --cmdline 'reboot=k panic=1 i8042.noaux i8042.nomux i8042.nopnp i8042.dumbkbd quiet console=hvc0'
```

## References
- https://firecracker-microvm.github.io/
- https://www.cloudhypervisor.org/
- https://qemu.readthedocs.io/en/latest/system/i386/microvm.html
