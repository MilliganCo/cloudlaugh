#!/usr/bin/env python3
"""Generates synthetic laugh sounds as WAV files using only Python stdlib."""

import wave
import struct
import math
import random
import os

SAMPLE_RATE = 44100
OUTPUT_DIR = os.path.join(os.path.dirname(__file__), '..', 'assets', 'sounds')


def write_wav(filename, samples):
    with wave.open(filename, 'w') as wav:
        wav.setnchannels(1)
        wav.setsampwidth(2)
        wav.setframerate(SAMPLE_RATE)
        for s in samples:
            wav.writeframes(struct.pack('<h', int(max(-1.0, min(1.0, s)) * 32767)))


def laugh_envelope(t_in_burst, burst_dur):
    attack = 0.025
    decay = burst_dur * 0.45
    if t_in_burst < attack:
        v = t_in_burst / attack
    elif t_in_burst > burst_dur - decay:
        v = (burst_dur - t_in_burst) / decay
    else:
        v = 1.0
    return max(0.0, v) ** 1.5


def generate_laugh(
    fund_freq=150,
    num_bursts=6,
    burst_dur=0.18,
    burst_gap=0.22,
    harmonics=((1.0, 0.5), (2.0, 0.28), (3.0, 0.14), (4.0, 0.06), (5.0, 0.02)),
    pitch_slide=0.0,
    noise_level=0.018,
    rng_seed=0,
):
    rng = random.Random(rng_seed)
    total = num_bursts * (burst_dur + burst_gap) + 0.4
    n = int(SAMPLE_RATE * total)
    samples = []
    phase = 0.0
    period = burst_dur + burst_gap

    for i in range(n):
        t = i / SAMPLE_RATE
        burst_idx = int(t / period)
        t_in = t % period

        if burst_idx < num_bursts and t_in < burst_dur:
            env = laugh_envelope(t_in, burst_dur)
            # Pitch naturally rises then falls during a laugh
            progress = burst_idx / max(num_bursts - 1, 1)
            pitch_mod = 1.0 + pitch_slide * math.sin(progress * math.pi)
            # Small random jitter per burst
            jitter = 1.0 + 0.03 * rng.gauss(0, 1)
            freq = fund_freq * pitch_mod * jitter

            phase += 2 * math.pi * freq / SAMPLE_RATE
            s = sum(amp * math.sin(phase * mult) for mult, amp in harmonics)
            s += noise_level * rng.gauss(0, 1)
            s *= env * 0.55
        else:
            # Silence between bursts - let phase keep accumulating for continuity
            phase += 2 * math.pi * fund_freq / SAMPLE_RATE
            s = 0.0

        samples.append(s)

    return samples


PROFILES = [
    # (name, fund_freq, num_bursts, burst_dur, burst_gap, pitch_slide, seed)
    ("laugh_01", 160, 7, 0.17, 0.20, 0.12, 1),   # Medium, lively
    ("laugh_02", 120, 5, 0.22, 0.28, 0.08, 2),   # Deep, slow
    ("laugh_03", 220, 9, 0.13, 0.15, 0.20, 3),   # High, rapid giggle
    ("laugh_04", 140, 6, 0.20, 0.24, 0.05, 4),   # Medium-low, steady
    ("laugh_05", 190, 4, 0.25, 0.35, 0.15, 5),   # Fewer bursts, longer
    ("laugh_06", 110, 8, 0.15, 0.18, 0.10, 6),   # Deep rapid
    ("laugh_07", 250, 10, 0.10, 0.12, 0.25, 7),  # High giggle, fast
    ("laugh_08", 130, 5, 0.28, 0.30, 0.06, 8),   # Slow deep belly
    ("laugh_09", 175, 7, 0.16, 0.22, 0.18, 9),   # Lively mid
    ("laugh_10", 145, 12, 0.11, 0.14, 0.09, 10), # Rapid sustained
    ("laugh_11", 200, 6, 0.20, 0.26, 0.22, 11),  # High, expressive
    ("laugh_12", 105, 4, 0.30, 0.40, 0.04, 12),  # Very deep, few
]


def main():
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    for name, freq, bursts, bdur, bgap, slide, seed in PROFILES:
        wav_path = os.path.join(OUTPUT_DIR, f"{name}.wav")
        if os.path.exists(wav_path):
            print(f"  skip {name}.wav (already exists)")
            continue
        samples = generate_laugh(
            fund_freq=freq,
            num_bursts=bursts,
            burst_dur=bdur,
            burst_gap=bgap,
            pitch_slide=slide,
            rng_seed=seed,
        )
        write_wav(wav_path, samples)
        dur = len(samples) / SAMPLE_RATE
        print(f"  {name}.wav  ({dur:.1f}s, {freq}Hz, {bursts} bursts)")
    print(f"\nDone. Files written to: {os.path.abspath(OUTPUT_DIR)}")


if __name__ == '__main__':
    main()
