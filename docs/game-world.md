# Regina y Nuny — Bosque mágico

Primera versión jugable, offline y sin cuentas, anuncios ni servicios externos.
La app mantiene la bienvenida, la navegación de regreso y el pipeline Android.
Ahora el botón **Jugar** abre un sendero con seis paradas.

| Parada | Actividad | Contenido |
| --- | --- | --- |
| 1 | Las estrellas perdidas | Cantidades 1 y 2 |
| 2 | La magia de R | Reconocer R entre tres letras |
| 3 | Un cielo de estrellas | Cantidades del 1 al 3 |
| 4 | R, E y G brillan | Reconocer R, E y G |
| 5 | Cinco deseos | Cantidades del 1 al 5 |
| 6 | El nombre de Regina | Reconocer R, E, G, I, N y A |

Cada parada tiene cinco retos; la última tiene seis para practicar cada letra.
Los objetivos se barajan en bloques, garantizando que aparezca todo el contenido
introducido. Las tres opciones siempre son distintas e incluyen la respuesta.
No hay cronómetro, vidas ni pérdida de estrellas. Cada acierto celebra; un intento
distinto muestra una pista y conserva el mismo reto. Las estrellas se pueden tocar
y, con la pista, muestran su orden. Las tarjetas numéricas incluyen puntos para
comparar cantidades sin depender de la lectura. Las letras se emparejan con una
referencia grande; no se exige leer una palabra completa.

Completar una parada concede tres estrellas y abre la siguiente. Repetirla permite
practicar, sin duplicar recompensas. La sexta completa el bosque (18 estrellas).
El botón de sonido está disponible en inicio, mapa y actividades.

## Guardado

Android almacena un JSON privado mediante SharedPreferences, con versión de formato.
Guarda niveles, estrellas, sonido e intentos/aciertos por letra y cantidad.
Las escrituras se serializan; el disco se usa fuera del hilo de interfaz.
Al interrumpir una parada se conservan los datos de aprendizaje ya guardados, pero
la próxima visita comienza sus retos desde el principio. No se desbloquea un nivel
hasta completar la parada anterior. Desinstalar la app o borrar sus datos elimina
este progreso local.

Un fallo de lectura ofrece reintentar sin reemplazar los datos existentes. Un fallo
de escritura mantiene el estado en memoria y ofrece **Guardar** de nuevo. Un fallo
de sonido permite seguir jugando. No hay sincronización ni recopilación de datos.

## Recursos originales y sustitución

- `lib/core/widgets/forest_art.dart`: bosque y personajes vectoriales originales.
  `FriendsScene(mood: ..., height: ...)` concentra el dibujo y las animaciones.
  Se puede sustituir por sprites personalizados sin cambiar preguntas o guardado.
- Estados de personajes: curiosidad, sorpresa amable y celebración. Se respeta la
  preferencia del sistema para reducir animaciones. Los dibujos se aíslan mediante
  RepaintBoundary; el bosque estático no se repinta en cada fotograma.
- `android/app/src/main/res/raw/*.wav`: cuatro efectos musicales originales,
  generados por `scripts/generate_sounds.py`, sin muestras descargadas.
  Se reproducen con SoundPool y se detienen al salir de la app o silenciarla.
- `docs/resources.md`: procedencia y licencia de estos recursos.

Los personajes y sonidos son provisionales. No hay voces narradas, sprites finales,
música continua ni más mundos. Esta versión usa pistas visuales, iconos y cantidades
para acompañar a una niña que todavía no lee.

## Verificación en cloud

`bash scripts/check.sh` ejecuta formato, análisis y pruebas. Estas incluyen 600
partidas con semillas distintas, progresión sin recompensas duplicadas, errores de
guardado, contrato del canal Android y recorrido de las seis paradas con reinicio.
También se prueba una pantalla de 320 × 480 con texto al doble de tamaño.

Las pruebas Dart del canal usan un sustituto de la plataforma: no prueban por sí
solas la reproducción física del altavoz ni el almacenamiento de un dispositivo.
La compilación Android se verifica por separado en GitHub Actions. Antes de publicar,
`scripts/verify_apk.py` comprueba el ZIP del APK, el código Android, Material Icons
y la presencia y contenido exacto de los cuatro sonidos WAV. El Redmi Note 11
es el dispositivo de referencia; no afirmar que una versión nueva se probó allí
sin una prueba real del APK.
