FROM alpine:latest

RUN apk --update-cache add python3

COPY ./init ./vsock-demo.py /
