#! /bin/bash
set -eu


INITRAMFS=./run/initramfs.img.lz4
KERNEL=./run/vmlinux.bin
CMDLINE=(reboot=k panic=1 i8042.noaux i8042.nomux i8042.nopnp i8042.dumbkbd)

HYP_ARGS=(
    --seccomp=false
    --cpus boot=2
    --kernel "$KERNEL"
    --initramfs "$INITRAMFS"
    # --net "tap=,mac=,ip=,mask="
)

verbose=false
shared_dir=""
vsock_cid=""
test_string=""
while getopts ":vd:s:t:" flag
do
    case "${flag}" in
        v) verbose=true;;
        d) shared_dir=${OPTARG};;
        s) vsock_cid=${OPTARG};;
        t) test_string=${OPTARG};;
        *) echo>&2 "Invalid Option: '-${OPTARG}'"; exit 1 ;;
    esac
done


if [ "$verbose" = "true" ]; then
    HYP_ARGS+=(--console off --serial tty)
    CMDLINE+=("console=ttyS0")
else
    HYP_ARGS+=(--console tty)
    CMDLINE+=(quiet "console=hvc0")
fi

if [ -n "$vsock_cid" ]; then
    HYP_ARGS+=(--vsock cid=$vsock_cid,socket=/tmp/vsock-$vsock_cid.sock)
fi

if [ -n "$test_string" ]; then
    CMDLINE+=("TEST_STRING=${test_string}")
fi

if [ -n "$shared_dir" ]; then
    VIRTIOFS_NAME=myfs
    VIRTIOFS_SOCK=`mktemp -d`/$VIRTIOFS_NAME.virtiofs
    VIRTIOFS_SHARED=/tmp/$VIRTIOFS_NAME.shared_dir
    HYP_ARGS+=(
        --memory "size=512M,shared=on"
        --fs "tag=$VIRTIOFS_NAME,socket=$VIRTIOFS_SOCK,num_queues=1,queue_size=512"
    )

    /usr/lib/virtiofsd \
        --tag="$VIRTIOFS_NAME" \
        --socket-path="$VIRTIOFS_SOCK" \
        --shared-dir="$shared_dir" \
        --cache=never &

fi

set -x
cloud-hypervisor ${HYP_ARGS[@]} --cmdline "${CMDLINE[*]}"
set +x

## Guest commands:
# mount -t virtiofs myfs /mnt

## virtio-sock
# socat - UNIX-CONNECT:./v.sock
# nc-vsock -l ...
