#! /usr/bin/python3
'''
Get and unpack the alpinelinux minirootfs, add python3, and add this script
Create an initramfs from it, then run it inside of cloud-hypervisor:

$ cloud-hypervisor \
    --cmdline "console=hvc0 quiet panic=-1" \
    --kernel ./bzImage \
    --initramfs ./initramfs.img.lz4 \
    --vsock cid=10,sock=/tmp/cid10.sock


To simulate the proxy, you can do these:

On the host run this:
$ socat - UNIX-LISTEN:/tmp/cid10.sock_12345
REGISTER 54321
ping
pong

And this:
$ socat - UNIX-CONNECT:/tmp/cid10.sock
CONNECT 54321
…
'''

import asyncio
import socket

DUMMY_RESPONSE = '''\
HTTP/1.1 200 OK\r
date: Sat, 11 Apr 2020 23:43:49 GMT\r
content-type: text/plain\r
content-length: 3\r
\r
ok
'''

PROXY_WELL_KNOWN_ADDR = 2      ## the host in VSOCK addressing
PROXY_WELL_KNOWN_PORT = 12345

async def register_with_proxy(server):
    try:
        sock = socket.socket(socket.AF_VSOCK, socket.SOCK_STREAM, 0)
        sock.connect((PROXY_WELL_KNOWN_ADDR, PROXY_WELL_KNOWN_PORT))
        reader, writer = await asyncio.open_connection(sock=sock)

        for s in server.sockets:
            port = s.getsockname()[1]
            register_cmd = f"REGISTER {port}\n"
            writer.write(register_cmd.encode())
        await writer.drain()
        await keepalive(reader, writer)
    finally:
        server.close()

async def keepalive(reader, writer):
    while True:
        data = await reader.readuntil(separator=b'\n')
        if data == b'ping\n':
            writer.write(b'pong\n')
            await writer.drain()
        if data == b'':
            break
    writer.close()
    await writer.wait_closed()


async def handle_http_request(reader, writer):
    addr = writer.get_extra_info('peername')
    print(f"Connected from {addr}")
    request = await reader.readuntil(separator=b'\r\n\r\n')
    print(request)
    writer.write(DUMMY_RESPONSE.encode())
    await writer.drain()
    writer.close()

async def http_server():
    sock = socket.socket(socket.AF_VSOCK, socket.SOCK_STREAM, 0)
    sock.bind((-1, -1))

    srv = await asyncio.start_server(handle_http_request, sock=sock, start_serving=False)
    async with srv:
        print(srv)
        asyncio.create_task(register_with_proxy(srv))
        await srv.serve_forever()


if __name__ == '__main__':
    asyncio.run(http_server())
