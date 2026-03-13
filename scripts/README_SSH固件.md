# SSH 直接可用固件 — 使用说明

无显示器时，让树莓派**第一次上电就能 SSH 登录**的两种方式。

---

## 方式一：刷好官方镜像后，插卡运行脚本（推荐）

1. 用官方 [Raspberry Pi OS Lite](https://www.raspberrypi.com/software/operating-systems/) 镜像刷写 TF 卡（Raspberry Pi Imager 或 `dd`）。
2. **不要给树莓派上电**，把 TF 卡从读卡器插入 Mac。
3. 在项目目录执行（会往 boot 分区写 `ssh` + `userconf.txt`）：
   ```bash
   cd /path/to/6-mic-array-pcb/scripts
   chmod +x make-ssh-ready-image.sh
   ./make-ssh-ready-image.sh
   ```
4. 按提示推出 TF 卡，插回树莓派，上电。
5. 约 1 分钟后在同一局域网用：`ssh pi@<树莓派IP>`，密码：`raspberry`。

---

## 方式二：先做出「带 SSH 的镜像」，再一次性 dd 到卡

适合希望**只做一次 dd、不插两次卡**的情况。

1. 下载官方 Raspberry Pi OS Lite 镜像（.img.xz），例如：
   ```bash
   curl -L -o ~/Desktop/raspios-lite.img.xz "https://downloads.raspberrypi.com/raspios_lite_arm64/images/raspios_lite_arm64-2025-12-04/2025-12-04-raspios-trixie-arm64-lite.img.xz"
   ```
2. 在 Mac 上运行脚本，生成/修改 .img：
   ```bash
   cd /path/to/6-mic-array-pcb/scripts
   ./make-ssh-ready-image.sh ~/Desktop/raspios-lite.img.xz
   ```
   脚本会解压（若需要）、挂载镜像的 boot 分区、写入 `ssh` 和 `userconf.txt`，得到可用的 **.img**。
3. 将该 .img 写入 TF 卡（注意替换 `N` 为你的卡对应设备号）：
   ```bash
   diskutil list   # 确认 TF 卡设备，如 disk4
   diskutil unmountDisk disk4
   sudo dd if=~/Desktop/2025-12-04-raspios-trixie-arm64-lite.img of=/dev/rdisk4 bs=4m status=progress
   diskutil eject disk4
   ```
4. 插卡上电，约 1 分钟后：`ssh pi@<树莓派IP>`，密码 `raspberry`。

---

## 默认账号与安全

- **用户名**：`pi`  
- **密码**：`raspberry`  
- 首次登录后请执行 `passwd` 修改密码。

---

## 相关文档

- 固件/网络踩坑与 6 麦测试：见仓库内 `docs/经验教训_树莓派固件与网络.md`。
