FROM debian:12-slim

WORKDIR /app

# 可通过 --build-arg 自定义版本
# 例：docker build --build-arg QB_VERSION=4.3.9 --build-arg LIBT_VERSION=1.2.19 .
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

# 下载对应架构的 qbittorrent-nox 静态二进制
RUN case "${TARGETARCH}" in \
    "arm64") ARCH="aarch64" ;; \
    *) ARCH="x86_64" ;; \
    esac && \
    curl -sL "https://github.com/userdocs/qbittorrent-nox-static/releases/download/release-${QB_VERSION}_v${LIBT_VERSION}/${ARCH}-qbittorrent-nox" \
    -o /usr/local/bin/qbittorrent-nox && \
    chmod +x /usr/local/bin/qbittorrent-nox

RUN pip3 install --no-cache-dir autoremove-torrents --break-system-packages

COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

RUN git config --global user.email "wsng911@github.com" && \
    git config --global user.name "wsng911" && \
    git init && git add -A && git commit -m "init: qb-ptbox docker image"

ENV QB_USERNAME=admin \
    QB_WEBUI_PORT=8080 \
    QB_INCOMING_PORT=45000 \
    QB_CACHE_SIZE=512

EXPOSE 8080 45000

# /app/downloads  - 下载目录（种子文件保存位置）
# /app/config     - qBittorrent 配置目录（含 watched 目录）
VOLUME ["/app/downloads", "/app/config"]

ENTRYPOINT ["/app/entrypoint.sh"]
