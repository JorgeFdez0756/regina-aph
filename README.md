# Regina y Nuny — Bosque mágico

Base de un videojuego educativo para Android, creado con Flutter y desarrollado
completamente en **Codex Cloud y GitHub Actions**. No necesitas instalar ninguna
herramienta de desarrollo en tu computadora.

La versión 0.2.0 contiene un bosque ilustrado, seis paradas con desbloqueo
progresivo y dos minijuegos: contar estrellas del 1 al 5 y reconocer las letras de
REGINA, empezando por R. Regina y su perrita Nuny reaccionan con animaciones,
celebraciones y pistas amables. El progreso y la configuración de sonido se guardan
localmente. Se puede volver al mapa y repetir las actividades sin penalización.
La aplicación funciona sin conexión y no requiere cuentas ni servicios externos.

## Descargar el APK usando solo el navegador

1. Abre [el repositorio en GitHub](https://github.com/JorgeFdez0756/regina-aph).
2. Entra en **Actions** y selecciona **Android Debug APK**.
3. Abre una ejecución con marca verde, correspondiente al commit que quieras probar.
4. Baja hasta **Artifacts** y pulsa **regina-android-debug**. Debes iniciar sesión
   en GitHub para descargarlo.
5. Abre el ZIP descargado: contiene `las-aventuras-de-regina-debug.apk` y
   `SHA256SUMS.txt`. El APK es el archivo instalable en Android.

Los artifacts se conservan **14 días**. Si no hay ninguno o ha caducado, abre el
workflow y pulsa **Run workflow**, selecciona la rama y confirma **Run workflow**.
La opción aparece cuando el workflow ya existe en la rama predeterminada y tu
cuenta tiene permiso para ejecutarlo. También se ejecuta con cada push y pull request.

Para probarlo en un teléfono, descarga el ZIP desde el navegador del propio Android,
extrae el APK y ábrelo. Android puede pedir permiso a ese navegador o gestor de
archivos para instalar la app. No se necesitan herramientas de desarrollo.
Es una compilación de depuración para pruebas; no está publicada en Google Play.
La clave de depuración puede variar entre ejecuciones: si Android rechaza una
actualización por firma distinta, desinstala la versión anterior antes de instalar
esta (se perderán sus datos locales).

Si el workflow sale rojo, abre el paso fallido para ver el motivo. No habrá APK
de esa ejecución si fallaron las pruebas o la compilación.

## Qué comprueba GitHub Actions

El workflow prepara Flutter **3.29.3** estable con Dart **3.7.2**, Java **17** y el
SDK Android. Ejecuta resolución de dependencias, formato, análisis estático,
pruebas de widgets con cobertura y `flutter build apk --debug --no-pub`.
También verifica la integridad del APK, los iconos y los cuatro sonidos empaquetados.
Después publica un APK universal (sin elegir arquitectura) y su checksum SHA-256.
La cobertura se descarga por separado como **regina-test-coverage**.
No necesita secretos del proyecto ni credenciales de firma de producción.

## Organización del proyecto

```text
lib/
  main.dart
  app/regina_app.dart
  core/theme/regina_theme.dart
  core/widgets/                   Bosque, personajes y componentes compartidos
  core/audio/                     Contrato de efectos sonoros
  features/
    welcome/presentation/welcome_page.dart
    adventure/presentation/adventure_page.dart
    world/                        Reglas, progreso, repositorio y minijuegos
test/                             Navegación, lógica, progreso y canal Android
android/                         Proyecto Android y wrapper Gradle
.github/workflows/               Compilación y artifacts
scripts/check.sh                 Checks compartidos de cloud y CI
```

Consulta [el mundo jugable](docs/game-world.md) y [los recursos originales](docs/resources.md)
para conocer contenido, guardado, pruebas y qué ilustraciones siguen siendo provisionales.

Las futuras actividades pueden añadirse como funcionalidades independientes.
No se ha incorporado un motor de juego ni un gestor de estado adicional todavía.

Consulta [AGENTS.md](AGENTS.md) para las instrucciones de desarrollo y
[docs/cloud-development.md](docs/cloud-development.md) para preparar Codex Cloud.
