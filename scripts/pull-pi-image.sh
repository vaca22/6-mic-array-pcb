#!/bin/bash
# 把树莓派整张 SD 卡拉到电脑，生成可烧录的 .img（或 .img.gz）
# 用法: ./pull-pi-image.sh [Pi的IP] [保存路径]
# 例:   ./pull-pi-image.sh 192.168.167.20 ~/Desktop/pi-backup.img.gz
# Pi 地址也可写在上一级 pi-ip.conf 的 PI_IP

set -e
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
[ -f "$DIR/pi-ip.conf" ] && . "$DIR/pi-ip.conf"
PI_IP="${1:-${PI_IP:-192.168.167.20}}"
OUT="${2:-$DIR/pi-backup-$(date +%Y%m%d).img.gz}"
OUT_RAW="${OUT%.gz}"

echo "Pi: $PI_IP"
echo "输出: $OUT"
echo "整卡约 29GB，压缩后约 5–8GB，需 10–30 分钟。"
if [[ "${SKIP_CONFIRM:-0}" != "1" ]]; then
  read -p "继续? [y/N] " -n 1 -r; echo
  [[ $REPLY =~ ^[Yy]$ ]] || exit 0
fi

# 压缩则直接写 .gz，否则写 .img
if [[ "$OUT" == *.gz ]]; then
  sshpass -p 'raspberry' ssh -o StrictHostKeyChecking=no "pi@$PI_IP" \
    "sudo dd if=/dev/mmcblk0 bs=4M status=progress 2>/dev/null" | gzip -c > "$OUT"
else
  sshpass -p 'raspberry' ssh -o StrictHostKeyChecking=no "pi@$PI_IP" \
    "sudo dd if=/dev/mmcblk0 bs=4M status=progress 2>/dev/null" > "$OUT"
fi

echo "完成: $OUT"
echo "烧录到新卡: 解压后用 Raspberry Pi Imager 选「自定义」选该 .img，或:"
echo "  gunzip -c $OUT | sudo dd of=/dev/sdX bs=4m status=progress"
