#!/bin/bash
# 制作「SSH 直接能用」的树莓派固件（Raspberry Pi OS Lite）
# 用法一（推荐）：已刷好官方镜像的 TF 卡插入 Mac 后执行
#   ./make-ssh-ready-image.sh
# 用法二：对 .img 文件写入 ssh + userconf，得到新镜像后再 dd 到卡
#   ./make-ssh-ready-image.sh /path/to/raspios-lite.img.xz
#   # 或已解压的 .img
#   ./make-ssh-ready-image.sh /path/to/raspios-lite.img
#
# 首次启动后：用户 pi，密码 raspberry；请尽快执行 passwd 修改密码。

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# pi / raspberry 的 userconf 行（openssl passwd -6）
USERCONF='pi:$6$uvq9KxjRwxd7fd0Z$ofZd7cIPFBUYjs6spaLmyo3FQHbe8cMeMZ/r7DHkS/ckod9GDAL7IAEPc8zGkNJ4GvK/.0WifOTTnc8tVyZJI/'

prepare_boot_partition() {
  local boot_dir="$1"
  if [[ ! -d "$boot_dir" ]]; then
    echo "错误: boot 目录不存在: $boot_dir"
    return 1
  fi
  touch "$boot_dir/ssh"
  echo "$USERCONF" > "$boot_dir/userconf.txt"
  echo "  已写入: $boot_dir/ssh, $boot_dir/userconf.txt（用户 pi，密码 raspberry）"
  return 0
}

# ---------- 模式一：TF 卡已插入，挂载为卷 ----------
if [[ -z "$1" ]]; then
  BOOT="/Volumes/bootfs"
  if [[ ! -d "$BOOT" ]]; then
    # 常见卷名
    for name in bootfs boot "bootfs" "boot"; do
      if [[ -d "/Volumes/$name" ]]; then
        BOOT="/Volumes/$name"
        break
      fi
    done
  fi
  if [[ ! -d "$BOOT" ]]; then
    echo "错误: 未找到 boot 分区（/Volumes/bootfs 或 /Volumes/boot）"
    echo "请先：用官方镜像刷好 TF 卡 → 树莓派不要上电 → 取出卡插入 Mac，再运行本脚本。"
    exit 1
  fi
  echo "=== 在 TF 卡 boot 分区写入 SSH + 用户 ==="
  echo "目标: $BOOT"
  prepare_boot_partition "$BOOT"
  diskutil eject "$BOOT" 2>/dev/null || true
  echo "已推出。将 TF 卡插回树莓派上电，约 1 分钟后可用: ssh pi@<树莓派IP>"
  exit 0
fi

# ---------- 模式二：修改 .img 文件 ----------
IMG_INPUT="$1"
IMG_RAW=""
if [[ "$IMG_INPUT" == *.img.xz ]]; then
  IMG_RAW="${IMG_INPUT%.xz}"
  if [[ ! -f "$IMG_RAW" ]] || [[ "$IMG_INPUT" -nt "$IMG_RAW" ]]; then
    echo "解压: $IMG_INPUT -> $IMG_RAW"
    xz -dkf "$IMG_INPUT" 2>/dev/null || xz -dc "$IMG_INPUT" > "$IMG_RAW"
  fi
elif [[ "$IMG_INPUT" == *.img ]]; then
  IMG_RAW="$IMG_INPUT"
else
  echo "用法: $0  或  $0 <xxx.img.xz|xxx.img>"
  exit 1
fi

if [[ ! -f "$IMG_RAW" ]]; then
  echo "错误: 找不到镜像文件: $IMG_RAW"
  exit 1
fi

MOUNT_POINT="/tmp/rpi_boot_$$"
cleanup() {
  if mount | grep -q "$MOUNT_POINT"; then
    sudo umount "$MOUNT_POINT" 2>/dev/null || true
  fi
  rm -rf "$MOUNT_POINT"
  if [[ -n "$ATTACHED_DISK" ]]; then
    hdiutil detach "$ATTACHED_DISK" 2>/dev/null || true
  fi
}
trap cleanup EXIT

echo "=== 挂载镜像 boot 分区并写入 SSH + 用户 ==="
echo "镜像: $IMG_RAW"
# 可写挂载以便修改 boot 分区
hdiutil attach -nomount "$IMG_RAW" > /tmp/hdi_$$.txt 2>/dev/null || true
# 输出示例: /dev/disk4
ATTACHED_DISK=$(grep -oE '/dev/disk[0-9]+' /tmp/hdi_$$.txt | head -1)
rm -f /tmp/hdi_$$.txt
if [[ -z "$ATTACHED_DISK" ]]; then
  echo "错误: 无法挂载镜像，请确认是有效的树莓派 .img 文件"
  exit 1
fi

# 第一个分区多为 boot (FAT32)，如 disk4s1
BOOT_PART="${ATTACHED_DISK}s1"
if [[ ! -e "$BOOT_PART" ]]; then
  # 有些镜像分区为 disk4s2 等，取第一个
  for p in "${ATTACHED_DISK}s1" "${ATTACHED_DISK}s2"; do
    if [[ -e "$p" ]]; then BOOT_PART="$p"; break; fi
  done
fi
if [[ ! -e "$BOOT_PART" ]]; then
  echo "错误: 未找到分区设备 (如 ${ATTACHED_DISK}s1)"
  hdiutil detach "$ATTACHED_DISK" 2>/dev/null || true
  exit 1
fi

mkdir -p "$MOUNT_POINT"
# macOS 上 FAT 为 msdos
sudo mount -t msdos "$BOOT_PART" "$MOUNT_POINT"
prepare_boot_partition "$MOUNT_POINT"
sync
sudo umount "$MOUNT_POINT"
hdiutil detach "$ATTACHED_DISK"

echo "完成。已修改镜像: $IMG_RAW"
echo "请将该镜像写入 TF 卡，例如:"
echo "  xz -dc <原版.img.xz> | sudo dd of=/dev/rdisk<N> bs=4m status=progress"
echo "  # 或直接: sudo dd if=$IMG_RAW of=/dev/rdisk<N> bs=4m status=progress"
echo "写入后上电，约 1 分钟后: ssh pi@<树莓派IP>，密码 raspberry"
