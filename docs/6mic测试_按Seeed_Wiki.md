# ReSpeaker 6-Mic 测试 — 按 Seeed 官方 Wiki

完全按 [Seeed Wiki - ReSpeaker 6-Mic Circular Array Kit](https://wiki.seeedstudio.com/ReSpeaker_6-Mic_Circular_Array_kit_for_Raspberry_Pi/) 做**测试**，不采用会改系统、导致开不了机的旧方法（不自动装 overlay、不改 config.txt）。

---

## 一、驱动安装（仅在树莓派能正常开机时做）

在树莓派上**按 Wiki 步骤**安装 seeed-voicecard（官方仓库）：

```bash
sudo apt-get update
sudo apt-get upgrade
git clone https://github.com/respeaker/seeed-voicecard.git
cd seeed-voicecard
sudo ./install.sh
sudo reboot
```

**注意：**

- 若系统较新（如 Raspberry Pi OS 2025、内核 6.12），`sudo ./install.sh` 可能报错（如找不到 raspberrypi-kernel-headers、或 rtd->id 编译错误）。此时**不要强行改 config.txt 或加 Pi5 overlay**，以免再次导致无法开机。
- 若安装失败，可暂时不装驱动，仅用本仓库脚本做「有驱动时的标准测试」；等官方或社区有适配新内核的安装方式后再装。

---

## 二、6-Mic 测试（Wiki 录音 + 校验）

Wiki 说明：**8 路输入，前 6 路为麦克风**；录音格式：`arecord -D ac108 -f S32_LE -r 16000 -c 8`。

### 2.1 在树莓派上直接跑

```bash
cd /path/to/6-mic-array-pcb/scripts
chmod +x test_6mic_wiki.sh verify_wav.py
./test_6mic_wiki.sh
```

### 2.2 从本机推脚本到 Pi 再执行

```bash
scp scripts/test_6mic_wiki.sh scripts/verify_wav.py pi@<树莓派IP>:/tmp/
ssh pi@<树莓派IP> "cd /tmp && chmod +x test_6mic_wiki.sh verify_wav.py && ./test_6mic_wiki.sh"
```

### 2.3 脚本做了什么（与 Wiki 一致）

1. 检查 `arecord -L` 是否出现 **ac108** 或 **seeed8micvoicec**。
2. 使用设备 **ac108**（若无则用 `plughw:CARD=seeed8micvoicec,DEV=0`）。
3. 按 Wiki 录音：`arecord -D ac108 -f S32_LE -r 16000 -c 8`，保存为 8 通道 WAV。
4. 用 `verify_wav.py` 校验：8 通道、前 6 路为麦克风且有有效信号。

---

## 三、手动按 Wiki 录音/播放（可选）

```bash
# 录音（前 6 路为麦克风）
arecord -D ac108 -f S32_LE -r 16000 -c 8 a.wav

# 播放（Wiki：用 AC101 播放）
aplay -D ac101 a.wav
```

---

## 四、相关文件

| 文件 | 说明 |
|------|------|
| `scripts/test_6mic_wiki.sh` | 按 Wiki 的 6-Mic 自动测试（仅录音+校验） |
| `scripts/verify_wav.py` | 校验 8 通道 WAV，前 6 路为麦克风 |
| Wiki | https://wiki.seeedstudio.com/ReSpeaker_6-Mic_Circular_Array_kit_for_Raspberry_Pi/ |

不安装、不修改系统；若之前因改 config/overlay 导致开不了机，请勿再使用会改系统的安装方式，仅按上述步骤在**已能正常开机**的系统中安装驱动并跑本测试。
