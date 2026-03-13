#!/bin/bash
# 树莓派 4 / Raspberry Pi OS 国内镜像源（清华）- DEB822 格式
# 适用于 /etc/apt/sources.list.d/debian.sources 和 raspi.sources
# 使用前请备份：sudo cp /etc/apt/sources.list.d/debian.sources /etc/apt/sources.list.d/debian.sources.bak
#              sudo cp /etc/apt/sources.list.d/raspi.sources /etc/apt/sources.list.d/raspi.sources.bak

set -e
MIRROR="https://mirrors.tuna.tsinghua.edu.cn"

echo "=== 配置清华源 (DEB822) ==="

# Debian 基础 + updates，trixie
sudo tee /etc/apt/sources.list.d/debian.sources << 'DEBIAN_EOF'
Types: deb
URIs: https://mirrors.tuna.tsinghua.edu.cn/debian/
Suites: trixie trixie-updates
Components: main contrib non-free non-free-firmware
Signed-By: /usr/share/keyrings/debian-archive-keyring.pgp

Types: deb
URIs: https://mirrors.tuna.tsinghua.edu.cn/debian-security/
Suites: trixie-security
Components: main contrib non-free non-free-firmware
Signed-By: /usr/share/keyrings/debian-archive-keyring.pgp
DEBIAN_EOF

# 树莓派仓库
sudo tee /etc/apt/sources.list.d/raspi.sources << 'RASPI_EOF'
Types: deb
URIs: https://mirrors.tuna.tsinghua.edu.cn/raspberrypi/
Suites: trixie
Components: main
Signed-By: /usr/share/keyrings/raspberrypi-archive-keyring.pgp
RASPI_EOF

echo "已写入 debian.sources 与 raspi.sources（清华源）"
sudo apt-get update
echo "apt update 完成。"
