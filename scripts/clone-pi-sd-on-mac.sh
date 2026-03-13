#!/bin/bash
# 树莓派 SD 卡插到 Mac 上，直接克隆为镜像（通常比网络拉取快很多）
# 1. 树莓派关机，取出 SD 卡，插入 Mac 读卡器
# 2. 运行 diskutil list 确认 SD 卡设备号（如 disk2）
# 3. 执行: sudo ./clone-pi-sd-on-mac.sh disk2

set -e
DISK="${1:?用法: sudo $0 <SD卡设备号，如 disk2>}"
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_RAW="$DIR/pi-backup-$(date +%Y%m%d-%H%M).img"
OUT_GZ="${OUT_RAW}.gz"

# 安全：禁止误选系统盘
case "$DISK" in
  disk0|disk1|disk3) echo "请勿选择系统盘，应选 SD 卡（多为 disk2 或 disk4）"; exit 1 ;;
esac

if [[ ! "$DISK" =~ ^disk[0-9]+$ ]]; then
  echo "请传入设备号，如 disk2"
  echo "先运行: diskutil list"
  exit 1
fi

# 使用 rdisk 加速
RDISK="/dev/r${DISK}"
if [[ ! -e "$RDISK" ]]; then
  RDISK="/dev/$DISK"
fi

echo "将从未挂载的 $DISK 克隆到: $OUT_RAW"
echo "请确认 SD 卡对应的是 $DISK（可用 diskutil list 查看）。"
read -p "继续? [y/N] " -n 1 -r; echo
[[ $REPLY =~ ^[Yy]$ ]] || exit 0

# 先卸载该磁盘上的分区（不弹出）
diskutil unmountDisk "$DISK" 2>/dev/null || true

echo "克隆中（约 5–15 分钟）..."
sudo dd if="$RDISK" of="$OUT_RAW" bs=32m status=progress

echo "克隆完成。是否压缩为 .gz 以节省空间? [y/N]"
read -n 1 -r; echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  gzip -f "$OUT_RAW"
  echo "已生成: $OUT_GZ"
  ls -lh "$OUT_GZ"
else
  echo "已生成: $OUT_RAW"
  ls -lh "$OUT_RAW"
fi

echo "烧录到新卡: Raspberry Pi Imager 选「自定义镜像」选上述 .img 或 .img.gz 解压后的 .img"
