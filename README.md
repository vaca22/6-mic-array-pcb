# 6-Mic-Array-PCB

```text

SDK文档：
https://docs.sifli.com/projects/sdk/latest/sf32lb52x/quickstart/index.html

SF32LB52 Nano 开发版介绍：
https://docs.sifli.com/projects/xiaozhi/get-started/SF32LB52-DevKit-Nano/

官方
https://github.com/OpenSiFli/SiFli-Wiki/blob/main/source/board/sf32lb52x/SF32LB52-DevKit-Nano.md

硬件设计
https://wiki.sifli.com/silicon/product-index.html
https://wiki.sifli.com/hardware/SF32LB520-3-5-7-HW-Application.html

SDK GitHub:
https://github.com/OpenSiFli/SiFli-SDK

```
六路麦克风阵列 PCB 设计 - 基于 SF32LB52 + 音频 Hub 方案

## 🎯 设计目标

- 6 路模拟 MEMS 麦克风输入
- 音频 Hub 聚合为单路 I2S 输出
- SF32LB52 内置 Codec + 外部 Hub
- 低噪声、高信噪比
- 适用于语音阵列、会议系统、小智 AI 助手

## 📐 系统架构

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│   MIC1  MIC2  MIC3  MIC4  MIC5  MIC6                   │
│   (模拟) (模拟) (模拟) (模拟) (模拟) (模拟)             │
│    │     │     │     │     │     │                     │
│    └─────┴─────┴─────┴─────┴─────┘                     │
│                    │                                   │
│                    ▼                                   │
│            ┌───────────────┐                           │
│            │  音频 Hub     │                           │
│            │  (8 通道 ADC)  │                           │
│            │  ADAU1977     │                           │
│            └───────────────┘                           │
│                    │                                   │
│                    │ I2S/TDM (单路)                    │
│                    ▼                                   │
│            ┌───────────────┐                           │
│            │     MCU       │                           │
│            │  SF32LB52     │                           │
│            │  (内置 Codec) │                           │
│            └───────────────┘                           │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## 🔧 核心元件

| 类型 | 型号 | 数量 | 说明 |
|------|------|------|------|
| 模拟 MEMS 麦克风 | SPW0442LR5H / ICS-40180 | 6 | 模拟输出，-38dB |
| 音频 Hub | ADAU1977 | 1 | 8 通道 ADC，支持 TDM |
| MCU | SF32LB52JUD6 | 1 | 思澈科技，内置 Codec，16MB PSRAM |
| LDO | XC6206 3.3V | 1 | 麦克风供电 |
| 晶振 | 12.288MHz | 1 | 音频时钟 (可选，SF32 可输出 MCLK) |

## 📁 目录结构

```
6-mic-array-pcb/
├── README.md           # 本文件
├── docs/
│   ├── design-guide.md     # 设计指南
│   └── checklist.md        # 设计检查清单
├── hardware/
│   ├── bom.csv             # 元件清单
│   └── footprint/          # 封装库
└── schematic/
    ├── main.sch            # 主原理图
    └── power.sch           # 电源部分
```

## 🔌 SF32LB52 引脚分配

| 信号 | SF32LB52 引脚 | 功能 |
|------|--------------|------|
| I2S_BCLK | PA29 | I2S1_BCK |
| I2S_LRCLK | PA30 | I2S1_LRCK |
| I2S_DIN | PA28 | I2S1_SDI |
| I2S_MCLK | PA24 | I2S1_MCLK (可选) |
| MIC_BIAS | PA5 | 麦克风偏置电压 |
| MIC_ADC | PA4 | 内置 ADC 输入 (备用) |
| DAC_P | PA2 | 差分音频输出 + |
| DAC_N | PA3 | 差分音频输出 - |

## 📋 设计状态

- [x] 方案确定 (SF32LB52 + ADAU1977)
- [ ] 原理图设计
- [ ] 元件选型确认
- [ ] PCB 布局
- [ ] 设计审查
- [ ] Gerber 输出
- [ ] 打样验证

## 🎨 PCB 设计要点

### 布局
- 麦克风孔位精度 ±0.5mm
- 麦克风间距 ≥15mm (声学隔离)
- 麦克风下方挖空底层 (减少振动噪声)

### 走线
- PDM 走线等长 (误差 ≤5mm)
- I2S/TDM 走线包地处理
- 完整地平面，模拟数字分离

### 层叠
- 4 层板：Signal - GND - PWR - Signal
- 板厚 1.6mm
- 沉金工艺

## 🛠️ 设计工具

- **EDA**: 立创 EDA (EasyEDA)
- **仿真**: 可选
- **下单**: 嘉立创 PCB

## 📋 设计状态

- [ ] 原理图设计
- [ ] 元件选型确认
- [ ] PCB 布局
- [ ] 设计审查
- [ ] Gerber 输出
- [ ] 打样验证

## 🤝 贡献

欢迎提交 Issue 和 PR！

## 📄 许可证

MIT License
