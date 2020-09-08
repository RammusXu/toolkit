FROM alpine:3.10

RUN apk add jq httpie

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
