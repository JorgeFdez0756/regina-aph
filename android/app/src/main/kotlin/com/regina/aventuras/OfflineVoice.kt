package com.regina.aventuras

import android.content.Context
import android.media.AudioAttributes
import android.media.MediaPlayer
import java.util.ArrayDeque

/** Reproduce frases empaquetadas: no usa TTS del teléfono ni conexión de red. */
class OfflineVoice(private val context: Context, private val duck: (Boolean) -> Unit) {
    private var player: MediaPlayer? = null
    private val queue = ArrayDeque<Int>()
    private var active = false
    fun resume() { active = true }
    fun pause() { active = false; stop() }
    fun speak(ids: List<String>) {
        stop()
        if (!active) return
        ids.forEach { queue.add(VoiceCatalog.clips.getValue(it)) }
        next()
    }
    private fun next() {
        val resource = queue.pollFirst()
        if (resource == null || !active) { duck(false); return }
        duck(true)
        val current = MediaPlayer()
        player = current
        try {
            current.setAudioAttributes(AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_GAME)
                .setContentType(AudioAttributes.CONTENT_TYPE_SPEECH).build())
            context.resources.openRawResourceFd(resource).use { file ->
                current.setDataSource(file.fileDescriptor, file.startOffset, file.length)
            }
            current.setOnPreparedListener { if (player === it && active) it.start() }
            current.setOnCompletionListener {
                if (player === it) { player = null; it.release(); next() }
            }
            current.setOnErrorListener { failed, _, _ -> if (player === failed) stop(); true }
            current.prepareAsync()
        } catch (error: Exception) {
            stop()
        }
    }
    fun stop() {
        queue.clear()
        val old = player
        player = null
        old?.setOnPreparedListener(null)
        old?.setOnCompletionListener(null)
        old?.setOnErrorListener(null)
        old?.release()
        duck(false)
    }
}
