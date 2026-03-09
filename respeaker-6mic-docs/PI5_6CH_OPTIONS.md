# 树莓派 5 上 6 麦全通道方案

当前在 Pi 5 上只有 1 个麦克风通道有数据，这是 RP1 I2S + AC108 TDM 的已知限制。以下是可行方案。

---

## 方案一：换用树莓派 4（推荐）

在 **树莓派 4** 上，ReSpeaker 6-Mic 可正常使用全部 6 个麦克风通道。

**依据**：Seeed Wiki 兼容列表含 Pi 4，并给出 8 通道录音与按通道提取示例；同驱动的 4-Mic 在 [issue #342](https://github.com/respeaker/seeed-voicecard/issues/342) 中确认「On the RPI-4: The HAT works pretty well and is able to capture 4 channel audio」。

- 使用原版 seeed-voicecard（无需 Pi 5 overlay）
- 在 config.txt 中设置 `dtoverlay=seeed-8mic-voicecard`
- 无需额外补丁

---

## 方案二：等待上游修复

问题出在 **RP1 的 Designware I2S 驱动** 在 `i2s_clk_consumer` 模式下对多通道 capture 的支持。

- 在 [raspberrypi/linux/issues](https://github.com/raspberrypi/linux/issues) 中搜索类似问题
- 参考 [respeaker/seeed-voicecard#342](https://github.com/respeaker/seeed-voicecard/issues/342) 和 [RPi Forum](https://forums.raspberrypi.com/viewtopic.php?t=373301)
- 可定期执行 `sudo rpi-update` 获取最新内核，看是否修复

---

## 方案三：尝试内核更新

当前内核 6.12.47 已包含 PR #6023 的通道数修复，但 consumer 模式多通道仍可能有问题。

```bash
# 在树莓派上执行
sudo rpi-update
sudo reboot
```

---

## 方案四：尝试 i2s_clk_producer（需 AC108 支持 slave）

若 AC108 支持 slave 模式，可尝试让 Pi 作为 master。但 ReSpeaker 6-Mic 的 AC108 通常为 master，此方案可能不适用。

---

## 方案五：改用 USB 麦克风阵列

若必须使用 Pi 5，可考虑改用 **USB 麦克风阵列**，例如：

- ReSpeaker USB Mic Array

---

## 已尝试的配置

- 将 overlay 的 TDM 从 `slot-num=2` 改为 `slot-num=8`，`rx-mask` 设为全 8 槽
- 结果：仍只有 1 个通道有数据

---

## 总结

| 方案 | 可行性 | 说明 |
|------|--------|------|
| 换用 Pi 4 | 高 | 6 麦可全通道工作 |
| 等待上游 | 中 | 需 RP1 驱动修复 |
| 内核更新 | 低 | 可能改善，但非保证 |
| 使用 USB 麦 | 高 | 需更换硬件 |
