# TLV320ADC3140IRTWT 6Mic 实现指南

基于 `TLV320ADC3140IRTWT_datasheet.pdf` 的典型应用（PDM 数字麦克风模式）整理，目标是 6 路 Mic 输入，单路音频总线输出到主控。

## 1) 先确认架构

- 你说的“单路 I2S”在这里建议按 **TDM over I2S 引脚**实现（BCLK + FSYNC + SDOUT 三线）。
- TLV320ADC3140 支持最多 8 路数字 PDM Mic 输入，6 路需求可覆盖。
- 6 路建议映射到 TDM 8 槽（留 2 槽空位），主控侧处理更简单。

## 2) 最小元器件清单（可上板）

## A. 核心芯片

1. `TLV320ADC3140IRTWT`（音频 ADC/Hub）
   - 链接：<https://item.szlcsc.com/1942834.html>
   - 料号：`C1852021`

## B. 数字麦克风（PDM）6 颗

可选任一系列，建议同型号全阵列一致。结合当前立创参考价和库存，优先级如下：

1. `ICS-41350`（PDM，支持双麦同线时分，当前性价比最高）
   - 链接：<https://item.szlcsc.com/3733793.html>
   - 料号：`C3171856`
   - 参考价/库存：`￥6.46` / `InStock(222)`
2. `ICS-41351`（PDM，1.8V）
   - 链接：<https://item.szlcsc.com/3733780.html>
   - 料号：`C3171843`
   - 参考价/库存：`￥9.12` / `InStock(1)`
3. `VM3011-U1`（PDM，低功耗）
   - 链接：<https://item.szlcsc.com/8116311.html>
   - 料号：`C7149370`
   - 参考价/库存：`￥16.78` / `OutOfStock(0)`

结论：
- **推荐选 `ICS-41350`**：价格更低，库存更稳，参数（64dB SNR、750uA）也足够做 6Mic 阵列。
- `ICS-41351` 只在你明确要全 1.8V 麦克风轨时再考虑；当前库存太少，不建议首板用它。

## C. 电源与基础无源（示例可直接下单）

1. 0.1uF/0402（电源去耦）
   - <https://item.szlcsc.com/1877.html?fromZone=s_s__%25220.1uF%25200402%2522> (`C1525`)
2. 1uF/0402（AREG/VREF/MICBIAS 滤波）
   - <https://item.szlcsc.com/15107.html?fromZone=s_s__%25221uF%25200402%2522> (`C14445`)
3. 10uF/0603（AVDD/IOVDD/DREG 储能）
   - <https://item.szlcsc.com/97651.html?fromZone=s_s__%252210uF%25200603%2522> (`C96446`)
4. 2.2k/0402（I2C 上拉）
   - <https://item.szlcsc.com/26676.html?fromZone=s_s__%25222.2k%25200402%2522> (`C25933`)
5. 33R/0402（时钟/数据串联阻尼，可选）
   - <https://item.szlcsc.com/25848.html?fromZone=s_s__%252233R%25200402%2522> (`C25105`)
6. 0R/0402（调试跳线位）
   - <https://item.szlcsc.com/22093.html?fromZone=s_s__%25220R%25200402%2522> (`C21376`)

> 注：无源器件为“可替换示例料号”，你可按库存替换同规格型号。

## D. 你是 5V 供电时，需要补的电源芯片

### 方案 A（推荐，最省钱，足够 6Mic 前端）

- `5V -> 3.3V LDO`：`ME6211C33M5G-N`
  - 链接：<https://item.szlcsc.com/84106.html>
  - 料号：`C82942`
  - 参考价/库存：`￥0.1812` / `InStock(325207)`

此方案下：
- `TLV320ADC3140` 用 `AVDD=3.3V`、`IOVDD=3.3V`
- 6 个 `ICS-41350` 直接用同一条 `MIC_3V3`
- 不再额外需要 1.8V LDO（电路更简单）

### 方案 B（可选，做双电压电源树）

- `5V -> 3.3V LDO`：`ME6211C33M5G-N`（同上）
- `3.3V -> 1.8V LDO`：`ME6211C18M5G-N`
  - 链接：<https://item.szlcsc.com/236111.html>
  - 料号：`C236671`
  - 参考价/库存：`￥0.1499` / `InStock(36776)`

此方案下：
- 可把 `IOVDD` 或麦克风电源放到 1.8V（看主控 IO 电平兼容性）
- 成本略增、调试复杂度略增

> 只做音频前端（TLV + 6Mic）时，电流通常不大，`5V -> 3.3V` 直接 LDO 很划算。若后级还有 Wi-Fi/屏幕/4G 等大电流负载，再考虑把系统主电源改为 Buck。

## 3) 关键连线（按 PDM 6Mic）

## A. TLV 与主控

