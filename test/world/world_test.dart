import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:las_aventuras_de_regina/features/world/domain/world.dart';
import 'package:las_aventuras_de_regina/features/world/domain/progress.dart';
import 'package:las_aventuras_de_regina/features/world/presentation/game_controller.dart';
import 'package:las_aventuras_de_regina/core/audio/game_audio.dart';
import '../support/fakes.dart';

void main() {
  test(
    '600 partidas: tres opciones únicas, respuesta válida y cobertura completa',
    () {
      for (final level in forestLevels) {
        for (var seed = 0; seed < 100; seed++) {
          final session = AdventureSession(level, random: Random(seed));
          final seen = <String>{};
          for (var i = 0; i < session.totalRounds; i++) {
            final question = session.question;
            expect(question.options.toSet().length, 3);
            expect(question.options, contains(question.answer));
            if (level.kind == ActivityKind.counting) {
              expect(question.starCount, inInclusiveRange(1, level.range));
              expect(
                question.options.every(
                  (v) => int.parse(v) >= 1 && int.parse(v) <= 5,
                ),
                isTrue,
              );
            } else {
              expect(
                'REGINA'.substring(0, level.range),
                contains(question.answer),
              );
            }
            seen.add(question.answer);
            expect(session.answer(question.answer), isTrue);
            if (!session.finished) session.next();
          }
          expect(session.finished, isTrue);
          expect(seen.length, level.range);
        }
      }
    },
  );
  test('las preguntas cambian de orden según la semilla', () {
    List<String> plan(int seed) {
      final game = AdventureSession(forestLevels[4], random: Random(seed));
      final result = <String>[];
      for (var i = 0; i < 5; i++) {
        result.add(game.question.answer);
        game.answer(game.question.answer);
        game.next();
      }
      return result;
    }

    expect(plan(1), isNot(equals(plan(2))));
  });
  test('R es la primera letra y una pista permite reintentar sin avanzar', () {
    final session = AdventureSession(forestLevels[1], random: Random(1));
    expect(session.question.answer, 'R');
    final original = session.question;
    expect(
      session.answer(original.options.firstWhere((x) => x != 'R')),
      isFalse,
    );
    expect(session.hintVisible, isTrue);
    session.next();
    expect(session.round, 0);
    expect(session.question, same(original));
    expect(session.answer('R'), isTrue);
    expect(session.answer('R'), isNull);
    session.next();
    expect(session.round, 1);
    expect(session.hintVisible, isFalse);
  });
  test('solo desbloquea en orden y las repeticiones no acumulan estrellas', () {
    var progress = GameProgress();
    expect(progress.isUnlocked(1), isTrue);
    expect(progress.isUnlocked(2), isFalse);
    progress = progress.complete(2);
    expect(progress.stars, 0);
    for (final level in forestLevels) {
      progress = progress.complete(level.id).complete(level.id);
      expect(progress.stars, level.id * 3);
    }
    expect(progress.complete(99).stars, 18);
  });
  test('JSON conserva estrellas, aprendizaje y sonido tras reiniciar', () {
    final question = AdventureSession(forestLevels[1]).question;
    final progress = GameProgress()
        .complete(1)
        .record(question, false)
        .record(question, true)
        .withSound(false);
    final restored = GameProgress.fromJson(progress.toJson());
    expect(restored.stars, 3);
    expect(restored.isUnlocked(2), isTrue);
    expect(restored.learning['letters:R']!.attempts, 2);
    expect(restored.learning['letters:R']!.correct, 1);
    expect(restored.soundEnabled, isFalse);
  });
  test('rechaza un formato desconocido y no restaura niveles aislados', () {
    expect(() => GameProgress.fromJson({'version': 7}), throwsFormatException);
    final json = GameProgress().toJson();
    json['levels'] = {'2': 3};
    expect(GameProgress.fromJson(json).levelStars, isEmpty);
  });
  test(
    'fallo de lectura bloquea carga y puede reintentarse sin borrar datos',
    () async {
      final repository = MemoryProgressRepository(GameProgress().complete(1))
        ..failRead = true;
      final game = GameController(repository, FakeAudio());
      addTearDown(game.dispose);
      await game.initialize();
      expect(game.loaded, isFalse);
      expect(game.loadFailed, isTrue);
      expect(repository.writes, 0);
      repository.failRead = false;
      await game.initialize();
      expect(game.progress.stars, 3);
    },
  );
  test(
    'escrituras ordenadas conservan ajustes y aciertos; reintenta fallos',
    () async {
      final repository = MemoryProgressRepository();
      final audio = FakeAudio();
      final game = GameController(repository, audio);
      addTearDown(game.dispose);
      await game.initialize();
      final q = AdventureSession(forestLevels[0]).question;
      await Future.wait([
        game.record(q, true),
        game.complete(1),
        game.toggleSound(),
      ]);
      expect(repository.value.stars, 3);
      expect(repository.value.soundEnabled, isFalse);
      expect(repository.value.learning[q.learningKey]!.correct, 1);
      expect(audio.stops, 1);
      await game.sound(GameSound.correct);
      expect(audio.played, isEmpty);
      repository.failWrite = true;
      await game.complete(2);
      expect(game.saveFailed, isTrue);
      expect(game.progress.stars, 6);
      repository.failWrite = false;
      await game.retrySave();
      expect(repository.value.stars, 6);
      expect(game.saveFailed, isFalse);
    },
  );
  test('un fallo de audio no impide guardar una respuesta', () async {
    final repository = MemoryProgressRepository();
    final game = GameController(repository, FakeAudio()..fail = true);
    addTearDown(game.dispose);
    await game.initialize();
    await game.sound(GameSound.correct);
    await game.record(AdventureSession(forestLevels[0]).question, true);
    expect(game.audioFailed, isTrue);
    expect(repository.value.learning, isNotEmpty);
  });
}
