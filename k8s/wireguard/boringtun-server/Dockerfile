FROM rust:1.40-slim-buster AS builder

ARG BORINGTUN_VERSION=0.3.0

RUN cargo install boringtun --version ${BORINGTUN_VERSION}

###

FROM ghcr.io/linuxserver/wireguard:version-v1.0.20200827

COPY --from=builder /usr/local/cargo/bin/boringtun /usr/local/bin

ENV WG_QUICK_USERSPACE_IMPLEMENTATION=boringtun \
    WG_SUDO=1
    # WG_LOG_LEVEL=info \
    # WG_THREADS=4
