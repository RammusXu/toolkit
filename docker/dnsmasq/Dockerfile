# https://hub.docker.com/_/alpine
FROM alpine:3.11.3

RUN apk update \
	&& apk --no-cache add dnsmasq bind-tools

EXPOSE 53 53/udp

ENTRYPOINT dnsmasq --no-daemon --log-queries