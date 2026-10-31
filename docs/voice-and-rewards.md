# Voz, compañía y premios — 0.3.0

La niña puede escuchar qué hacer sin leer. Se conservan el bosque y los dos
minijuegos de la versión anterior. Todo el contenido se ejecuta offline.

## Qué probar desde el teléfono

1. Abre el juego: Nuny da la bienvenida. Pulsa **Escuchar** para repetirla.
2. Pulsa **Jugar**: la guía explica el mapa. Entra en estrellas o letras.
   Las instrucciones se oyen automáticamente. En letras se nombra el objetivo.
3. Toca las estrellas para escuchar «una», «dos», hasta «cinco». Si eliges otra
   respuesta, la voz propone intentarlo juntas. Toca a Nuny durante la pista para
   contar con ella o volver a oír la letra. No se pierden estrellas.
4. Acaricia a Nuny tocando los personajes: mueve más la cola, salta, y responde.
5. Completa una parada: celebración, tres estrellas y un premio. El accesorio nuevo
   se pone automáticamente la primera vez. **Ver mi premio** abre el álbum.
6. En **Premios de Nuny**, elige un premio desbloqueado o **Sin accesorio**.
   La selección se guarda y aparece en inicio, mapa y retos. Reinicia para comprobarlo.
7. El icono de volumen silencia voz y efectos. **Escuchar** vuelve a activar el
   sonido, lo guarda y repite la guía. No cambia el reto ni la puntuación.

Los seis regalos son lazo de estrella, pañuelo dino, capa de heroína, flor de luz,
medalla musical y corona mágica. Las paradas completadas antes de actualizar también
dan acceso a sus premios. Repetirlas no duplica estrellas ni cambia una elección
anterior. La migración conserva niveles, aprendizaje y configuración de sonido.

## Implementación

- `GameShell`: narración por pantalla, repetición visible y propiedad de la voz
  por ruta; una pantalla cubierta o destruida no corta la narración de otra.
- `VoiceCue` y `lines.json`: frases estables, instrucciones, refuerzos, números y
  letras. 31 WAV incluidos, con catálogo Kotlin generado.
- `OfflineVoice.kt`: reproducción secuencial con MediaPlayer asíncrono. Una nueva
  solicitud sustituye la anterior. Silenciar, salir o poner la app en segundo plano
  libera la voz y cancela la cola. Los efectos bajan de volumen durante la narración.
- `NunyCompanion` y `FriendsScene`: caricias, cola más rápida, saltos y gesto de
  ayuda; accesorios dibujados sin texturas grandes. Se respeta reducir movimiento.
- `RewardsPage`: álbum visual, selección validada, estado guardado con formato 2
  y lectura compatible con el formato 1. No usa plugins ni servicios externos.

## Provisional y límites de validación

La voz española es sintética (eSpeak NG) y suena robótica; no es una narración humana
definitiva. Las ilustraciones, dinosaurio y accesorios son originales provisionales.
No se utiliza música ni personajes protegidos de grupos pop o franquicias.

Las pruebas de widgets verifican las solicitudes de voz mediante un sustituto, no
el altavoz de un teléfono. Actions compila el código Android y comprueba integridad
y contenido de todos los WAV del APK, pero eso no equivale a escucharlo físicamente
en el Redmi Note 11. La prueba manual debe incluir volumen, cambio de pantalla,
segundo plano, modo avión y reapertura del progreso.
