FROM alpine:latest

RUN apk --update-cache add python3

COPY ./assets/init ./assets/vsock-demo.py /
