FROM alpine:3.12

RUN apk add iperf3

EXPOSE 5201/tcp 5201/udp

ENTRYPOINT ["iperf3"]

CMD ["-s"]
