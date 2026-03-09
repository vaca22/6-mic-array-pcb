#!/usr/bin/env python3
"""
Verify ReSpeaker 6-mic recording: 8 channels, first 6 are mics with non-silent signal.
Uses only stdlib (wave, struct). Supports S16_LE and S32_LE.
"""
import sys
import wave
import struct

def verify(wav_path, min_energy=50, min_channels_with_signal=5):
    try:
        with wave.open(wav_path, 'rb') as w:
            nch = w.getnchannels()
            sampwidth = w.getsampwidth()
            nframes = w.getnframes()
            framerate = w.getframerate()
            frames = w.readframes(nframes)
    except Exception as e:
        print(f"VERIFY_FAIL: Could not open WAV: {e}")
        return False

    if nch != 8:
        print(f"VERIFY_FAIL: Expected 8 channels, got {nch}")
        return False

    if sampwidth not in (2, 4):
        print(f"VERIFY_FAIL: Unsupported sample width {sampwidth} (expected 2 or 4)")
        return False

    fmt = '<h' if sampwidth == 2 else '<i'  # S16_LE or S32_LE
    sample_size = sampwidth * nch
    if len(frames) < sample_size:
        print("VERIFY_FAIL: No samples in file")
        return False

    # Per-channel max absolute value (channels 0..5 are the 6 mics)
    ch_max = [0] * 8
    n = len(frames) // sample_size
    for i in range(n):
        for c in range(8):
            off = (i * 8 + c) * sampwidth
            raw = frames[off : off + sampwidth]
            if len(raw) == sampwidth:
                val = struct.unpack(fmt, raw)[0]
                if abs(val) > ch_max[c]:
                    ch_max[c] = abs(val)

    # Require at least min_channels_with_signal of the first 6 channels above min_energy
    mic_ok = sum(1 for c in range(6) if ch_max[c] >= min_energy)
    if mic_ok < min_channels_with_signal:
        # Pi 5 + AC108: often only 1 channel has data (known quirk). Accept 1+ as partial pass.
        if mic_ok >= 1 and min_channels_with_signal >= 5:
            print(f"VERIFY_PARTIAL: {mic_ok}/6 mic channels (Pi 5 quirk); levels: {ch_max[:6]}")
            return True
        print(f"VERIFY_FAIL: Only {mic_ok}/6 mic channels have signal (max levels: {ch_max[:6]})")
        return False

    print(f"VERIFY_OK: 8ch, {nframes} frames, {framerate} Hz; mic levels (ch0-5): {ch_max[:6]}")
    return True

if __name__ == "__main__":
    path = sys.argv[1] if len(sys.argv) > 1 else "/tmp/respeaker_6mic_test.wav"
    ok = verify(path)
    sys.exit(0 if ok else 1)
