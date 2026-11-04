"""Gera o tema de cada planeta (sintese propria em Python puro, sem amostras de terceiros): loops de 24 s, mono, 22050 Hz, que emendam sem
estalo (as notas dao a volta no fim do loop). Uso: python -I tools/make_music.py <pasta_saida>   (sylvara vem de tools/make_audio.py)"""
import math
import random
import struct
import sys
import wave

OUT = sys.argv[1]
RATE = 22050
LEN = 24.0
N = int(RATE * LEN)
TAU = 2.0 * math.pi

# Por planeta: raiz (midi), escala (semitons), andamento, progressao (graus por compasso), timbre do arpejo e do baixo, cama de ruido.
THEMES = {
    "cristalia": dict(root=62, scale=[0, 2, 4, 6, 7, 9, 11], bpm=100, prog=[0, 4, 5, 3, 0, 4, 2, 3, 0, 5], arp="bell", bed="shimmer", bass="sine"),
    "mecatron": dict(root=45, scale=[0, 2, 3, 5, 7, 8, 10], bpm=120, prog=[0, 0, 5, 5, 3, 3, 4, 4, 0, 0, 5, 3], arp="pulse", bed="hum", bass="saw"),
    "aquarys": dict(root=57, scale=[0, 2, 3, 5, 7, 9, 10], bpm=80, prog=[0, 3, 4, 3, 0, 5, 4, 3], arp="drop", bed="water", bass="sine"),
    "aerion": dict(root=55, scale=[0, 2, 4, 5, 7, 9, 10], bpm=80, prog=[0, 4, 3, 4, 0, 3, 4, 0], arp="air", bed="wind", bass="sine"),
    "umbraxis": dict(root=40, scale=[0, 1, 3, 5, 6, 8, 10], bpm=100, prog=[0, 1, 0, 5, 0, 1, 4, 0, 1, 0], arp="dark", bed="drone", bass="saw"),
}


def hz(midi):
    return 440.0 * 2.0 ** ((midi - 69) / 12.0)


def add(track, sig, start, gain):
    n = len(sig)
    for i in range(n):
        track[(start + i) % N] += sig[i] * gain


def lowpass(sig, a):
    out = []
    y = 0.0
    for x in sig:
        y += a * (x - y)
        out.append(y)
    return out


def envelope(i, n, attack, release):
    a = max(int(RATE * attack), 1)
    r = max(int(RATE * release), 1)
    return min(1.0, i / a, (n - i) / r)


def tone(freq, dur, kind):
    n = int(RATE * dur)
    out = []
    phase = 0.0
    for i in range(n):
        t = i / RATE
        if kind == "bell":
            s = math.sin(TAU * freq * t) * math.exp(-t * 2.2) + 0.5 * math.sin(TAU * freq * 2.76 * t) * math.exp(-t * 3.4) + 0.25 * math.sin(TAU * freq * 5.4 * t) * math.exp(-t * 5.0)
        elif kind == "pulse":
            s = (1.0 if math.sin(TAU * freq * t) >= 0 else -1.0) * math.exp(-t * 9.0) * 0.6
        elif kind == "drop":
            s = math.sin(TAU * freq * t * (1.0 + 0.04 * math.exp(-t * 18.0))) * math.exp(-t * 3.0)
        elif kind == "air":
            s = (math.sin(TAU * freq * t) + 0.4 * math.sin(TAU * freq * 2 * t)) * math.exp(-t * 1.4)
        elif kind == "dark":
            s = math.sin(TAU * freq * t + 3.0 * math.exp(-t * 4.0) * math.sin(TAU * freq * 0.5 * t)) * math.exp(-t * 1.6)
        elif kind == "saw":
            phase = (phase + freq / RATE) % 1.0
            s = 2.0 * phase - 1.0
        else:
            s = math.sin(TAU * freq * t)
        out.append(s * envelope(i, n, 0.005, min(0.1, dur * 0.5)))
    return lowpass(out, 0.25) if kind == "saw" else out


def pad(freq, dur):
    n = int(RATE * dur)
    phases = [0.0, 0.0, 0.0]
    out = []
    for i in range(n):
        s = 0.0
        for k, detune in enumerate((-0.004, 0.0, 0.004)):
            phases[k] = (phases[k] + freq * (1.0 + detune) / RATE) % 1.0
            s += 2.0 * phases[k] - 1.0
        out.append(s / 3.0 * envelope(i, n, 1.2, 1.5))
    return lowpass(out, 0.08)


def bed(kind):
    rng = random.Random(7)
    noise = [rng.gauss(0.0, 1.0) for _ in range(N)]
    if kind == "wind":
        sig = lowpass(noise, 0.05)
        return [x * (0.6 + 0.4 * math.sin(TAU * i / N * 2.0)) * 3.0 for i, x in enumerate(sig)]
    if kind == "water":
        sig = lowpass(noise, 0.15)
        return [x * (0.4 + 0.6 * abs(math.sin(TAU * i / RATE * 0.5))) * 2.0 for i, x in enumerate(sig)]
    if kind == "hum":
        sig = lowpass(noise, 0.3)
        return [math.sin(TAU * 50.0 * i / RATE) * 0.18 + x * 0.25 for i, x in enumerate(sig)]
    if kind == "shimmer":
        sig = lowpass(noise, 0.6)
        return [x * 0.18 * (0.5 + 0.5 * math.sin(TAU * i / N * 2.0)) for i, x in enumerate(sig)]
    return [math.sin(TAU * 32.7 * i / RATE) * 0.3 + math.sin(TAU * 34.6 * i / RATE) * 0.25 for i in range(N)]


def render(name, cfg):
    beat = 60.0 / cfg["bpm"]
    bar = beat * 4.0
    bars = int(round(LEN / bar))
    track = [0.0] * N
    scale = cfg["scale"]
    for b in range(bars):
        degree = cfg["prog"][b % len(cfg["prog"])]
        start = int(b * bar * RATE)
        chord = [cfg["root"] + scale[(degree + k) % 7] + 12 * ((degree + k) // 7) for k in (0, 2, 4)]
        for note in chord:
            add(track, pad(hz(note), bar * 1.25), start, 0.16)
        add(track, tone(hz(chord[0] - 12), bar * 0.95, cfg["bass"]), start, 0.5)
        for i in range(8):
            note = chord[(i * 3 + b) % 3] + 12 * (1 + (i % 2))
            add(track, tone(hz(note), beat * 1.4, cfg["arp"]), start + int(i * beat * 0.5 * RATE), 0.22)
    for i, x in enumerate(bed(cfg["bed"])):
        track[i] += x * 0.35
    peak = max(abs(x) for x in track) + 1e-9
    with wave.open(f"{OUT}/music_{name}.wav", "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes(b"".join(struct.pack("<h", int(x / peak * 0.8 * 32767)) for x in track))


for planet, cfg in THEMES.items():
    render(planet, cfg)
    print("ok", planet, flush=True)
