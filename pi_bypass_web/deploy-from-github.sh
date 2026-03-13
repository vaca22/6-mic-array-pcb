#!/bin/bash
# 在树莓派上运行：先确保已使用旁路由（能访问 GitHub），再从 GitHub 克隆仓库并部署 pi_bypass_web。
# 用法: bash deploy-from-github.sh [--no-clone] [--enable-gateway-boot]
#   --no-clone          不重新克隆，使用当前目录或 ~/6-mic-array-pcb
#   --enable-gateway-boot  开机自动启用旁路由

set -e
REPO_URL="${REPO_URL:-https://github.com/vaca22/6-mic-array-pcb.git}"
REPO_DIR="${REPO_DIR:-$HOME/6-mic-array-pcb}"
BYPASS_WEB_DIR="$REPO_DIR/pi_bypass_web"
ENABLE_GATEWAY_BOOT=""

while [ -n "$1" ]; do
  case "$1" in
    --no-clone)          SKIP_CLONE=1; shift ;;
    --enable-gateway-boot) ENABLE_GATEWAY_BOOT=1; shift ;;
    *) shift ;;
  esac
done

echo "=== 旁路由配置 Web · 从 GitHub 部署 ==="

# 若未跳过克隆，则克隆或更新仓库
if [ -z "$SKIP_CLONE" ]; then
  if [ -d "$REPO_DIR/.git" ]; then
    echo "已有仓库 $REPO_DIR，拉取最新..."
    git -C "$REPO_DIR" pull --depth 1 || true
  else
    echo "克隆 $REPO_URL 到 $REPO_DIR ..."
    git clone --depth 1 "$REPO_URL" "$REPO_DIR"
  fi
fi

if [ ! -d "$BYPASS_WEB_DIR" ] || [ ! -f "$BYPASS_WEB_DIR/server.py" ]; then
  echo "错误: 未找到 $BYPASS_WEB_DIR 或 server.py"
  exit 1
fi

# 部署目录：与 bypass-web.service 一致
DEPLOY_DIR="$HOME/bypass_web"
mkdir -p "$DEPLOY_DIR"
echo "复制文件到 $DEPLOY_DIR ..."
cp -f "$BYPASS_WEB_DIR/server.py" "$BYPASS_WEB_DIR/index.html" "$BYPASS_WEB_DIR/bypass-ctl.sh" "$DEPLOY_DIR/"
[ -f "$BYPASS_WEB_DIR/bypass-gateway.service" ] && cp -f "$BYPASS_WEB_DIR/bypass-gateway.service" "$DEPLOY_DIR/"
[ -f "$BYPASS_WEB_DIR/bypass-web.service" ]     && cp -f "$BYPASS_WEB_DIR/bypass-web.service" "$DEPLOY_DIR/"

# 安装 bypass-ctl.sh 到系统
echo "安装 bypass-ctl.sh 到 /usr/local/bin ..."
sudo cp -f "$DEPLOY_DIR/bypass-ctl.sh" /usr/local/bin/
sudo chmod +x /usr/local/bin/bypass-ctl.sh

# sudo 免密
echo "配置 sudoers ..."
echo 'pi ALL=(ALL) NOPASSWD: /usr/local/bin/bypass-ctl.sh' | sudo tee /etc/sudoers.d/bypass-ctl
sudo chmod 440 /etc/sudoers.d/bypass-ctl

# 可选：开机启用旁路由
if [ -n "$ENABLE_GATEWAY_BOOT" ]; then
  echo "安装并启用 bypass-gateway.service（开机使用旁路由）..."
  sudo cp -f "$DEPLOY_DIR/bypass-gateway.service" /etc/systemd/system/
  sudo systemctl daemon-reload
  sudo systemctl enable bypass-gateway.service
fi

# 安装并启动配置网页服务
echo "安装并启用 bypass-web.service ..."
sudo cp -f "$DEPLOY_DIR/bypass-web.service" /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable bypass-web.service
sudo systemctl start bypass-web.service

echo ""
echo "部署完成。访问: http://<本机IP>:8081"
echo "若未启用旁路由，可先在网页中点击「使用旁路由」或执行: sudo /usr/local/bin/bypass-ctl.sh enable"
echo ""
