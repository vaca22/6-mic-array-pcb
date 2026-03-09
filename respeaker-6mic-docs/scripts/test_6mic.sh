#!/bin/bash
# ReSpeaker 6-Mic Array automatic test on Raspberry Pi
# Usage: run on the Pi (e.g. ./test_6mic.sh) or: ssh xiaozhi@192.168.71.10 'bash -s' < test_6mic.sh

set -e
RECORD_SEC=2
WAV="/tmp/respeaker_6mic_test.wav"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERIFY_PY="$SCRIPT_DIR/verify_wav.py"

echo "=== ReSpeaker 6-Mic Array Test ==="

# 1. Check if capture device is present
echo "[1/4] Checking ALSA capture device..."
ARECORD_LIST="$(arecord -L 2>/dev/null)"
if ! echo "$ARECORD_LIST" | grep -qE 'seeed8micvoicec|ac108'; then
    echo "FAIL: seeed-8mic-voicecard / ac108 not found in 'arecord -L'"
    if echo "$ARECORD_LIST" | grep -q 'googlevoi'; then
        echo "Tip: Pi shows Google Voice HAT. Disable it or install seeed-voicecard for ReSpeaker 6-Mic."
    else
        echo "Tip: Install seeed-voicecard and reboot: https://github.com/respeaker/seeed-voicecard"
    fi
    exit 1
fi
echo "OK: Capture device found."

# 2. Find device to use (prefer ac108 plug, else default seeed card)
RECORD_DEV="ac108"
if ! arecord -L 2>/dev/null | grep -q 'ac108'; then
    RECORD_DEV="plughw:CARD=seeed8micvoicec,DEV=0"
fi
echo "[2/4] Using device: $RECORD_DEV"

# 3. Record short clip (8 ch, 16 kHz, S32_LE as per wiki)
echo "[3/4] Recording ${RECORD_SEC}s (8 channels, 16 kHz)..."
rm -f "$WAV"
if ! arecord -D "$RECORD_DEV" -f S32_LE -r 16000 -c 8 -d "$RECORD_SEC" "$WAV" 2>/dev/null; then
    echo "FAIL: arecord failed. Check permissions and device."
    exit 1
fi

WAV_SIZE="$(stat -c%s "$WAV" 2>/dev/null || stat -f%z "$WAV" 2>/dev/null)"
if [ ! -f "$WAV" ] || [ "${WAV_SIZE:-0}" -lt 10000 ]; then
    echo "FAIL: Recording too small or missing ($WAV)"
    exit 1
fi
echo "OK: Recorded ${WAV_SIZE} bytes."

# 4. Verify WAV (8 ch, 6 mics with signal)
echo "[4/4] Verifying WAV (8 channels, 6 mics with signal)..."
if [ -f "$VERIFY_PY" ]; then
    if python3 "$VERIFY_PY" "$WAV"; then
        echo ""
        echo "=== All checks passed. ReSpeaker 6-Mic is working. ==="
        exit 0
    fi
else
    # No Python verifier: only check file exists and has reasonable size (8ch 16kHz S32_LE ~ 2s = 256000 bytes)
    echo "OK: WAV file present (verify_wav.py not run)."
    echo ""
    echo "=== Recording check passed. Run verify_wav.py for channel verification. ==="
    exit 0
fi

echo ""
echo "=== Verification failed. See above. ==="
exit 1
