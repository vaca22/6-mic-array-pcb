# ReSpeaker 6-Mic 在树莓派 5 上的探索与结论

本文档记录在树莓派 5 上使用 ReSpeaker 6-Mic Circular Array 的完整探索过程、遇到的问题、尝试的修复方案及最终结论。

---

## 一、背景

- **硬件**：ReSpeaker 6-Mic Circular Array Kit（2×AC108 ADC + 1×AC101 DAC，6 路麦克风）
- **平台**：树莓派 5，内核 6.12.47+rpt-rpi-2712
- **目标**：在 Pi 5 上实现 6 个麦克风通道正常录音

---

## 二、探索过程

### 2.1 初始状态

首次通过 SSH 运行测试脚本时：

- `arecord -L` 仅显示 **Google Voice HAT**（sndrpigooglevoi），未见 ReSpeaker 设备
- 系统未安装 seeed-voicecard 驱动

### 2.2 驱动安装

**步骤 1：尝试官方 respeaker/seeed-voicecard**

- 执行 `sudo ./install.sh` 后，DKMS 编译失败
- 错误：`'struct snd_soc_pcm_runtime' has no member named 'id'`
- 原因：内核 6.12 中 ASoC API 变更，`rtd->id` 已移除

**步骤 2：改用 HinTak 分支**

- 使用 `https://github.com/HinTak/seeed-voicecard`（支持新内核）
- 仍出现 `rtd->id` 编译错误

**步骤 3：手动修复内核 API**

- 在 `seeed-voicecard.c` 中将所有 `rtd->id` 替换为 `rtd->num`
- 重新执行 `sudo ./install.sh` 后，内核模块编译成功并安装

**步骤 4：设备树 overlay 问题**

- 安装后 `arecord -l` 仍无 seeed 设备
- dmesg 显示：`seeed-voicecard soc@...:sound: probe with driver seeed-voicecard failed with error -22`
- 原因：原 overlay 使用 `&i2s`（在 Pi 5 上解析为 `i2s_clk_producer`），而 AC108 作为时钟主设备，需要 Pi 使用 `i2s_clk_consumer`

### 2.3 Pi 5 专用 overlay

**创建 `seeed-8mic-voicecard-pi5-overlay.dts`：**

- `compatible = "brcm,bcm2712"`
- 将 `&i2s` 改为 `&i2s_clk_consumer`（fragment@0 及 cpu 的 sound-dai）
- 保持 `bitclock-master`、`frame-master` 指向 codec
- 禁用冲突的 `hifiberry-dac`、`googlevoicehat-soundcard` overlay

**结果**：设备成功 probe，`arecord` 可录音，但 **仅 1 个通道有数据**。

### 2.4 尝试修复 6 通道

**修改 TDM 配置：**

- 原配置：`dai-tdm-slot-num = <2>`，`dai-tdm-slot-rx-mask = <1 1 0 0>`（仅 2 槽）
- AC108 双芯片使用 8 槽：chip0 占 6,7,0,1，chip1 占 2,3,4,5
- 修改为：`dai-tdm-slot-num = <8>`，`dai-tdm-slot-rx-mask = <1 1 1 1 1 1 1 1>`

**结果**：录音正常，但 **仍只有 1 个通道有数据**。

---

## 三、根因分析

### 3.1 问题定位

- 在 Pi 4 上，ReSpeaker 6-Mic 可正常输出 6 通道
- 在 Pi 5 上，仅 1 通道有数据
- 差异在于：Pi 5 使用 **RP1 芯片** 处理 I2S，与 Pi 4 的 BCM2835 I2S 不同

**Pi 4 上 6 通道正常工作的证据：**

