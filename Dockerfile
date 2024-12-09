FROM alpine:latest

RUN apk --update-cache add python3 socat

COPY ./assets/init ./assets/vsock-demo.py /
