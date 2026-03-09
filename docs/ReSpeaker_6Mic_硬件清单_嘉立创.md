# ReSpeaker 6-Mic Circular Array 硬件清单

> 基于 Seeed Wiki 规格整理，适用于 DIY 复刻或参考选型。  
> 嘉立创 = 嘉立创 EDA/JLCPCB（PCB 制造）+ 立创商城 LCSC（元器件）。  
> 价格仅供参考，以立创商城实时报价为准。

---

## 一、产品概述

ReSpeaker 6-Mic 套件由两块板组成：

| 板子 | 说明 |
|------|------|
| **Voice Accessory HAT** | 主控板，含 AC108/AC101、3.5mm 耳机座、扬声器接口、Grove、40pin GPIO |
| **6-Mic Circular Array** | 麦克风阵列子板，6 颗 MEMS 麦 + 12 颗 GRB LED，通过 FPC 排线连接 HAT |

---

## 二、核心芯片（ADC / DAC）

| 序号 | 型号 | 数量 | 说明 | 立创商城 | 参考价格 | 备注 |
|------|------|------|------|----------|----------|------|
| 1 | **AC108** (X-Power) | 2 | 4 通道 ADC，I2S/TDM 输出 | 暂无 | — | 全志/芯智汇，立创商城无货，需从 Seeed/淘宝/模块商采购 |
| 2 | **AC101** (X-Power) | 1 | 立体声 DAC，I2S 输入 | 暂无 | — | 同上，通常与 AC108 配套 |

