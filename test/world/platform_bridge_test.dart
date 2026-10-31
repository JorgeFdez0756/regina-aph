import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:las_aventuras_de_regina/features/world/data/progress_repository.dart';
import 'package:las_aventuras_de_regina/features/world/domain/progress.dart';
import 'package:las_aventuras_de_regina/core/audio/game_audio.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('regina/world');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  tearDown(() => messenger.setMockMethodCallHandler(channel, null));
  test(
    'contrato Android: guardar JSON, restaurarlo y reproducir/silenciar sonido',
    () async {
      String? stored;
      final methods = <String>[];
      messenger.setMockMethodCallHandler(channel, (call) async {
        methods.add(call.method);
        switch (call.method) {
          case 'saveProgress':
            stored = call.arguments as String;
          case 'loadProgress':
            return stored;
          case 'playSound':
            expect(call.arguments, 'correct');
        }
        return null;
      });
      final repo = AndroidProgressRepository();
      expect((await repo.load()).stars, 0);
      await repo.save(GameProgress().complete(1).withSound(false));
      expect(jsonDecode(stored!)['version'], 2);
      final restored = await AndroidProgressRepository().load();
      expect(restored.stars, 3);
      expect(restored.soundEnabled, isFalse);
      await AndroidGameAudio().play(GameSound.correct);
      await AndroidGameAudio().stop();
      await AndroidGameAudio().speak(['letters', 'l_r']);
      await AndroidGameAudio().stopVoice();
      expect(
        methods,
        containsAllInOrder([
          'loadProgress',
          'saveProgress',
          'loadProgress',
          'playSound',
          'stopSound',
          'speak',
          'stopVoice',
        ]),
      );
    },
  );
  test(
    'errores nativos de almacenamiento y JSON corrupto no se ocultan',
    () async {
      messenger.setMockMethodCallHandler(channel, (_) async => '{broken');
      await expectLater(
        AndroidProgressRepository().load(),
        throwsFormatException,
      );
      messenger.setMockMethodCallHandler(
        channel,
        (_) async => throw PlatformException(code: 'storage'),
      );
      await expectLater(
        AndroidProgressRepository().save(GameProgress()),
        throwsA(isA<PlatformException>()),
      );
    },
  );
}
