"""Gera SFX e o tema de Sylvara (sintese propria, sem amostras de terceiros). Uso: python -I tools/make_audio.py <pasta_saida>"""
import math
import random
import struct
import sys
import wave

OUT = sys.argv[1]
RATE = 22050


def write(name, samples):
    with wave.open(f"{OUT}/{name}.wav", "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes(b"".join(struct.pack("<h", max(-32767, min(32767, int(s * 32767)))) for s in samples))


def tone(freq, dur, vol=0.5, sweep_to=None, harmonics=(1.0,)):
    n = int(RATE * dur)
    out = []
    phase = 0.0
    for i in range(n):
        t = i / n
        f = freq if sweep_to is None else freq + (sweep_to - freq) * t
        phase += 2 * math.pi * f / RATE
        env = min(1.0, i / (RATE * 0.005)) * (1.0 - t) ** 1.5
        out.append(vol * env * sum(a * math.sin(phase * (k + 1)) for k, a in enumerate(harmonics)) / sum(harmonics))
    return out


def seq(*parts):
    out = []
    for p in parts:
        out += p
    return out


write("sfx_coin", seq(tone(988, 0.07, 0.4), tone(1319, 0.14, 0.4)))
write("sfx_item", seq(tone(784, 0.08, 0.4), tone(1047, 0.08, 0.4), tone(1568, 0.2, 0.4)))
write("sfx_jump", tone(320, 0.13, 0.35, sweep_to=640))
write("sfx_swap", seq(tone(500, 0.06, 0.35, sweep_to=900), tone(900, 0.07, 0.3, sweep_to=600)))
write("sfx_checkpoint", seq(tone(660, 0.12, 0.4), tone(880, 0.12, 0.4), tone(1320, 0.3, 0.4)))
write("sfx_chest", seq(tone(523, 0.1, 0.4, harmonics=(1, 0.4)), tone(659, 0.1, 0.4, harmonics=(1, 0.4)),
                       tone(784, 0.1, 0.4, harmonics=(1, 0.4)), tone(1047, 0.45, 0.4, harmonics=(1, 0.4))))
random.seed(7)
hurt = tone(420, 0.28, 0.45, sweep_to=140)
write("sfx_hurt", [h + 0.12 * (random.random() - 0.5) * (1 - i / len(hurt)) for i, h in enumerate(hurt)])

# Tema de Sylvara: arpejo de La menor pentatonica sobre um pedal; 24 s em laco perfeito.
scale = [220.0, 261.63, 293.66, 329.63, 392.0, 440.0, 523.25, 587.33]
pattern = [0, 2, 4, 5, 4, 2, 3, 1, 0, 2, 4, 6, 7, 6, 4, 2]
note_len = 0.5
total = int(RATE * 24)
music = [0.0] * total
for n_i in range(48):
    f = scale[pattern[n_i % len(pattern)]]
    start = int(n_i * note_len * RATE)
    for i, s in enumerate(tone(f, 0.9, 0.22, harmonics=(1.0, 0.3))):
        if start + i < total:
            music[start + i] += s
for i in range(total):
    music[i] += 0.07 * math.sin(2 * math.pi * 110.0 * i / RATE) + 0.04 * math.sin(2 * math.pi * 164.8 * i / RATE)
peak = max(abs(m) for m in music)
write("music_sylvara", [m / peak * 0.6 for m in music])
print("audio OK")