**说明：** AC108、AC101 为 X-Power（芯智汇）音频芯片，立创商城通常无现货。可考虑：
- 购买 Seeed 原装 ReSpeaker 套件
- 淘宝搜索「AC108 树莓派 麦克风模块」等成品模块
- 参考 [GitHub ReSpeaker 原理图](https://github.com/Fuhua-Chen/ReSpeaker_Microphone_Array_SCH_PCB) 自行设计时，需另寻芯片渠道

---

## 三、麦克风

| 序号 | 型号 | 数量 | 说明 | 立创商城 | 参考价格 | 备注 |
|------|------|------|------|----------|----------|------|
| 1 | **MSM321A3729H9BP** | 6 | MEMS 麦克风，全向，-32dB，65dB SNR | [C966932](https://item.szlcsc.com/1052909.html) | 约 ¥2–4/颗 | 敏芯微，与官方 MSM321A3729H9CP 同系列，封装 OCLGA-4(3×3.8) |

**替代型号（立创可选）：**
- [SPW0442LR5H](https://item.szlcsc.com/2843908.html) — Knowles，-38dB，约 ¥2.5/颗
- 其他 OCLGA-4 或 SMD-4 封装 MEMS 麦，注意方向性与灵敏度匹配

---

## 四、LED（Pixel Ring）

| 序号 | 型号 | 数量 | 说明 | 立创商城 | 参考价格 | 备注 |
|------|------|------|------|----------|----------|------|
| 1 | **WS2812B** | 12 | GRB 可编程 LED，单线驱动 | [WS2812B-B/W](https://item.szlcsc.com/115830.html) | 约 ¥0.5–1/颗 | 5050 封装 |
|  |  |  |  | [WS2812B-MINI-V3](https://item.szlcsc.com/546079.html) | 约 ¥0.4/颗 | 3535 小封装，可选 |

---

## 五、连接器与接口

| 序号 | 型号/规格 | 数量 | 说明 | 立创商城 | 参考价格 | 备注 |
|------|-----------|------|------|----------|----------|------|
| 1 | **3.5mm 耳机座** | 1 | 四极，带麦克风检测 | [PJ-342](https://item.szlcsc.com/698549.html) | 约 ¥1–2 | 6 脚卧贴 |
|  |  |  |  | [PJ-3440-2](https://item.szlcsc.com/353368.html) | 约 ¥1.5 | 7 脚 4 级插件 |
| 2 | **JST 2.0 扬声器座** | 1 | 2pin，间距 2.0mm | 搜索「JST 2.0 2P」 | 约 ¥0.3 | 常用 PH 系列 |
| 3 | **40pin GPIO 排针** | 1 | 2×20，2.54mm，树莓派 HAT | 搜索「2.54 2x20 排针」 | 约 ¥0.5 | 公针，与树莓派母座配合 |
| 4 | **FPC 30pin 0.5mm** | 2 | HAT↔麦克风阵列排线座 | [F-FPC0M30P-C310](https://item.szlcsc.com/208421.html) | 约 ¥1–2 | 翻盖式 |
|  |  |  |  | [AFC30-S30FCA-00](https://item.szlcsc.com/989091.html) | 约 ¥1 | 下接式 |
| 5 | **Grove 接口** | 2 | I2C/UART 等扩展 | Seeed 或兼容 4pin | 约 ¥1/个 | 可选 |

---

## 六、被动元件（估算）

以下为典型音频板常用规格，具体以原理图为准：

| 类型 | 规格 | 数量估算 | 立创商城 | 参考价格 |
|------|------|----------|----------|----------|
| 晶振 | 12.288 MHz（音频时钟） | 1 | 搜索「12.288MHz」 | 约 ¥1 |
| LDO | 3.3V，如 XC6206、AMS1117 | 2–3 | [XC6206P332MR](https://item.szlcsc.com/6206332.html) | 约 ¥0.3 |
| 电容 | 100nF 去耦 | 10+ | C0603 系列 | 约 ¥0.03/颗 |
| 电容 | 1µF / 10µF 滤波 | 若干 | C0603/C0805 | 约 ¥0.05–0.1/颗 |
| 电阻 | 1kΩ / 10kΩ 偏置/上拉 | 若干 | R0603 | 约 ¥0.01/颗 |

---

## 七、其他

| 序号 | 项目 | 数量 | 说明 | 参考价格 |
|------|------|------|------|----------|
| 1 | **FPC 排线** | 1 | 30pin 0.5mm，长度按结构定 | 约 ¥2–5 |
| 2 | **按钮** | 1 | GPIO 26 检测用（可选） | 约 ¥0.2 |
| 3 | **PCB** | 2 | HAT 板 + 麦克风阵列板 | 嘉立创打样约 ¥20–50 |

---

## 八、整机采购方案（不 DIY 时）

若不自制 PCB，可直接购买 Seeed 原装套件：

| 渠道 | 链接 | 参考价格 |
|------|------|----------|
| Seeed 官网 | [ReSpeaker 6-Mic Circular Array Kit](https://www.seeedstudio.com/ReSpeaker-6-Mic-Circular-Array-Kit-for-Raspberry-Pi.html) | 约 $59 |
| 立创商城 | 搜索「ReSpeaker 6-Mic」或「Seeed 麦克风阵列」 | 以商家报价为准 |

---

## 九、立创商城快速链接汇总

| 元件 | 立创商城链接 |
|------|--------------|
| 麦克风 MSM321A3729H9BP | https://item.szlcsc.com/1052909.html |
| LED WS2812B-B/W | https://item.szlcsc.com/115830.html |
| LED WS2812B-MINI-V3 | https://item.szlcsc.com/546079.html |
| 3.5mm 耳机座 PJ-342 | https://item.szlcsc.com/698549.html |
| FPC 30pin F-FPC0M30P-C310 | https://item.szlcsc.com/208421.html |
| LDO XC6206P332MR | https://item.szlcsc.com/6206332.html |

---

## 十、注意事项

1. **AC108 / AC101** 立创商城无货，需通过 Seeed、淘宝或模块商采购。
2. **MSM321A3729H9CP** 官方规格，立创有 **MSM321A3729H9BP**，封装兼容，可作替代。
3. **MSM381A3729H9CP** 已停产，不建议选用。
4. 完整 BOM 需结合 [ReSpeaker 原理图](https://github.com/Fuhua-Chen/ReSpeaker_Microphone_Array_SCH_PCB) 或 Seeed 官方资源核对。
5. 价格随市场波动，下单前请以立创商城实时价格为准。

---

*文档整理自 Seeed Wiki 与立创商城检索，最后更新：2025-03*
