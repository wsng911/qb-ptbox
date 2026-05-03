FROM debian:12-slim

WORKDIR /app

ARG QB_VERSION=4.6.7
ARG LIBT_VERSION=2.0.10
ARG TARGETARCH

RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    python3 \
    python3-pip \
    git \
    && rm -rf /var/lib/apt/lists/*

RUN case "${TARGETARCH}" in \
    "amd64") ARCH="x86_64" ;; \
    "arm64") ARCH="aarch64" ;; \
    *) ARCH="x86_64" ;; \
    esac && \
    curl -sL "https://github.com/userdocs/qbittorrent-nox-static/releases/download/release-${QB_VERSION}_v${LIBT_VERSION}/x86_64-qbittorrent-nox" \
    -o /usr/local/bin/qbittorrent-nox && \
    chmod +x /usr/local/bin/qbittorrent-nox

RUN pip3 install --no-cache-dir autoremove-torrents --break-system-packages

COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

RUN git init && git add -A && git commit -m "init: qb-ptbox docker image" || true

ENV QB_USERNAME=admin \
    QB_PASSWORD=adminadmin \
    QB_WEBUI_PORT=8080 \
    QB_INCOMING_PORT=45000 \
    QB_CACHE_SIZE=512

EXPOSE 8080 45000

VOLUME ["/app/downloads", "/app/config"]

ENTRYPOINT ["/app/entrypoint.sh"]
