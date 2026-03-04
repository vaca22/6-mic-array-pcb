# KiCad 文件导入立创 EDA 指南

## 📁 文件说明

```
kicad/
├── 6-mic-array-pcb.kicad_pro    # KiCad 项目文件
├── 6-mic-array-pcb.kicad_sch    # 原理图
├── 6-mic-array-pcb.kicad_pcb    # PCB 布局
├── sym-lib-table                 # 符号库表
└── fp-lib-table                  # 封装库表
```

---

## 🚀 导入步骤

### 方法 1: 立创 EDA 专业版 (推荐)

1. **打开立创 EDA 专业版**
   - 访问 https://pro.lceda.cn
   - 登录账号

2. **导入 KiCad 项目**
   - 文件 → 导入 → KiCad
   - 选择 `6-mic-array-pcb.kicad_pro`
   - 点击"导入"

3. **检查导入结果**
   - 原理图 → 检查元件和连接
   - PCB → 检查封装和布局

4. **保存为立创 EDA 格式**
   - 文件 → 另存为
   - 命名 "6-Mic-Array-PCB"

---

### 方法 2: 立创 EDA 标准版

1. **打开立创 EDA 标准版**
   - 访问 https://lceda.cn

2. **导入 KiCad 文件**
   - 文件 → 导入 → KiCad 6.0
   - 选择 `6-mic-array-pcb.kicad_sch` (原理图)
   - 或选择 `6-mic-array-pcb.kicad_pcb` (PCB)

3. **转换项目**
   - 导入后自动转换为立创 EDA 格式
   - 保存项目

---

## ⚠️ 注意事项

### 元件库问题

立创 EDA 可能没有某些 KiCad 封装，需要手动替换：

| KiCad 封装 | 立创 EDA 替代 |
|-----------|--------------|
| LGA-56_6x6mm_P0.65mm | 搜索 "SF32LB52" 或手动创建 |
| LQFP-48_7x7mm_P0.5mm | 搜索 "LQFP48" |
| MEMS_Mic_SMD | 搜索 "MEMS 麦克风" 或 "INMP441" |
| USB_C_Receptacle | 搜索 "USB-C" |

### 替换步骤

1. 导入后右键元件 → 替换封装
2. 搜索立创商城有货的封装
3. 确认引脚匹配
4. 应用替换

---

## 🔧 导入后检查清单

### 原理图检查
- [ ] 所有元件已正确导入
- [ ] 网络连接无丢失
- [ ] 电源符号正确
- [ ] 接地符号正确
- [ ] 网络标签命名正确

### PCB 检查
- [ ] 板框尺寸正确 (100x120mm)
- [ ] 所有封装已加载
- [ ] 4 层板设置正确
- [ ] 地平面已填充

### DRC 检查
- [ ] 运行 DRC 无错误
- [ ] 修复所有间距问题
- [ ] 修复所有未连接网络

---

## 📐 推荐立创 EDA 设置

### 层叠设置
```
Layer 1: Top Signal (顶层信号)
Layer 2: GND Plane (地平面)
Layer 3: PWR Plane (电源平面)
Layer 4: Bottom Signal (底层信号)
```

### 设计规则
| 参数 | 值 |
|------|-----|
| 最小线宽 | 6mil (0.15mm) |
| 最小间距 | 6mil (0.15mm) |
| 最小过孔 | 0.3mm |
| 过孔焊盘 | 0.6mm |

### 电源网络
- 3V3_DIG: 数字电源 (15mil 线宽)
- 3V3_ANA: 模拟电源 (15mil 线宽)
- GND: 完整地平面

---

## 🎨 麦克风布局建议

```
┌─────────────────────────────────────────┐
│                                         │
│   MIC4      MIC5      MIC6              │
│   ●         ●         ●                 │
│                                         │
│              ADAU1977                   │
│               ┌───┐                     │
│               │   │                     │
│               └───┘                     │
│                                         │
│   MIC1      MIC2      MIC3              │
│   ●         ●         ●                 │
│                                         │
│                    SF32LB52             │
│                     ┌───┐               │
│                     │   │               │
│                     └───┘               │
│                                         │
└─────────────────────────────────────────┘
```

**间距**: 麦克风之间 ≥15mm (声学隔离)

---

## 📤 导出 Gerber (完成后)

1. **文件 → 导出 → Gerber**
2. **选择层**:
   - Top Layer
   - Bottom Layer
   - Top Solder Mask
   - Bottom Solder Mask
   - Top Silkscreen
   - Bottom Silkscreen
   - Keep-Out Layer
   - Drill Drawing
3. **压缩为 ZIP**
4. **嘉立创下单**

---

## 🐛 常见问题

### Q1: 导入后元件丢失
**解决**: 手动从立创元件库重新放置，替换封装

### Q2: 网络连接错误
**解决**: 重新运行 "更新 PCB 从原理图"

### Q3: 封装不匹配
**解决**: 右键元件 → 替换封装 → 搜索立创商城封装

### Q4: 板框尺寸不对
**解决**: 在 PCB 编辑器重画板框 (100x120mm)

---

## 📞 需要帮助？

- 立创 EDA 教程：https://docs.lceda.cn
- 立创社区：https://club.lceda.cn
- 本项目 Issue: https://github.com/vaca22/6-mic-array-pcb/issues

---

## 版本记录

| 版本 | 日期 | 说明 |
|------|------|------|
| v1.0 | 2026-03-04 | 初始 KiCad 文件 |
