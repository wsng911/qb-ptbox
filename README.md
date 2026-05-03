# qb-ptbox

一个基于 Docker 的 qBittorrent PT 下载盒子，将原始 seedbox 安装脚本的所有步骤容器化，开箱即用，无需手动编译安装。

## 功能特性

- 🐳 基于 Docker，一条命令启动 qBittorrent
- ⚙️ 环境变量配置用户名、密码、端口、缓存
- 💾 数据持久化（下载目录 + 配置目录挂载）
- 🔄 支持 `autoremove-torrents` 自动删种
- 📦 使用静态编译二进制，无依赖冲突

## 快速开始

### 使用 docker-compose（推荐）

```bash
git clone https://github.com/wsng911/qb-ptbox.git
cd qb-ptbox
docker compose up -d
```

访问 WebUI：`http://localhost:8080`
默认账号：`admin` / `adminadmin`

### 使用 docker run

```bash
docker build -t qb-ptbox .

docker run -d \
  --name qb-ptbox \
  -p 8080:8080 \
  -p 45000:45000 \
  -e QB_USERNAME=admin \
  -e QB_PASSWORD=adminadmin \
  -e QB_CACHE_SIZE=1024 \
  -v $(pwd)/downloads:/app/downloads \
  -v $(pwd)/config:/app/config \
  qb-ptbox
```

## 环境变量

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `QB_USERNAME` | `admin` | WebUI 用户名 |
| `QB_PASSWORD` | `adminadmin` | WebUI 密码 |
| `QB_WEBUI_PORT` | `8080` | WebUI 端口 |
| `QB_INCOMING_PORT` | `45000` | BT 监听端口 |
| `QB_CACHE_SIZE` | `512` | 磁盘缓存（MB），建议设为内存的 1/4 |

## 目录结构

```
qb-ptbox/
├── Dockerfile          # 镜像构建文件
├── docker-compose.yml  # 编排配置
├── entrypoint.sh       # 容器启动脚本
├── Install.sh          # 原始 seedbox 安装脚本（参考）
├── downloads/          # 下载目录（运行时自动创建）
└── config/             # qBittorrent 配置目录（运行时自动创建）
```

## 缓存建议

- 普通用途：内存的 1/4，如 8GB 内存设 `QB_CACHE_SIZE=2048`
- qBittorrent 4.3.x 存在内存泄漏，建议设为内存的 1/8

## License

MIT License - Copyright (c) 2025 wsng911
