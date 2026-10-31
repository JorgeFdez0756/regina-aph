# Recursos visuales y sonoros

Los dibujos de bosque, flores, mariposas, Regina y Nuny en `forest_art.dart` son
formas vectoriales creadas para este proyecto. No se han descargado ilustraciones
ni utilizado personajes de terceros. Son diseños provisionales reemplazables.

Los archivos `tap.wav`, `correct.wav`, `hint.wav` y `complete.wav` de
`android/app/src/main/res/raw/` son síntesis musical original de ondas sinusoidales.
Su fuente reproducible es `scripts/generate_sounds.py` (Python estándar, solo cloud).
No contienen grabaciones, voces ni muestras externas. Cada efecto dura menos de un
segundo y se precarga en SoundPool para reducir latencia.

Estos dibujos y los cuatro WAV originales se ofrecen bajo **CC0 1.0 Universal**:
https://creativecommons.org/publicdomain/zero/1.0/

Los iconos de interfaz proceden de Material Icons incluido en Flutter y conservan
su licencia Apache 2.0. Las fuentes predeterminadas las proporciona el sistema.
El nuevo icono Android `ic_nuny.xml` es un dibujo vectorial original de Nuny.
El pequeño dinosaurio y los accesorios también se dibujan con formas originales.
No se han copiado personajes, logotipos ni música de franquicias o grupos pop.


## Voz provisional offline (0.3.0)

31 clips de voz sintética en español latinoamericano, generados a partir de textos originales en
`scripts/voice/lines.json`. Los WAV de salida se empaquetan en el APK; no se usa
el motor TTS del teléfono ni se descarga una voz al jugar. La voz es formante,
claramente sintética, y puede sustituirse por una narradora definitiva.

Generador de desarrollo: `@echogarden/espeak-ng-emscripten` 0.3.5 (eSpeak NG,
GPL-3.0), fijado con package-lock. El motor y sus datos se usan solo en cloud,
no se incluyen en el APK. Los WAV son síntesis de textos propios, no grabaciones
reutilizadas de terceros. «Nuni» es la grafía fonética usada para pronunciar Nuny.

Para regenerar en **Codex Cloud**, desde la raíz: `npm ci --prefix scripts/voice
--ignore-scripts` y `npm run --prefix scripts/voice generate`. Nunca se pide instalar
Node ni el sintetizador en la computadora del usuario. Cambiar un texto requiere
regenerar sus clips y conservar el catálogo Kotlin y los WAV en Git. La compilación
normal de Actions utiliza los WAV ya generados y no instala el sintetizador.
