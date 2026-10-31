import 'package:flutter/services.dart';

enum GameSound { tap, correct, hint, complete }

abstract interface class GameAudio {
  Future<void> play(GameSound sound);
  Future<void> stop();
  Future<void> speak(List<String> clips);
  Future<void> stopVoice();
}

class AndroidGameAudio implements GameAudio {
  @override
  Future<void> speak(List<String> clips) =>
      _channel.invokeMethod<void>('speak', clips);
  @override
  Future<void> stopVoice() => _channel.invokeMethod<void>('stopVoice');
  static const _channel = MethodChannel('regina/world');
  @override
  Future<void> play(GameSound sound) =>
      _channel.invokeMethod<void>('playSound', sound.name);
  @override
  Future<void> stop() => _channel.invokeMethod<void>('stopSound');
}
