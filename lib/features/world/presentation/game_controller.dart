import 'dart:async';
import 'package:flutter/foundation.dart';

import '../../../core/audio/game_audio.dart';
import '../data/progress_repository.dart';
import '../domain/progress.dart';
import '../domain/world.dart';

class GameController extends ChangeNotifier {
  GameController(this.repository, this.audio);
  final ProgressRepository repository;
  final GameAudio audio;
  GameProgress progress = GameProgress();
  bool loaded = false;
  bool loadFailed = false;
  bool saveFailed = false;
  bool audioFailed = false;
  bool _disposed = false;
  Object? _voiceOwner;
  void claimVoice(Object owner) {
    _voiceOwner = owner;
  }

  void releaseVoice(Object owner) {
    if (identical(_voiceOwner, owner)) {
      _voiceOwner = null;
      unawaited(_stopVoice());
    }
  }

  Future<void> _stopVoice() async {
    try {
      await audio.stopVoice();
    } catch (_) {
      /* No impedir la navegación. */
    }
  }

  Future<void> narrate(List<String> clips, {Object? owner}) async {
    if (_disposed ||
        !progress.soundEnabled ||
        (owner != null && !identical(owner, _voiceOwner)))
      return;
    try {
      await audio.speak(clips);
    } catch (_) {
      audioFailed = true;
      _notify();
    }
  }

  Future<void> repeatInstructions(List<String> clips, Object owner) async {
    if (!progress.soundEnabled) await toggleSound();
    await narrate(clips, owner: owner);
  }

  Future<void> wear(int id) {
    progress = progress.wear(id);
    return _save();
  }

  Future<void> _writes = Future.value();

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> initialize() async {
    loadFailed = false;
    _notify();
    try {
      progress = await repository.load();
      loaded = true;
    } catch (_) {
      loadFailed = true;
    }
    _notify();
  }

  Future<void> sound(GameSound sound) async {
    if (!progress.soundEnabled) return;
    try {
      await audio.play(sound);
    } catch (_) {
      audioFailed = true;
      _notify();
    }
  }

  Future<void> toggleSound() async {
    progress = progress.withSound(!progress.soundEnabled);
    if (!progress.soundEnabled) {
      try {
        await audio.stop();
      } catch (_) {
        audioFailed = true;
      }
    } else {
      await sound(GameSound.tap);
    }
    await _save();
  }

  Future<void> record(Question question, bool correct) {
    progress = progress.record(question, correct);
    return _save();
  }

  Future<void> complete(int id) {
    progress = progress.complete(id);
    return _save();
  }

  Future<void> retrySave() => _save();

  Future<void> _save() {
    final snapshot = progress;
    _notify();
    // Serializar escrituras para que un ajuste de sonido no borre un acierto.
    _writes = _writes.then((_) async {
      try {
        await repository.save(snapshot);
        saveFailed = false;
      } catch (_) {
        saveFailed = true;
      }
      _notify();
    });
    return _writes;
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(_stopVoice());
    super.dispose();
  }
}
