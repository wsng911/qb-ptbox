#!/bin/bash
set -e

CONFIG_DIR="/app/config"
DOWNLOAD_DIR="/app/downloads"
QB_CONF="${CONFIG_DIR}/qBittorrent/qBittorrent.conf"

mkdir -p "${CONFIG_DIR}/qBittorrent" "${DOWNLOAD_DIR}"

# Write qBittorrent config
cat > "${QB_CONF}" << CONF
[BitTorrent]
Session\DefaultSavePath=${DOWNLOAD_DIR}
Session\Port=${QB_INCOMING_PORT:-45000}
Session\DiskCacheSize=${QB_CACHE_SIZE:-512}

[Preferences]
WebUI\Port=${QB_WEBUI_PORT:-8080}
WebUI\Username=${QB_USERNAME:-admin}
WebUI\Password_PBKDF2="@ByteArray()"
CONF

echo "Starting qBittorrent-nox..."
echo "WebUI: http://0.0.0.0:${QB_WEBUI_PORT:-8080}"
echo "Username: ${QB_USERNAME:-admin}"
echo "Password: ${QB_PASSWORD:-adminadmin}"

exec qbittorrent-nox \
    --profile="${CONFIG_DIR}" \
    --webui-port="${QB_WEBUI_PORT:-8080}"
