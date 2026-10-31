# Regina y Nuny

Videojuego educativo para Android. El idioma de la interfaz y la documentación
es español. La fase actual incluye el Bosque mágico y dos minijuegos. Ampliar por
funcionalidades sin romper progreso, accesibilidad ni funcionamiento offline.

## Trabajar completamente en la nube

- Usar el checkout existente en Codex Cloud. Cada tarea ya está aislada; no crear
  worktrees salvo petición expresa.
- No pedir al usuario instalar SDK, IDE, Java, Git ni ejecutar comandos en su PC.
- Flutter estable **3.29.3**, Dart **3.7.2** (incluido en Flutter), Java **17** para
  Android. `.flutter-version` es la referencia de CI. Actualizar versiones de
  forma conjunta y comprobar Android antes de cambiarlas.
- Android: AGP 8.7.0, Gradle 8.10.2, Kotlin 1.8.22, SDK 35, NDK 26.1.10909125.
- No cambiar archivos de credenciales ni incluir keystores, tokens,
  `android/local.properties`, SDK o compilaciones en Git.

## Estructura

- `lib/main.dart`: punto de entrada.
- `lib/app/`: composición de la aplicación y navegación global cuando haga falta.
- `lib/core/`: elementos compartidos, empezando por el tema visual.
- `lib/features/<funcionalidad>/presentation/`: pantallas de cada funcionalidad.
- Añadir `domain/` y `data/` dentro de una funcionalidad solo cuando haya lógica
  o datos que lo justifiquen. No crear capas vacías ni dependencias especulativas.
- `test/`: pruebas de comportamiento; usar rutas equivalentes a las funcionalidades.

## Validación obligatoria en cloud

Desde la raíz del repositorio, con Flutter disponible:

```sh
bash scripts/check.sh
flutter build apk --debug --no-pub
```

Si el formato falla, ejecutar `dart format lib test` en cloud y repetir.
Conservar `pubspec.lock` cuando Flutter lo genere y actualizarlo con cambios de
dependencias; no inventarlo ni editarlo a mano.

Las pruebas deben cubrir navegación, interacción y tamaños de pantalla relevantes.
No sustituir una compilación fallida por comprobaciones estáticas. Distinguir
siempre pruebas ejecutadas de comprobaciones pendientes. El workflow
`.github/workflows/android-debug.yml` publica el APK solo tras superar los checks.
No afirmar que existe un artifact sin haber observado una ejecución correcta.

## Alcance y accesibilidad

- Preferir Flutter estándar y dependencias mínimas. La base funciona sin red.
- Mantener botones con área táctil suficiente, texto escalable y desplazamiento
  en pantallas pequeñas. No forzar orientación sin un motivo del juego.
- No añadir anuncios, analítica, cuentas ni recopilar datos de menores como parte
  de esta preparación.
- El APK actual es de depuración, no una publicación en Google Play.

## Mundo jugable

- Reglas y contenido en `docs/game-world.md`; recursos originales en
  `docs/resources.md`. No incorporar imágenes o audios sin licencia compatible.
- Mantener preguntas, progresión y serialización en `features/world/domain/`,
  sin dependencia de widgets. Inyectar Random, repositorio y audio en pruebas.
- No penalizar intentos ni duplicar recompensas al repetir un nivel.
- El canal Android `regina/world` usa JSON versionado y recursos WAV precargados.
  No añadir plugins si las APIs existentes resuelven la necesidad.
- Cambiar formatos persistidos requiere migración y pruebas de restauración.
- Mantener el identificador Android `com.regina.aventuras` y la versión creciente.
- No afirmar pruebas físicas en el Redmi Note 11 basándose en pruebas de widgets.

## Voz y premios (0.3.0)

- `docs/voice-and-rewards.md` describe el flujo y la verificación.
- Narrar con `GameShell.instructions` y `GameController.narrate`; no apilar voces
  de rutas anteriores. El botón Escuchar repite sin reiniciar el reto.
- No depender de TTS instalado ni de Internet: el catálogo y sus WAV están incluidos.
- La voz sintética es provisional; mantener los IDs al sustituir grabaciones.
- Guardado formato 2 compatible con formato 1. Premios derivados de niveles y
  accesorio validado: no duplicar premios ni quitar estrellas al cambiarlo.
- Inspiración general pop y dinosaurios: personajes, iconos y dibujos originales.
