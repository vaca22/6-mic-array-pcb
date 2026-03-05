# 蓝牙芯片（支持 TDM）选型调研（含立创可得性）

调研目标：找“性能强 + 性价比高 + 支持 TDM + 立创可买”的蓝牙芯片/模组。  
调研时间：当前会话（价格和库存会波动）。

## 1) 结论先看

在“有公开 TDM 证据 + 立创可买 + 性价比”三个条件同时满足下，当前最稳妥的是 **Espressif ESP32 系列**：

1. **ESP32-C3（性价比优先）**
2. **ESP32-S3（性能优先）**
3. **ESP32-WROOM-32D（经典方案，BT4.2）**

补充（高通专项结论）：
- 高通 `QCC` 系列性能很强，音频特性优秀；
- 但在立创当前可见条目主要是高价预售料，且 `OutOfStock`，**不适合做“性价比量产主推”**。

---

## 2) 候选芯片（满足 TDM 证据）

## A. ESP32-C3（推荐：性价比最高）

- 立创商品（示例）：
  - `ESP32-C3`（芯片）<https://item.szlcsc.com/3013220.html?fromZone=s_s__%2522ESP32-C3%2522>，编号 `C2838500`
  - `ESP32-C3-WROOM-02-N4`（模组）<https://item.szlcsc.com/3281215.html?fromZone=s_s__%2522ESP32-C3%2522>，编号 `C2934560`
- 立创参考价/库存（抓取时）：
  - `ESP32-C3`：1+ 约 `11.36`，库存 `11K+`
  - `ESP32-C3-WROOM-02-N4`：1+ 约 `19.6`，库存 `19K+`
- 性能要点（来自立创条目）：
  - Bluetooth 5.0（BLE）
  - 接口包含 `I2S`
  - 主频最高约 160MHz（模组描述）
- TDM 证据（官方）：
  - Espressif `ESP32-C3` I2S 文档含 `### TDM Mode`
  - 明确有 `i2s_channel_init_tdm_mode()`
  - 文档有 `i2s_es7210_tdm` 示例（ESP32-C3）
  - 文档链接：<https://docs.espressif.com/projects/esp-idf/en/stable/esp32c3/api-reference/peripherals/i2s.html>

## B. ESP32-S3（推荐：性能更强）

- 立创商品（示例）：
  - `ESP32-S3R8`（芯片）<https://item.szlcsc.com/3198292.html?fromZone=s_s__%2522ESP32-S3%2522>，编号 `C2913194`
  - `ESP32-S3-WROOM-1-N8R8`（模组）<https://item.szlcsc.com/3198299.html?fromZone=s_s__%2522ESP32-S3%2522>，编号 `C2913201`
  - `ESP32-S3-MINI-1-N8`（模组）<https://item.szlcsc.com/3198304.html?fromZone=s_s__%2522ESP32-S3%2522>，编号 `C2913206`
- 立创参考价/库存（抓取时）：
  - `ESP32-S3R8`：1+ 约 `21.09`，库存 `4004`
  - `ESP32-S3-WROOM-1-N8R8`：1+ 约 `31.27`，库存 `12K+`
  - `ESP32-S3-MINI-1-N8`：1+ 约 `29.11`，库存 `16K+`
- 性能要点（来自立创条目）：
  - Bluetooth 5.0
  - `LX7` 双核，最高 240MHz（模组描述）
  - 接口含 `I2S`
- TDM 证据（官方）：
  - `ESP32-S3` I2S 文档含 `### TDM Mode`
  - 明确 `TDM supports up to 16 slots`
  - 明确 `i2s_channel_init_tdm_mode()`
  - 文档链接：<https://docs.espressif.com/projects/esp-idf/en/stable/esp32s3/api-reference/peripherals/i2s.html>

## C. ESP32-WROOM-32D（经典，BT4.2）

- 立创商品（示例）：
  - `ESP32-WROOM-32D-N4` <https://item.szlcsc.com/479662.html?fromZone=s_s__%2522ESP32-WROOM-32D%2522>，编号 `C473012`
  - `ESP32-WROOM-32D-N8` <https://item.szlcsc.com/549843.html?fromZone=s_s__%2522ESP32-WROOM-32D%2522>，编号 `C529577`
