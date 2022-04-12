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

## Verbose start

* Build a kernel with the `linux-config` config for a minimal no-legacy kernel
  (no modules either). You'll need the `arch/x86/boot/compressed/vmlinux.bin` for
  firecracker and cloud-hypervisor, `arch/x86/boot/bzImage` for QEMU microvm.
* `build-initramfs.sh` will create an initramfs based on alpine, with python
  installed and a custom /init script.
* `run-cloud-hypervisor.sh` will run cloud-hypervisor with some shortcuts
* `microvm` will run qemu with some shortcuts

## References
- https://firecracker-microvm.github.io/
- https://www.cloudhypervisor.org/
- https://qemu.readthedocs.io/en/latest/system/i386/microvm.html
