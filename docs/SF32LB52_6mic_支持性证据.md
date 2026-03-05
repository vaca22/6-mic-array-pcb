# SF32LB52 与 6Mic 支持性证据

## 结论

- 结论不是“芯片绝对不能做 6Mic 系统”，而是：
  - **官方公开资料未给出 SF32LB52 的多槽 TDM 接收能力**；
  - 公开接口明确为 `1x I2S + 1x PDM`；
  - SDK I2S 配置模型是 `mono/stereo`，不是 `TDM slot`。
- 因此在“6 路独立数字麦通道直入 MCU”这个目标上，**当前证据不足以支持可行**。

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
