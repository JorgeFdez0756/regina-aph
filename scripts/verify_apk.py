"""Comprueba el APK real dentro de GitHub Actions, antes de publicarlo."""
from pathlib import Path
import hashlib
import io
import json
import sys
import wave
import zipfile


def verify(apk: Path) -> None:
    sources = Path(__file__).resolve().parents[1] / 'android/app/src/main/res/raw'
    with zipfile.ZipFile(apk) as archive:
        bad = archive.testzip()
        if bad is not None:
            raise ValueError(f'Entrada corrupta del APK: {bad}')
        names = archive.namelist()
        if 'AndroidManifest.xml' not in names or not any(name.endswith('.dex') for name in names):
            raise ValueError('El APK no contiene manifiesto o código Android')
        if not any('MaterialIcons' in name for name in names):
            raise ValueError('No se empaquetaron los iconos de la interfaz')
        catalog = json.loads((Path(__file__).resolve().parents[1] / 'scripts/voice/lines.json').read_text())
        expected = ['tap', 'correct', 'hint', 'complete'] + [f'voice_{key}' for key in catalog]
        for sound in expected:
            matches = [name for name in names if name.endswith(f'/raw/{sound}.wav')]
            if len(matches) != 1:
                raise ValueError(f'Falta el sonido {sound}')
            if archive.getinfo(matches[0]).compress_type != zipfile.ZIP_STORED:
                raise ValueError(f'El audio {sound} debe permitir lectura directa por Android')
            content = archive.read(matches[0])
            if content != (sources / f'{sound}.wav').read_bytes():
                raise ValueError(f'El sonido {sound} no coincide con el original')
            with wave.open(io.BytesIO(content)) as audio:
                if audio.getnchannels() != 1 or audio.getsampwidth() != 2 or audio.getnframes() <= 0:
                    raise ValueError(f'Formato WAV inesperado: {sound}')
            print(f'Sonido verificado: {sound}')
    print(f'APK íntegro: {apk.stat().st_size} bytes')
    print(f'SHA-256: {hashlib.sha256(apk.read_bytes()).hexdigest()}')


if __name__ == '__main__':
    verify(Path(sys.argv[1]))
