"""Sonidos originales CC0, sin muestras externas. Ejecutar en cloud con Python 3."""
from pathlib import Path
import math
import struct
import wave

RATE = 22050
DEST = Path(__file__).resolve().parents[1] / 'android/app/src/main/res/raw'
MELODIES = {
    'tap': [(784, .10)],
    'correct': [(523.25, .12), (659.25, .12), (783.99, .22)],
    'hint': [(392, .13), (523.25, .20)],
    'complete': [(523.25, .13), (659.25, .13), (783.99, .13), (1046.5, .35)],
}
DEST.mkdir(parents=True, exist_ok=True)
for name, melody in MELODIES.items():
    frames = bytearray()
    for frequency, duration in melody:
        count = int(duration * RATE)
        for index in range(count):
            time = index / RATE
            envelope = min(1, index / (RATE * .012), (count - index) / (RATE * .035))
            sample = .23 * envelope * (math.sin(2 * math.pi * frequency * time) + .2 * math.sin(4 * math.pi * frequency * time))
            frames += struct.pack('<h', int(sample * 32767))
    with wave.open(str(DEST / f'{name}.wav'), 'wb') as out:
        out.setnchannels(1)
        out.setsampwidth(2)
        out.setframerate(RATE)
        out.writeframes(frames)
