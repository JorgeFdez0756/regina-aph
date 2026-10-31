package com.regina.aventuras

import android.media.AudioAttributes
import android.media.SoundPool
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors

/** Recursos y preferencias privados, sin red ni permisos de almacenamiento. */
class MainActivity : FlutterActivity() {
    private var sounds: SoundPool? = null
    private var voice: OfflineVoice? = null
    private var foreground = false
    private var speaking = false
    private val samples = mutableMapOf<String, Int>()
    private val ready = mutableSetOf<Int>()
    private val pending = mutableListOf<Int>()
    private val streams = mutableListOf<Int>()
    private val disk = Executors.newSingleThreadExecutor()
    private val main = Handler(Looper.getMainLooper())

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val pool = SoundPool.Builder().setMaxStreams(4).setAudioAttributes(
            AudioAttributes.Builder().setUsage(AudioAttributes.USAGE_GAME)
                .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION).build()
        ).build()
        sounds = pool
        voice = OfflineVoice(this) { isSpeaking ->
            speaking = isSpeaking
            streams.forEach { pool.setVolume(it, if (isSpeaking) 0.18f else 0.65f, if (isSpeaking) 0.18f else 0.65f) }
        }
        pool.setOnLoadCompleteListener { _, id, status ->
            if (status == 0) {
                ready.add(id)
                val waiting = pending.filter { it == id }
                pending.removeAll { it == id }
                waiting.forEach { play(id) }
            }
        }
        samples["tap"] = pool.load(this, R.raw.tap, 1)
        samples["correct"] = pool.load(this, R.raw.correct, 1)
        samples["hint"] = pool.load(this, R.raw.hint, 1)
        samples["complete"] = pool.load(this, R.raw.complete, 1)
        val prefs = getSharedPreferences("regina_world", MODE_PRIVATE)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "regina/world")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "loadProgress" -> disk.execute {
                        try {
                            val value = prefs.getString("progress", null)
                            main.post { result.success(value) }
                        } catch (error: Exception) {
                            main.post { result.error("storage", "No se pudo leer el progreso", null) }
                        }
                    }
                    "saveProgress" -> {
                        val value = call.arguments as? String
                        if (value == null) result.error("argument", "Progreso inválido", null)
                        else disk.execute {
                            try {
                                val saved = prefs.edit().putString("progress", value).commit()
                                main.post {
                                    if (saved) result.success(null)
                                    else result.error("storage", "No se pudo guardar el progreso", null)
                                }
                            } catch (error: Exception) {
                                main.post { result.error("storage", "No se pudo guardar el progreso", null) }
                            }
                        }
                    }
                    "playSound" -> {
                        val id = samples[call.arguments as? String]
                        if (id == null) result.error("sound", "Sonido no disponible", null)
                        else {
                            if (ready.contains(id)) play(id)
                            else if (pending.size < 4) pending.add(id)
                            result.success(null)
                        }
                    }
                    "speak" -> {
                        val ids = (call.arguments as? List<*>)?.filterIsInstance<String>()
                        if (ids == null || ids.isEmpty() || ids.size > 6 || ids.any { !VoiceCatalog.clips.containsKey(it) }) {
                            result.error("voice", "Frase no disponible", null)
                        } else { voice?.speak(ids); result.success(null) }
                    }
                    "stopVoice" -> { voice?.stop(); result.success(null) }
                    "stopSound" -> { voice?.stop(); stopSounds(); result.success(null) }
                    else -> result.notImplemented()
                }
            }
    }

    private fun play(id: Int) {
        if (!foreground) return
        val volume = if (speaking) 0.18f else 0.65f
        val stream = sounds?.play(id, volume, volume, 1, 0, 1f) ?: 0
        streams.add(stream)
        if (streams.size > 16) streams.removeAt(0)
    }
    private fun stopSounds() {
        pending.clear()
        streams.forEach { sounds?.stop(it) }
        streams.clear()
    }
    override fun onResume() { super.onResume(); foreground = true; voice?.resume() }
    override fun onPause() { foreground = false; voice?.pause(); stopSounds(); super.onPause() }
    override fun onDestroy() {
        voice?.stop(); voice = null
        stopSounds(); sounds?.release(); sounds = null
        disk.shutdown()
        super.onDestroy()
    }
}