- 立创参考价/库存（抓取时）：
  - `N4`：1+ 约 `24.05`，库存 `8288`
  - `N8`：1+ 约 `28.66`，库存 `4005`
- 性能要点（来自立创条目）：
  - 双核最高 240MHz（商品描述）
  - Bluetooth 4.2
  - 音频流/MP3 解码等场景描述
- TDM 证据（官方）：
  - ESP32 I2S 文档存在 `i2s_channel_init_tdm_mode()` API 路径
  - 文档链接：<https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/peripherals/i2s.html>

---

## 3) 不纳入“主推 TDM”但你可能会看到的蓝牙芯片

以下在立创可见，但当前公开页面未给出明确 TDM 证据（多为 I2S/PCM）：

- `FR5082`（`C2843683`）：蓝牙音频 SoC，见 I2S/PCM、4ch PDM 描述，但该条目当前 `OutOfStock`
  - <https://item.szlcsc.com/3032569.html>
- `AK1052D`（`C383433`）：蓝牙音频 SoC，描述有 `2x I2S`，但未明确 TDM；当前 `OutOfStock`
  - <https://item.szlcsc.com/356814.html>

## 3.1) 高通（Qualcomm/QCC）专项核查

本段按你要求单独补充。

### A) 能力侧（公开资料）

- 高通 QCC5100/QCC51xx 系列面向蓝牙音频，定位高性能音频 SoC。
- 公开特性可见 `192kHz/24bit I2S + SPDIF`、ANC、aptX 等（以 QCC5125 相关资料为代表）。
- 说明：公开页面通常写 `I2S/SPDIF`，TDM 往往通过具体 SDK/参考设计体现，官网产品页对 TDM 字样不一定显式。

参考：
- QCC5125 产品页：<https://www.qualcomm.com/products/internet-of-things/consumer/audio/qcc5100-series/qcc5125>

### B) 立创可得性（抓取时）

1. `DK-QCC5125-VFBGA90-A-0`（Qualcomm）
   - 链接：<https://item.szlcsc.com/18424940.html>
   - 编号：`C17295791`
   - 参考价/库存：`￥5509.65`，`OutOfStock(0)`
   - 页面标签：`预售商品`

2. `DB-QCC5127-VFBGA124-A-0`（Qualcomm）
   - 链接：<https://item.szlcsc.com/18587279.html>
   - 编号：`C17458086`
   - 参考价/库存：`￥1377.42`，`OutOfStock(0)`
   - 页面标签：`预售商品`

### C) 评价（高通是否“性能强+性价比高”）

- **性能**：强（音频生态成熟，面向耳机/音频类产品）。
- **性价比（按立创当前可买状态）**：弱
  - 可见料价格远高于 ESP32 系列；
  - 当前均无现货，且更像专项/预售料，不利于快速打样和低成本迭代。

结论：
- 如果你追求“高端音频体验并且供应链可控”，高通可作为中长期路线；
- 如果你当前目标是“立创直接下单 + 成本可控 + 快速推进 6Mic/TDM”，仍建议优先 ESP32-C3 / ESP32-S3。

---

## 4) 选型建议（针对你的 6Mic 方向）

- 如果你要“6Mic 独立通道 + TDM 输入”且预算敏感：优先 `ESP32-C3`
- 如果你要更强算力（关键词检测/算法余量）：优先 `ESP32-S3`
- 如果你要经典成熟方案且可接受 BT4.2：`ESP32-WROOM-32D`
- 如果你坚持高通路线：建议先确认代理供货与SDK门槛，再做 PoC，不建议直接以立创预售料开量产。

## 5) 风险与确认项

- 立创页面多数写的是 `I2S` 接口，`TDM` 能力来自芯片官方 SDK 文档能力，不一定在立创参数栏直接显示。
- 实际可用的 `slot 数/位宽/采样率` 需要按具体芯片文档和时钟约束再核一次（尤其高槽位、高位宽组合）。
- 下单前务必复查实时价格与库存。
