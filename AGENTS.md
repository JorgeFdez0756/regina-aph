# Las Aventuras de Regina

Videojuego educativo para Android. El idioma de la interfaz y la documentación
es español. Esta primera versión prepara la aplicación; no desarrollar todavía
el juego completo sin una nueva tarea.

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