- `SDOUT` -> 主控 `I2S_RXD`（或 TDM_RXD）
- `BCLK`  <-> 主控 `I2S_BCLK`
- `FSYNC` <-> 主控 `I2S_LRCLK/WS`
- `SCL_MOSI` + `SDA_SSZ` -> 主控 I2C（推荐）  
- `ADDR0_SCLK`、`ADDR1_MISO`：按 I2C 地址绑高低（常见先都下拉）
- `SHDNZ` -> 主控 GPIO（建议加 100k 下拉，默认关断）

## B. TLV 与 6 个 PDM Mic

TLV 的 1 组 `PDMDINx` 可接 2 个 PDM 麦（通过 Mic 的 L/R 选择实现时分复用）：

- `GPO1` 配置为 `PDMCLK` -> Mic1/Mic2 `CLK`
- `GPI1` 配置为 `PDMDIN1` <- Mic1/Mic2 `DATA`（同一根线）

- `GPO2` 配置为 `PDMCLK` -> Mic3/Mic4 `CLK`
- `GPI2` 配置为 `PDMDIN2` <- Mic3/Mic4 `DATA`

- `GPO3` 配置为 `PDMCLK` -> Mic5/Mic6 `CLK`
- `GPI3` 配置为 `PDMDIN3` <- Mic5/Mic6 `DATA`

- `GPO4/GPI4` 预留（后续可扩到 8Mic）

每对麦中：
- 一颗 `LR/SEL=0`（左）
- 一颗 `LR/SEL=1`（右）

## C. 电源与去耦（按 datasheet 典型值）

- `AVDD`：0.1uF + 10uF 靠近芯片
- `IOVDD`：0.1uF + 10uF 靠近芯片
- `DREG`：0.1uF + 10uF 靠近芯片
- `AREG`：1uF
- `VREF`：1uF（非常靠近）
- `MICBIAS`：1uF（若不用可不外供 Mic）
- 裸露焊盘 `Thermal Pad (VSS)` 必须直连地平面并打导热过孔

PDM 麦克风供电补充（重点）：
- 每颗 PDM 麦 `VDD` 旁边放 `0.1uF` 去耦（距离尽量 < 2mm）。
- 每 2 颗麦（同一 PDMDIN 组）再并 1 颗 `1uF` 本地储能。
- 6 颗麦的 `MIC_3V3` 建议从 TLV 主电源分一条支路，入口可预留磁珠位（0R/磁珠二选一）做噪声对比。
- `MICBIAS` 是给模拟麦的偏置，**PDM 麦一般不用 MICBIAS 供电**，直接上 `3.3V` 或 `1.8V` 数字电源。

## 4) 走线要点（避免后期噪声/丢码）

- BCLK/FSYNC/SDOUT 与 PDM 时钟线尽量短，地参考连续。
- 每组 PDMCLK 与 PDMDIN 成对就近布线，避免跨分割地。
- 若边沿振铃明显，在源端串 `22R~33R`（预留 0R/33R 位最稳妥）。
- 模拟地/数字地最终单点或完整地平面策略保持一致，不要割裂芯片下方回流路径。

## 5) 上电与初始化（最小流程）

1. 上电 `AVDD/IOVDD`，保持 `SHDNZ=0`
2. 电源稳定后拉高 `SHDNZ`
3. 等待至少 1ms
4. I2C 写寄存器，配置 PDM 输入与 TDM 输出

datasheet 示例（PDM 模式）关键寄存器片段：

- `P0_R60/65/70/75 = 0x40`（CH1~CH4 输入源设为数字 PDM）
- `P0_R34~37 = 0x41`（GPO1~4 输出 PDMCLK）
- `P0_R43 = 0x45`，`P0_R44 = 0x67`（GPI 映射为 PDMDIN1~4）
- `P0_R115 = 0xFF`（使能输入通道）
- `P0_R116 = 0xFF`（使能 ASI 输出通道）
- `P0_R117 = 0x60`（上电 ADC 和 PLL）

## 6) 你的 6Mic 建议参数（首版）

- `FSYNC = 48kHz`
- TDM 槽宽 32bit，8 槽
- `BCLK = 48k * 32 * 8 = 12.288MHz`
- 输出取 CH1~CH6，CH7/CH8 丢弃或后续扩展

## 7) 关键提醒

- TLV320ADC3140 虽支持 I2S 格式，但 6 路并行数据必须走 TDM 才能在“一路串口”里带出来。
- 如果你选的是 `ICS-52000` 这类 **TDM 麦克风**，那是另一条架构（可直接进主控 TDM），不应再走 TLV 的 PDM 输入路径。
- 下单前请再次确认嘉立创实时库存与价格（会变动）。
- 本文“性价比结论”按当前抓取结果：`ICS-41350`（￥6.46）优于 `ICS-41351`（￥9.12，且库存仅 1）和 `VM3011-U1`（缺货）。
