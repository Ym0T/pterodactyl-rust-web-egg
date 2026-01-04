# Pterodactyl Rust Web Application Egg
FROM debian:bookworm-slim

LABEL author="Ym0T" maintainer="YmoT@tuta.com"
LABEL org.opencontainers.image.source="https://github.com/Ym0T/pterodactyl-rust-web-egg"
LABEL org.opencontainers.image.description="Pterodactyl Egg for running Rust web applications with Cloudflare Tunnel support"

# Arguments for customization
ARG RUST_VERSION=stable

ENV DEBIAN_FRONTEND=noninteractive
ENV USER=container
ENV HOME=/home/container
# Install Rust to /opt/rust so it's not hidden by Pterodactyl's volume mount on /home/container
ENV CARGO_HOME=/opt/rust/cargo
ENV RUSTUP_HOME=/opt/rust/rustup
ENV PATH="/opt/rust/cargo/bin:${PATH}"

# Install system dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        # Essential tools
        ca-certificates \
        curl \
        wget \
        git \
        unzip \
        tar \
        gzip \
        xz-utils \
        # Build essentials for Rust
        build-essential \
        pkg-config \
        libssl-dev \
        libpq-dev \
        libsqlite3-dev \
        # Runtime dependencies
        openssl \
        sqlite3 \
        # Network tools
        iproute2 \
        iputils-ping \
        dnsutils \
        # Process management
        procps \
    # Cloudflared
    && curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o /usr/local/bin/cloudflared \
    && chmod +x /usr/local/bin/cloudflared \
    # Cleanup
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install Rust toolchain to /opt/rust
RUN mkdir -p /opt/rust \
    && curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain ${RUST_VERSION} \
    && . "$CARGO_HOME/env" \
    && rustup component add clippy rustfmt \
    && cargo --version \
    && rustc --version \
    && chmod -R a+rx /opt/rust

# Create user and set environment variables
RUN useradd -m -d /home/container -s /bin/bash container \
    && echo "USER=container" >> /etc/environment \
    && echo "HOME=/home/container" >> /etc/environment

# Create directory structure
RUN mkdir -p /home/container/logs \
    /home/container/tmp \
    /home/container/data \
    /home/container/bin \
    && chown -R container:container /home/container

WORKDIR /home/container

STOPSIGNAL SIGINT

# Copy entrypoint script
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]
