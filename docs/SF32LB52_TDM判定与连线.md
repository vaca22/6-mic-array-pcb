# SF32LB52 是否支持 TDM + 连线建议

## 1. 结论（先看）

- 基于你给的官方文档与用户手册核查，`SF32LB52` **未看到独立 TDM 音频接口/模式**说明。
- 官方明确的是：
  - `1x I2S`
  - `1x PDM`
  - 模拟 `ADC/DAC`（codec）
- SDK 的 `I2S` 驱动配置项也是以 `mono/stereo`、`sample bitwidth`、`master/slave` 为主，未给出 TDM slot 配置项。

结论落地：
- **按官方资料，SF32LB52 不建议按多槽 TDM(例如 8-slot)方案来接收 6 路麦克风。**
- 你当前 6Mic 方案如果坚持 `TLV320ADC3140`，建议：
  1) 降级成 TLV 输出标准 I2S 双声道给 MCU；或  
  2) 更换支持 TDM 多槽接收的主控。

## 2. 我参考的文档点

- DevKit Nano 页：支持 `I2S`、`PDM`，并给出 `I2S1_BCK/LRCK/SDI/SDO/MCLK` 引脚复用。
- SDK I2S 驱动页：功能为采样率、声道、位宽、主从；示例按普通 I2S 设备使用。
- SF32LB52x User Manual（下载核查）：I2S 章节给的是 Standard/Left/Right justified；未检索到独立 `TDM` 术语定义。

## 3. 可行连线 A：`SF32LB52 + TLV320ADC3140`（I2S 双声道）

> 说明：这是“能工作”的保守方案，但无法把 6 路独立麦通道全量送入 MCU。

## A1. 音频串口连线

- `MCU PA29 (I2S1_BCK)` <-> `TLV BCLK`
- `MCU PA30 (I2S1_LRCK)` <-> `TLV FSYNC`
- `MCU PA28 (I2S1_SDI)` <- `TLV SDOUT`  （MCU 接收）
- `MCU PA24 (I2S1_MCLK)` -> `TLV GPIOx/PLL clock in`（可选，按你时钟策略）

## A2. 控制接口（I2C）

- MCU 任意 I2C 两线 -> `TLV SCL_MOSI` / `TLV SDA_SSZ`
- `TLV ADDR0_SCLK`、`ADDR1_MISO` 上拉/下拉设地址
- `TLV SHDNZ` -> MCU GPIO（建议可控）

## A3. TLV 前端 6Mic（PDM）

- Mic1/2 -> `PDMDIN1`（同线，L/R 配对）
- Mic3/4 -> `PDMDIN2`
- Mic5/6 -> `PDMDIN3`
- `PDMCLK` 由 TLV `GPOx` 输出到对应麦组

> 关键限制：MCU 端只收 I2S 双声道，6 路独立信息需要在 TLV 内部做取舍/混合后再送 MCU。

## 4. 可行连线 B：`SF32LB52` 直接接 PDM 麦（最简）

> 说明：适合快速验证，但通常是 1 组 PDM（左右时分）= 2 路麦，不是 6 路阵列。

- `MCU PA07 (PDM1_CLK)` -> PDM Mic `CLK`
- `MCU PA08 (PDM1_DAT)` <- PDM Mic `DAT`（L/R 配对同线）
- 麦供电：`3.3V`（或按麦规格 1.8V），每颗就近 `0.1uF`

## 5. 5V 供电时的电源建议（配合上面任一方案）

- `5V -> 3.3V`：`ME6211C33M5G-N`  
  - <https://item.szlcsc.com/84106.html> (`C82942`)
- 若你选 1.8V 麦或要降 IO 电平，再加：
  - `3.3V -> 1.8V`：`ME6211C18M5G-N`  
  - <https://item.szlcsc.com/236111.html> (`C236671`)

## 6. 给你的决策建议

如果目标是“**6Mic 独立通道 + 阵列算法**”，建议优先：
- 换支持 TDM 多槽接收的 MCU；或
- 让前端 DSP/codec 先完成波束形成/降维，再以 I2S 双声道喂给 SF32LB52。

如果目标是“**尽快打通录音链路**”，当前板子可先：
- 用 `SF32LB52 + 2Mic(PDM)` 或
- `SF32LB52 + TLV(I2S 双声道输出)`。
