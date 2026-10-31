# Desarrollo sin instalaciones locales

Todos los comandos de este documento se ejecutan en **Codex Cloud o GitHub
Actions**, nunca en tu computadora. Para pedir cambios basta con abrir una tarea
de Codex sobre este repositorio. Usa GitHub desde el navegador para revisar
código, ejecuciones y descargar el APK.

## Entorno de Codex

Usar el checkout existente en `/workspace/regina-aph`; no crear worktrees.
Se requiere Flutter 3.29.3 estable (que incluye Dart 3.7.2). Para compilar Android
también se necesitan Java 17, Android command-line tools y los componentes
`platforms;android-35`, `build-tools;35.0.0` y `ndk;26.1.10909125`.
GitHub Actions los prepara automáticamente con el workflow del repositorio.

Flutter necesita acceder a `storage.googleapis.com` para descargar Dart y los
binarios del motor. La política de red del entorno debe permitir también los
destinos de los gestores de paquetes: GitHub, pub.dev, dl.google.com,
repo.maven.apache.org, plugins.gradle.org y services.gradle.org y sus destinos
oficiales de descarga. El acceso a la API de GitHub requiere `api.github.com`.
Mantener las verificaciones TLS y de checksums activadas.

Desde la raíz del checkout, con el SDK en el PATH del entorno cloud:

```sh
flutter --version
flutter doctor -v
bash scripts/check.sh
flutter build apk --debug --no-pub
```

El APK se genera en `build/app/outputs/flutter-apk/app-debug.apk`.
`flutter pub get` genera `pubspec.lock`: debe conservarse en Git cuando se haya
podido resolver por primera vez. No se requieren variables secretas de la app.
Los procesos de desarrollo no sobreviven necesariamente entre tareas; esta app
no necesita un servidor persistente ni una base de datos.

## Pruebas incluidas

Consulta [docs/game-world.md](game-world.md) para la cobertura del mundo jugable.
Las pruebas incluyen ambos minijuegos, preguntas aleatorias, progresión, guardado,
fallos de almacenamiento, sonido y recorrido completo con reinicio.

Las pruebas de widgets y los sustitutos del canal nativo no prueban el altavoz ni
un dispositivo físico. La compilación Android se verifica por separado en Actions.
