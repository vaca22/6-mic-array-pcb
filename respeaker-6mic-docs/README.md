# ReSpeaker 6-Mic Circular Array Kit for Raspberry Pi — 资料汇总

**官方 Wiki 地址：**  
https://wiki.seeedstudio.com/ReSpeaker_6-Mic_Circular_Array_kit_for_Raspberry_Pi/

---

## 本机树莓派 5 — SSH 连接

| 项目 | 值 |
|------|-----|
| 主机 | 树莓派 5 |
| 用户 | `xiaozhi` |
| 地址 | `192.168.71.10` |

**登录命令：**
```bash
ssh xiaozhi@192.168.71.10
```

### 六麦阵列自动测试

仓库内提供脚本，用于在树莓派上**自动检测设备 → 录音 → 验证 8 通道 WAV（前 6 路为麦克风）**。

**前提：** 树莓派上已安装 **seeed-voicecard** 驱动并重启，`arecord -L` 中能看到 `seeed8micvoicec` 或 `ac108`。

**在本地执行（自动复制脚本到 Pi 并运行）：**
```bash
cd respeaker-6mic-docs
scp scripts/test_6mic.sh scripts/verify_wav.py xiaozhi@192.168.71.10:/tmp/respeaker_test/
ssh xiaozhi@192.168.71.10 "cd /tmp/respeaker_test && chmod +x test_6mic.sh verify_wav.py && ./test_6mic.sh"
```

**或登录 Pi 后执行：**
```bash
# 先将 scripts/ 拷到 Pi 的某目录，例如 ~/respeaker_test/
cd ~/respeaker_test
chmod +x test_6mic.sh verify_wav.py
./test_6mic.sh
```

**脚本步骤：**
1. 检查 ALSA 是否识别 seeed-8mic-voicecard / ac108  
2. 使用 `arecord` 录制 2 秒 8 通道 16 kHz S32_LE  
3. 检查录音文件存在且大小合理  
4. 用 `verify_wav.py` 验证 8 通道、且前 6 路麦克风有非静音信号  

**首次运行结果（当前 Pi 未装 seeed-voicecard）：** 检测到系统为 Google Voice HAT，未发现 ReSpeaker 设备；需在树莓派上安装并启用 seeed-voicecard 后重新测试。

### seeed-voicecard 安装记录（树莓派 5，内核 6.12）