1. **Seeed 官方 Wiki**（[ReSpeaker 6-Mic Circular Array](https://wiki.seeedstudio.com/ReSpeaker_6-Mic_Circular_Array_kit_for_Raspberry_Pi/)）  
   - 兼容列表明确包含 Raspberry Pi 4  
   - 说明「前 6 路输入通道为麦克风录音」  
   - 提供 `arecord -c 8` 及 PyAudio 按通道提取（`[0::8]`～`[7::8]`）的示例  
   - DOA（到达角）示例依赖多路麦克风，需多通道有效数据

2. **respeaker/seeed-voicecard#342**（[4-mic array and Pi 5 support](https://github.com/respeaker/seeed-voicecard/issues/342)）  
   - 作者使用相同 AC108 + seeed-voicecard 驱动  
   - 明确描述：「On the RPI-4: The HAT works pretty well and is able to capture 4 channel audio」  
   - 6-Mic 与 4-Mic 共用 seeed-voicecard，仅 overlay 不同（seeed-8mic-voicecard），驱动逻辑一致

### 3.2 已知问题

- [respeaker/seeed-voicecard#342](https://github.com/respeaker/seeed-voicecard/issues/342)：4 麦在 Pi 5 上仅 1 通道有数据
- [RPi Forum t=373301](https://forums.raspberrypi.com/viewtopic.php?t=373301)：相同现象，用户已用 i2s_clk_consumer overlay
- [raspberrypi/linux#5743](https://github.com/raspberrypi/linux/issues/5743)：Pi 5 I2S 需区分 producer/consumer

### 3.3 结论

**RP1 的 Designware I2S 驱动** 在 `i2s_clk_consumer` 模式下，对多通道 capture 支持不完整，导致仅 1 通道有效。此问题在驱动层，无法通过设备树 overlay 或 TDM 配置解决。

---

## 四、已完成的修复（可正常工作部分）

| 项目 | 说明 |
|------|------|
| 内核 API | `rtd->id` → `rtd->num` |
| Pi 5 overlay | `seeed-8mic-voicecard-pi5.dtbo`，使用 i2s_clk_consumer |
| 设备识别 | 设备可 probe，ALSA 可见 seeed8micvoicec |
| 录音 | `arecord` 可录制 8 通道 WAV |
| 通道数据 | 仅 1/6 麦克风通道有有效数据 |

---

## 五、6 通道可行方案

| 方案 | 可行性 | 说明 |
|------|--------|------|
| **换用树莓派 4** | 高 | 6 麦可全通道工作，使用原 overlay |
| **等待上游修复** | 中 | 需 RP1 I2S 驱动修复 |
| **定期 rpi-update** | 低 | 可能随内核更新改善 |
| **改用 USB 麦克风阵列** | 高 | 如 ReSpeaker USB Mic Array |

---

## 六、相关文件

| 文件 | 说明 |
|------|------|
| `overlays/seeed-8mic-voicecard-pi5-overlay.dts` | Pi 5 overlay 源码 |
| `overlays/seeed-8mic-voicecard-pi5.dtbo` | 编译后的 overlay |
| `scripts/test_6mic.sh` | 6 麦自动测试脚本 |
| `scripts/verify_wav.py` | WAV 通道验证脚本 |
| `PI5_6CH_OPTIONS.md` | 6 通道方案简要说明 |

---

## 七、参考链接

- [ReSpeaker 6-Mic Wiki](https://wiki.seeedstudio.com/ReSpeaker_6-Mic_Circular_Array_kit_for_Raspberry_Pi/)
- [HinTak/seeed-voicecard](https://github.com/HinTak/seeed-voicecard)
- [respeaker/seeed-voicecard#342](https://github.com/respeaker/seeed-voicecard/issues/342)
- [raspberrypi/linux#5743](https://github.com/raspberrypi/linux/issues/5743)
- [raspberrypi/linux#6022](https://github.com/raspberrypi/linux/issues/6022)
- [RPi Forum: 4 channel TDM on RPI-5](https://forums.raspberrypi.com/viewtopic.php?t=373301)

---

*文档整理自 2025-03 探索过程*
