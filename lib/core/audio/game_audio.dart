import 'package:flutter/services.dart';

enum GameSound { tap, correct, hint, complete }

abstract interface class GameAudio {
  Future<void> play(GameSound sound);
  Future<void> stop();
}

class AndroidGameAudio implements GameAudio {
  static const _channel = MethodChannel('regina/world');
  @override
  Future<void> play(GameSound sound) =>
      _channel.invokeMethod<void>('playSound', sound.name);
  @override
  Future<void> stop() => _channel.invokeMethod<void>('stopSound');
}