1. **使用 HinTak 分支**：`git clone https://github.com/HinTak/seeed-voicecard.git`
2. **内核 API 修复**：在 `seeed-voicecard.c` 中将 `rtd->id` 全部替换为 `rtd->num`，然后执行 `sudo ./install.sh`。
3. **Pi 5 专用 overlay**：原 overlay 使用 `i2s`（producer），AC108 需 Pi 为 consumer。使用 `overlays/seeed-8mic-voicecard-pi5.dtbo`，在 config.txt 中设置 `dtoverlay=seeed-8mic-voicecard-pi5`。
4. **当前状态**：设备已识别，录音正常；6 麦中通常仅 1 路有数据（Pi 5 + RP1 I2S 已知问题，参见 [respeaker#342](https://github.com/respeaker/seeed-voicecard/issues/342)）。

**完整探索记录**：见 [PI5_探索与结论.md](PI5_探索与结论.md)。

---

## 一、硬件信息摘要

### 产品概述
- Seeed 的 ReSpeaker 6-Mic 圆形麦克风阵列套件，为树莓派扩展板（HAT）。
- 由两块板组成：**语音配件 HAT** + **六麦克风圆形阵列**。
- 面向 AI 与语音应用，可集成 Amazon Alexa、Google Assistant 等。

### 通道与接口
- **输入：** 8 通道（前 6 路为麦克风录音，后 2 路为播放回波）
- **输出：** 8 通道（前 2 路用于播放，后 6 路为占位）
- **音频输出：** 3.5mm 耳机孔、JST 2.0 扬声器接口
- **兼容：** 树莓派 40pin GPIO（Zero/Zero W、B+、2B、3B、3B+、3A+、4）

### 主要规格
| 项目 | 说明 |
|------|------|
| ADC | 2 × X-Power AC108 |
| DAC | 1 × X-Power AC101 |
| 麦克风 | 6 × 高性能麦克风，型号 MSM321A3729H9CP |
| 灵敏度 | -22 dBFS（全向） |
| 信噪比 | 59 dB |
| 最大采样率 | 48 kHz |
| 其他 | 12 颗 GRB LED、Grove 接口、按钮（GPIO 26） |

### 应用场景
智能音箱、语音助手、录音、会议/语音会议、语音交互机器人、车载语音助手等。

---

## 二、软件与驱动摘要

### 驱动与内核
- **seeed-voicecard**（必装）：Linux 内核驱动与 ALSA 配置  
  - 仓库：https://github.com/respeaker/seeed-voicecard  
  - 安装后设备名：`seeed-8mic-voicecard`（录音 `arecord -L` / 播放 `aplay -L`）

### 录音/播放
- **arecord**：`arecord -D ac108 -f S32_LE -r 16000 -c 8 a.wav`（8 通道，前 6 路为麦克风）
- **aplay**：`aplay -D ac101 a.wav`
- 同时录放时：**必须先启动录音**，播放文件需为**单声道**，且输出需填满 8 通道或 4 路立体声数据。

### 语音与算法
- **PyAudio**：多通道录音、按通道提取（如 `[0::8]` 提取通道 0）
- **Voice Engine**：语音流水线（Source、ChannelPicker、KWS、DOA 等）  
  - https://github.com/voice-engine/voice-engine
- **DOA（到达角）**：`voice-engine` 中 `doa_respeaker_6mic_array`，可与 Snowboy 关键词检测结合（示例：`kws_doa.py`）
- **ODAS**：实时声源定位与跟踪  
  - https://github.com/introlab/odas  
  - 配置示例：`respeaker_6_mic_array.cfg`

### LED 与 GPIO
- **pixel_ring**：12 颗 GRB LED 控制  
  - https://github.com/respeaker/pixel_ring  
  - 示例：`python examples/respeaker_4mic_array.py`
- **按钮**：GPIO 26（BCM），用于检测 HAT 安装状态

### 常用依赖
- pyaudio, numpy, snowboy（KWS+DOA）
- libfftw3-dev, libconfig-dev, libasound2-dev, cmake（ODAS）
- RPi.GPIO（按钮）

---

## 三、本文件夹内资源

| 文件 | 说明 |
|------|------|
| `AC101_User_Manual_v1.1.pdf` | AC101 DAC 用户手册 |
| `AC108_Datasheet_V1.2.pdf` | AC108 ADC 数据手册 |
| `2d.zip` | ReSpeaker 6-Mic 圆形阵列 2D 文件（zip） |
| `ReSpeaker_Circular_Array_6Mic_HAT_case.dxf` | 6 麦圆形阵列 Voice Accessory HAT 外壳 DXF |
| `overlays/seeed-8mic-voicecard-pi5.dtbo` | 树莓派 5 专用设备树 overlay（使用 i2s_clk_consumer） |
| `overlays/seeed-8mic-voicecard-pi5-overlay.dts` | 上述 overlay 的源码 |
| `README.md` | 本说明（Wiki 链接 + 硬件/软件摘要） |

---

## 四、官方资源链接（Wiki Resources）

- [AC101 Datasheet (PDF)](https://files.seeedstudio.com/wiki/ReSpeaker_6-Mics_Circular_Array_kit_for_Raspberry_Pi/reg/AC101_User_Manual_v1.1.pdf)
- [AC108 Datasheet (PDF)](https://files.seeedstudio.com/wiki/ReSpeaker_6-Mics_Circular_Array_kit_for_Raspberry_Pi/reg/AC108_Datasheet_V1.2.pdf)
- [Seeed-Voice Driver](https://github.com/respeaker/seeed-voicecard)
- [Voice Engine](https://github.com/voice-engine/voice-engine)
- [Algorithms (DOA, VAD, NS)](https://github.com/respeaker/mic_array)
- [AEC](https://github.com/voice-engine/ec)
- [2D 文件 (zip)](https://files.seeedstudio.com/wiki/ReSpeaker_6-Mics_Circular_Array_kit_for_Raspberry_Pi/reg/2d.zip)
- [外壳 DXF](https://files.seeedstudio.com/wiki/ReSpeaker_6-Mics_Circular_Array_kit_for_Raspberry_Pi/reg/ReSpeaker%20Circular%20Array%20for%20Voice%20Accessory%20HAT%20with%206%20Microphones.dxf)

---

*文档根据 Seeed Wiki 整理，最后更新：2025-03*
