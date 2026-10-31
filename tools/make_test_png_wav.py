"""Gera PNG RGBA (com pixels transparentes) e WAV de teste, so com a biblioteca padrao.
Uso: python -I tools/make_test_png_wav.py <saida_png> <saida_wav>"""
import math
import struct
import sys
import wave
import zlib

png_out, wav_out = sys.argv[1:3]
w = h = 32
rows = b""
for y in range(h):
    row = b"\x00"
    for x in range(w):
        inside = (x - 16) ** 2 + (y - 16) ** 2 < 12 ** 2
        row += bytes((240, 138, 59, 255)) if inside else bytes((0, 0, 0, 0))
    rows += row


def chunk(tag: bytes, data: bytes) -> bytes:
    return struct.pack(">I", len(data)) + tag + data + struct.pack(">I", zlib.crc32(tag + data) & 0xFFFFFFFF)


with open(png_out, "wb") as f:
    f.write(b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", w, h, 8, 6, 0, 0, 0))
            + chunk(b"IDAT", zlib.compress(rows)) + chunk(b"IEND", b""))

with wave.open(wav_out, "wb") as wf:
    wf.setnchannels(1)
    wf.setsampwidth(2)
    wf.setframerate(44100)
    wf.writeframes(b"".join(struct.pack("<h", int(12000 * math.sin(2 * math.pi * 440 * i / 44100))) for i in range(4410)))
print("OK", png_out, wav_out)
