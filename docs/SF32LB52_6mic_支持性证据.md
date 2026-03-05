# SF32LB52 与 6Mic 支持性证据

## 结论

- 结论不是“芯片绝对不能做 6Mic 系统”，而是：
  - **官方公开资料未给出 SF32LB52 的多槽 TDM 接收能力**；
  - 公开接口明确为 `1x I2S + 1x PDM`；
  - SDK I2S 配置模型是 `mono/stereo`，不是 `TDM slot`。
- 因此在“6 路独立数字麦通道直入 MCU”这个目标上，**当前证据不足以支持可行**。
- **直接用 MCU 的 PDM 外设时，最多 2 路 PDM 通道（L/R），等效最多 2 颗 PDM Mic（同一数据线时分）**。

## 证据 1：官方硬件文档列出的音频接口数量

来源：`SF32LB52x-HW-Application`  
链接：<https://wiki.sifli.com/hardware/SF32LB520-3-5-7-HW-Application.html>

抓取原文摘录：

```text
1x I2S音频接口
1x PDM音频接口
1x 差分模拟音频输出
1x 单端模拟音频输入
```

这说明公开规格是单个 I2S、单个 PDM 口，并未列出 TDM 独立接口项。

## 证据 2：官方 User Manual 的音频章节结构

来源：`UM5201-SF32LB52x-EN`（官方用户手册）  
文档下载地址：<https://downloads.sifli.com/docs/user%20manual/SF32LB52x/UM5201%E2%80%90SF32LB52x%E2%80%90EN.pdf>

目录摘录（手册目录页）：

```text
11 Audio
11.1 PDM
11.2 I2S
11.3 Audprc
11.4 Audcodec
```

I2S 章节摘录（I2S介绍页）：

```text
HPSYS has one I2S module. It supports master mode and slave mode.
Currently, I2S supports MSB alignment (left-aligned), LSB alignment (right-aligned), and the I2S standard mode.
```

这类描述是标准 I2S 三种对齐模式，没有给出 TDM 多时隙模式定义。

## 证据 3：SDK I2S 驱动配置项是单/双声道

来源：SDK 驱动文档  
链接：<https://docs.sifli.com/projects/sdk/latest/en/sf32lb52x/drivers/i2s.html>

摘录 1：

```text
Main functionalities include:
i2s samplerate
i2s channel
i2s sample bitwidth
i2s slave/master select
```

摘录 2（示例配置）：

```c
/* 1 for mono, 2 for stereo */
caps.udata.config.channels = 2;
```

来源：HAL I2S API  
链接：<https://docs.sifli.com/projects/sdk/latest/sf32lb52x/api/hal/i2s.html>

摘录 3（结构体字段说明）：

```text
track: 1 mono, 0 stereo
```

这进一步表明公开 SDK 的 I2S 配置维度是 mono/stereo，而不是 TDM slot/channel map。

## 证据 4：DevKit-Nano 可见音频引脚和能力

来源：DevKit Nano 官方页面  
链接：<https://wiki.sifli.com/board/sf32lb52x/SF32LB52-DevKit-Nano.html>

页面说明包含：
- 支持 I2S、PDM、模拟音频输入输出；
- 暴露 `I2S1_BCK/I2S1_LRCK/I2S1_SDI/I2S1_SDO/I2S1_MCLK`；
- 另有 `PDM1_CLK/PDM1_DAT`。

即：接口模型与“1 路 I2S + 1 路 PDM”一致。

## 工程判断（对应你的问题）

- 如果你要的是“**6 路独立 Mic 采样流进入 MCU**”，当前官方文档链路里没有足够证据证明 SF32LB52 具备对应 TDM 多槽接收能力。
- 如果你接受“**前端先做降维/混音，再给 MCU 双声道 I2S**”，则 SF32LB52 可以用。

## 证据 5：深入到 I2S 寄存器，未见 TDM/Slot 字段

来源：同一份 `UM5201-SF32LB52x-EN.pdf`（I2S 章节寄存器页）

I2S 时序模式寄存器摘录：

```text
AUDIO_SERIAL_TIMING.timing
00: I2S mode
01: Left justified
10: right justified
11: reserved
```

I2S 声道相关寄存器摘录：

```text
TX_PCM_FORMAT.track_flag
0: stereo
1: mono
```

说明：
- 公开寄存器给出的数据格式选择仅是 `I2S/Left/Right justified`；
- 声道维度是 `mono/stereo`，没有 `slot_num/slot_width/tdm_enable` 这类典型 TDM 多槽字段。

## 证据 6：官方 SDK 源码层（SiFli-SDK）仍无 TDM 配置路径

来源：OpenSiFli 官方仓库
- 仓库：<https://github.com/OpenSiFli/SiFli-SDK>
- I2S HAL 头文件：<https://raw.githubusercontent.com/OpenSiFli/SiFli-SDK/main/drivers/Include/bf0_hal_i2s.h>
- I2S HAL 源文件：<https://raw.githubusercontent.com/OpenSiFli/SiFli-SDK/main/drivers/hal/bf0_hal_i2s.c>

头文件结构体摘录：

```c
uint8_t track;      /* 1 mono, 0 stereo */
uint8_t lrck_invert;/* standard I2S / Left-Right Justified */
uint8_t pcm_dw;     /* data width */
```

源码寄存器配置摘录：

```c
/* 0 I2S mode, 1 left justified, 2 right justifiled */
AUDIO_SERIAL_TIMING.TIMING = ...

/* Mono or stereo */
TX_PCM_FORMAT.TRACK_FLAG = ...
```

说明：
- HAL 配置项和驱动写寄存器路径都围绕 I2S/LJ/RJ + mono/stereo；
- 没有发现 TDM 多槽的初始化参数、寄存器写入或模式枚举。

## 证据 7：PDM 外设通道模型是 Left/Right（2 路）

来源 1：SDK HAL PDM API  
链接：<https://docs.sifli.com/projects/sdk/latest/sf32lb52x/api/hal/pdm.html>

摘录：

```text
enum PDM_ChannelTypeDef
PDM_CHANNEL_LEFT_ONLY
PDM_CHANNEL_RIGHT_ONLY
PDM_CHANNEL_STEREO
PDM_CHANNEL_STEREO_SWAP
```

来源 2：User Manual PDM 寄存器描述（同一份 UM）  
可见字段为 left/right 双通道状态位，例如：

```text
overflow_l / overflow_r
full_l / empty_l
full_r / empty_r
```

说明：
- PDM 模块公开为左右双通道模型，没有更多通道枚举或多数据口描述；
- 结合开发板引脚 `PDM1_CLK + PDM1_DAT`，可得“单 PDM 口典型最多 2 路”。

---

### 最终判断（深挖后）

- 截至目前公开文档 + 官方 SDK 源码，**没有发现“隐藏 TDM 能力”证据**。
- 所以“SF32LB52 直接接收 6 路独立数字麦通道”的方案仍不建议作为主方案。
