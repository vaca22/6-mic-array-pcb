#!/bin/bash
# 自动把树莓派整卡压缩拉取到 6-mic-array-pcb 目录
# 确保树莓派开机且与电脑互通后执行本脚本
# Pi 地址改 6-mic-array-pcb/pi-ip.conf 里的 PI_IP 即可

set -e
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
[ -f "$DIR/pi-ip.conf" ] && . "$DIR/pi-ip.conf"
PI_IP="${1:-${PI_IP:-192.168.167.20}}"
OUT="$DIR/pi-backup-$(date +%Y%m%d-%H%M).img.gz"

echo "Pi: $PI_IP"
echo "输出: $OUT"
echo "约 10–30 分钟，请保持网络稳定..."
echo ""

sshpass -p 'raspberry' ssh -o StrictHostKeyChecking=no \
  -o ServerAliveInterval=30 -o ServerAliveCountMax=120 \
  "pi@$PI_IP" "sudo dd if=/dev/mmcblk0 bs=4M status=progress 2>/dev/null" \
  | gzip -c > "$OUT"

ls -lh "$OUT"
echo "完成: $OUT"
