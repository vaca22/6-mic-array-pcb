#!/bin/bash
# 当前 SD 卡已是 disk8，执行此脚本后输入 Mac 密码即可开始克隆
set -e
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$DIR/pi-backup-$(date +%Y%m%d-%H%M).img"
echo "克隆 disk8 -> $OUT"
diskutil unmountDisk disk8 2>/dev/null || true
sudo dd if=/dev/rdisk8 of="$OUT" bs=32m status=progress
echo "完成: $OUT"
echo "压缩可选: gzip $OUT 得到 .img.gz"
