FROM          alpine:3.8

ENTRYPOINT    ["sh", "-c"]
CMD           ["trap : TERM INT; sleep infinity & wait"]
RUN           apk add --no-cache --virtual .run-deps \
                coreutils