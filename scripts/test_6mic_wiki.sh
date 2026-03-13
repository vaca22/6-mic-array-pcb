#!/bin/bash
# ReSpeaker 6-Mic 测试 — 完全按 Seeed 官方 Wiki 实现（仅录音与校验，不安装/不修改系统）
# Wiki: https://wiki.seeedstudio.com/ReSpeaker_6-Mic_Circular_Array_kit_for_Raspberry_Pi/
#
# 前置条件：树莓派上已按 Wiki 安装 seeed-voicecard 并重启，arecord -L 中能看到 ac108 或 seeed8micvoicec。
# 用法：在树莓派上执行 ./test_6mic_wiki.sh，或 scp 到 Pi 后 ssh pi@<IP> 'bash -s' < test_6mic_wiki.sh

set -e
RECORD_SEC=3
WAV="/tmp/respeaker_6mic_test.wav"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERIFY_PY="$SCRIPT_DIR/verify_wav.py"

echo "=== ReSpeaker 6-Mic Test (Seeed Wiki) ==="

# 1. 检查录音设备（Wiki: arecord -L 应出现 ac108 / seeed8micvoicec）
echo "[1/4] Checking ALSA capture device (Wiki: ac108, seeed8micvoicec)..."
ARECORD_LIST="$(arecord -L 2>/dev/null)"
if ! echo "$ARECORD_LIST" | grep -qE 'seeed8micvoicec|ac108'; then
    echo "FAIL: ac108 / seeed-8mic-voicecard not found in 'arecord -L'"
    echo ""
    echo "请按 Wiki 安装驱动（在树莓派上）："
    echo "  sudo apt-get update && sudo apt-get upgrade"
    echo "  git clone https://github.com/respeaker/seeed-voicecard.git"
    echo "  cd seeed-voicecard && sudo ./install.sh"
    echo "  sudo reboot"
    echo ""
    echo "Wiki: https://wiki.seeedstudio.com/ReSpeaker_6-Mic_Circular_Array_kit_for_Raspberry_Pi/"
    exit 1
fi
echo "OK: Capture device found."

# 2. 选择设备（Wiki: arecord -D ac108 -f S32_LE -r 16000 -c 8）
RECORD_DEV="ac108"
if ! arecord -L 2>/dev/null | grep -q 'ac108'; then
    RECORD_DEV="plughw:CARD=seeed8micvoicec,DEV=0"
fi
echo "[2/4] Using device: $RECORD_DEV (Wiki: first 6 ch = mics)"

# 3. 录音（Wiki 原文：arecord -Dac108 -f S32_LE -r 16000 -c 8 a.wav）
echo "[3/4] Recording ${RECORD_SEC}s (8 ch, 16 kHz, S32_LE)..."
rm -f "$WAV"
if ! arecord -D "$RECORD_DEV" -f S32_LE -r 16000 -c 8 -d "$RECORD_SEC" "$WAV" 2>/dev/null; then
    echo "FAIL: arecord failed. Check device and permissions."
    exit 1
fi

WAV_SIZE="$(stat -c%s "$WAV" 2>/dev/null || stat -f%z "$WAV" 2>/dev/null)"
if [ ! -f "$WAV" ] || [ "${WAV_SIZE:-0}" -lt 10000 ]; then
    echo "FAIL: Recording too small or missing ($WAV)"
    exit 1
fi
echo "OK: Recorded ${WAV_SIZE} bytes -> $WAV"

# 4. 校验（8 通道，前 6 路为麦克风）
echo "[4/4] Verifying WAV (8 ch, first 6 = mics)..."
if [ -f "$VERIFY_PY" ]; then
    if python3 "$VERIFY_PY" "$WAV"; then
        echo ""
        echo "=== ReSpeaker 6-Mic test passed (Wiki method). ==="
        exit 0
    fi
else
    echo "OK: WAV present (run verify_wav.py for channel check)."
    echo ""
    echo "=== Recording OK. ==="
    exit 0
fi

echo ""
echo "=== Verification failed. See above. ==="
exit 1
