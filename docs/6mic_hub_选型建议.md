# 6Mic 在单路 I2S 场景下的 Hub 选型建议

## 结论先看

- 如果你说的“单路 I2S”是**只有一组音频数据线**，那要跑 6 路麦克风，建议用 **TDM over I2S 引脚**（BCLK/LRCLK/DOUT 同线复用时隙）。
- 纯传统双声道 I2S（L/R 两声道）无法承载 6 路独立麦克风数据。
- 在立创可见候选里，性价比优先建议：
  1. **TLV320ADC3140IRTWT (C1852021)**：参考价约 **17.62 元**，支持最多 8 路数字 PDM 麦输入，支持 TDM/I2S 输出。
  2. **ADAU7118ACPZRL (C654437)**：参考价约 **35.59 元**，8 路 PDM 转 I2S/TDM，功能非常贴合麦阵列。

## 候选器件（立创商城）

## 1) TI TLV320ADC3140IRTWT（推荐优先看）

- 立创页面：<https://item.szlcsc.com/1942834.html>
- 立创料号：`C1852021`
- 页面参考价：`￥17.62`
- 页面库存字段：`InStock`（inventoryLevel: 64）
- 与 6Mic 相关能力：
  - 最多 8 通道数字 PDM 麦输入（页面概述描述）
  - 支持 `TDM / I2S / LJ` 串行音频格式
- 适配建议：
  - 6 个数字麦可按 TDM 时隙输出到主控的一路音频口
  - 成本低于 ADAU7118，综合性价比更好

## 2) ADI ADAU7118ACPZRL（功能匹配度高）

- 立创页面：<https://item.szlcsc.com/683991.html>
- 立创料号：`C654437`
- 页面参考价：`￥35.59`
- 页面库存字段：`InStock`（inventoryLevel: 30）
- 与 6Mic 相关能力：
  - 8 通道 PDM 到 PCM
  - 输出支持 `I2S/TDM`
  - 专门面向麦克风阵列场景
- 适配建议：
  - 对 6 路 PDM Mic 非常直接
  - 成本高于 TLV320ADC3140

## 3) ADI ADAU7002ACBZ-R7（不建议用于 6Mic 主方案）

- 立创页面：<https://item.szlcsc.com/489827.html>
- 立创料号：`C481886`
- 页面参考价：`￥9.7524`
- 页面库存字段：`InStock`
- 限制：
  - 仅立体声（2 路）PDM 转 I2S/TDM
  - 做 6Mic 需要多颗级联，系统复杂度上升

## 4) NXP 8CH-DMIC（开发板，不是量产Hub芯片）

- 立创页面：<https://item.szlcsc.com/6051993.html>
- 立创料号：`C5300709`
- 页面参考价：`￥870.06`
- 页面库存字段：`OutOfStock`（inventoryLevel: 0）
- 说明：
  - 更适合评估/验证，不适合你当前量产 PCB 的 hub 芯片选型

## 选型建议（按“性价比 + 落地风险”）

1. **主推：TLV320ADC3140**
   - 价格更友好；
   - 支持 8 路数字 PDM 麦，足够 6Mic；
   - 同时给你保留模拟前端扩展空间。
2. **备选：ADAU7118**
   - 专用 PDM hub 属性更强，麦阵列经验成熟；
   - 但单价明显更高。

## 设计注意点（很关键）

- 主控必须支持 **TDM 接收**（虽然走的是 I2S 同样的几根线）。
- 明确 6Mic 的数据格式：
  - 若用数字 PDM 麦：优先 TLV320ADC3140 / ADAU7118 这类聚合方案；
  - 若用模拟 MIC：应改看多通道模拟 ADC/codec 路线。
- 关注时钟与带宽：
  - 例如 6ch x 16kHz x 24bit（再考虑padding/slot）对应 BCLK 要留足裕量。

## 数据来源说明

- 本文价格和库存来自立创商品页 HTML 的 JSON-LD 字段（`price` / `availability` / `inventoryLevel`）。
- 价格会波动，建议下单前再次打开链接确认实时价格与库存。
