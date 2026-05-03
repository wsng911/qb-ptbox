#!/bin/bash
set -e

CONFIG_DIR="/app/config"
DOWNLOAD_DIR="/app/downloads"
QB_CONF_DIR="${CONFIG_DIR}/qBittorrent"
QB_CONF="${QB_CONF_DIR}/qBittorrent.conf"

mkdir -p "${QB_CONF_DIR}" "${DOWNLOAD_DIR}"

# Write qBittorrent config (password set via WebUI on first login)
cat > "${QB_CONF}" << CONF
[BitTorrent]
Session\DefaultSavePath=${DOWNLOAD_DIR}
Session\Port=${QB_INCOMING_PORT:-45000}
Session\DiskCacheSize=${QB_CACHE_SIZE:-512}

[Preferences]
WebUI\Port=${QB_WEBUI_PORT:-8080}
WebUI\Username=${QB_USERNAME:-admin}
WebUI\LocalHostAuth=false
CONF

echo "========================================"
echo "  qb-ptbox starting..."
echo "  WebUI: http://0.0.0.0:${QB_WEBUI_PORT:-8080}"
echo "  Username: ${QB_USERNAME:-admin}"
echo "  Password: set via WebUI on first login"
echo "========================================"

exec qbittorrent-nox \
    --profile="${CONFIG_DIR}" \
    --webui-port="${QB_WEBUI_PORT:-8080}"
