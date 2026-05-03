# qb-ptbox

基于 Docker 的 qBittorrent PT 下载盒子，将 seedbox 安装脚本容器化，开箱即用。

## 快速开始

```bash
git clone https://github.com/wsng911/qb-ptbox.git
cd qb-ptbox
docker compose up -d
```

访问 WebUI：`http://localhost:8080`
用户名：`admin`，密码：首次启动时 qBittorrent 会在日志中输出临时密码，登录后在设置中修改。

查看临时密码：
```bash
docker logs qb-ptbox 2>&1 | grep "temporary password"
```

## 目录结构

| 宿主机目录 | 容器内路径 | 说明 |
|-----------|-----------|------|
| `./downloads` | `/app/downloads` | **下载文件保存目录**，所有种子下载到这里 |
| `./config` | `/app/config` | qBittorrent 配置文件目录 |

目录会在首次运行时自动创建。

## 添加种子

**方式一：WebUI 添加**（推荐）
```
打开 http://localhost:8080 → 点击"+"→ 粘贴磁力链接或上传 .torrent 文件
```

**方式二：监控目录（自动添加）**
在 `docker-compose.yml` 中取消注释 watch 挂载：
```yaml
- ./watch:/app/watch
```
然后在 WebUI → 设置 → 下载 → 监控目录，填入 `/app/watch`。
之后把 `.torrent` 文件放入 `./watch/` 目录即可自动添加。

## 切换 qBittorrent 版本

修改 `docker-compose.yml` 中的 `QB_VERSION` 和 `LIBT_VERSION`：

```yaml
args:
  QB_VERSION: 4.3.9      # qBittorrent 版本
  LIBT_VERSION: 1.2.19   # libtorrent 版本
```

或构建时指定：
```bash
docker build --build-arg QB_VERSION=4.3.9 --build-arg LIBT_VERSION=1.2.19 -t qb-ptbox .
```

**版本对应关系参考：**

| qBittorrent | libtorrent | 说明 |
|-------------|-----------|------|
| 4.6.7 | 2.0.10 | 默认，推荐 |
| 4.6.x | 2.0.x | 稳定版 |
| 4.3.9 | 1.2.19 | 旧版，内存占用低 |

> 完整版本列表：https://github.com/userdocs/qbittorrent-nox-static/releases

## 环境变量

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `QB_USERNAME` | `admin` | WebUI 用户名 |
| `QB_WEBUI_PORT` | `8080` | WebUI 端口 |
| `QB_INCOMING_PORT` | `45000` | BT 监听端口 |
| `QB_CACHE_SIZE` | `512` | 磁盘缓存（MB），建议设为内存的 1/4 |

## 常用命令

```bash
# 启动
docker compose up -d

# 查看日志（含临时密码）
docker logs qb-ptbox

# 停止
docker compose down

# 重建（切换版本后）
docker compose up -d --build
```

## License

MIT License - Copyright (c) 2025 wsng911
