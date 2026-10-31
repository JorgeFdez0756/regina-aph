import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:las_aventuras_de_regina/app/regina_app.dart';
import 'package:las_aventuras_de_regina/core/widgets/forest_art.dart';
import 'package:las_aventuras_de_regina/features/world/domain/progress.dart';
import 'package:las_aventuras_de_regina/features/world/domain/world.dart';
import 'package:las_aventuras_de_regina/features/world/presentation/game_controller.dart';
import 'package:las_aventuras_de_regina/features/world/presentation/minigame_page.dart';
import '../features/navigation_test.dart' show frame, tapVisible;
import '../support/fakes.dart';

void main() {
  test('migra versión 1 sin perder niveles, aprendizaje ni sonido', () {
    final old = {
      'version': 1,
      'sound': false,
      'levels': {'1': 3, '2': 3},
      'learning': {
        'letters:R': {'attempts': 4, 'correct': 2},
      },
    };
    final progress = GameProgress.fromJson(old);
    expect(progress.stars, 6);
    expect(progress.soundEnabled, isFalse);
    expect(progress.learning['letters:R']!.correct, 2);
    expect(progress.accessory, 0);
    final equipped = progress.wear(2);
    expect(GameProgress.fromJson(equipped.toJson()).accessory, 2);
    expect(equipped.toJson()['version'], 2);
    expect(equipped.levelStars.length, 2);
  });
  test(
    'premios desbloqueados, selección persistente y repetición sin duplicados',
    () {
      var progress = GameProgress().complete(1).complete(2);
      expect(progress.accessory, 2);
      progress = progress.wear(1).complete(2);
      expect(progress.accessory, 1);
      expect(progress.stars, 6);
      expect(progress.wear(6).accessory, 1);
      expect(progress.wear(-1).accessory, 1);
      expect(progress.withSound(false).accessory, 1);
      expect(
        progress
            .record(AdventureSession(forestLevels[0]).question, true)
            .accessory,
        1,
      );
      final invalid = progress.toJson()..['accessory'] = 6;
      expect(GameProgress.fromJson(invalid).accessory, 0);
    },
  );
  test(
    'una pantalla anterior no interrumpe la voz de la pantalla actual',
    () async {
      final audio = FakeAudio();
      final game = GameController(MemoryProgressRepository(), audio);
      addTearDown(game.dispose);
      await game.initialize();
      final home = Object();
      final level = Object();
      game.claimVoice(home);
      await game.narrate(['welcome'], owner: home);
      game.claimVoice(level);
      game.releaseVoice(home);
      expect(audio.voiceStops, 0);
      await game.narrate(['map'], owner: home);
      expect(audio.spoken, [
        ['welcome'],
      ]);
      await game.narrate(['counting'], owner: level);
      expect(audio.spoken.last, ['counting']);
      game.releaseVoice(level);
      expect(audio.voiceStops, 1);
    },
  );
  test(
    'mutear silencia la narración; repetir reactiva y guarda el sonido',
    () async {
      final repo = MemoryProgressRepository();
      final audio = FakeAudio();
      final game = GameController(repo, audio);
      addTearDown(game.dispose);
      await game.initialize();
      final owner = Object();
      game.claimVoice(owner);
      await game.toggleSound();
      await game.narrate(['welcome']);
      expect(audio.spoken, isEmpty);
      expect(audio.stops, 1);
      await game.repeatInstructions(['welcome'], owner);
      expect(audio.spoken.last, ['welcome']);
      expect(repo.value.soundEnabled, isTrue);
    },
  );
  testWidgets(
    'bienvenida hablada, repetición visible, caricia y guía al cambiar de pantalla',
    (tester) async {
      final audio = FakeAudio();
      await tester.pumpWidget(
        ReginaApp(repository: MemoryProgressRepository(), audio: audio),
      );
      await frame(tester);
      expect(audio.spoken.last, ['welcome']);
      await tapVisible(tester, find.byKey(const ValueKey('repeat-voice')));
      expect(audio.spoken.where((c) => c.first == 'welcome').length, 2);
      await tapVisible(tester, find.byKey(const ValueKey('pet-nuny')));
      expect(audio.spoken.last, ['friend']);
      expect(
        tester.widget<FriendsScene>(find.byType(FriendsScene)).mood,
        FriendsMood.happy,
      );
      await tapVisible(tester, find.text('Jugar'));
      expect(audio.spoken.last, ['map']);
      await tapVisible(tester, find.byKey(const ValueKey('level-1')));
      expect(audio.spoken.last, ['counting']);
      final q =
          tester.widget<QuestionBoard>(find.byType(QuestionBoard)).question;
      await tapVisible(tester, find.byKey(const ValueKey('star-0')));
      expect(audio.spoken.last, ['n1']);
      await tapVisible(
        tester,
        find.byKey(
          ValueKey('answer-${q.options.firstWhere((o) => o != q.answer)}'),
        ),
      );
      expect(audio.spoken.last, ['hint_counting']);
      await tapVisible(tester, find.byKey(const ValueKey('pet-nuny')));
      expect(audio.spoken.last.first, 'hint_counting');
      expect(audio.spoken.last.length, q.starCount + 1);
      await tapVisible(tester, find.byKey(ValueKey('answer-${q.answer}')));
      expect(audio.spoken.last, ['correct', 'next']);
    },
  );
  testWidgets(
    'las letras se nombran y las pistas mantienen la referencia hablada',
    (tester) async {
      final audio = FakeAudio();
      await tester.pumpWidget(
        ReginaApp(
          repository: MemoryProgressRepository(GameProgress().complete(1)),
          audio: audio,
        ),
      );
      await frame(tester);
      await tapVisible(tester, find.text('Jugar'));
      await tapVisible(tester, find.byKey(const ValueKey('level-2')));
      expect(audio.spoken.last, ['letters', 'l_r']);
      await tapVisible(tester, find.byKey(const ValueKey('repeat-voice')));
      expect(audio.spoken.last, ['letters', 'l_r']);
      final q =
          tester.widget<QuestionBoard>(find.byType(QuestionBoard)).question;
      await tapVisible(
        tester,
        find.byKey(
          ValueKey('answer-${q.options.firstWhere((o) => o != q.answer)}'),
        ),
      );
      expect(audio.spoken.last, ['hint_letters', 'l_r']);
    },
  );
  testWidgets('álbum: selección, candados, accesorio visible y restauración', (
    tester,
  ) async {
    final repo = MemoryProgressRepository(
      GameProgress().complete(1).complete(2),
    );
    final audio = FakeAudio();
    await tester.pumpWidget(ReginaApp(repository: repo, audio: audio));
    await frame(tester);
    await tapVisible(tester, find.text('Premios de Nuny'));
    expect(audio.spoken.last, ['album']);
    expect(
      tester
          .widget<ElevatedButton>(find.byKey(const ValueKey('reward-3')))
          .onPressed,
      isNull,
    );
    await tapVisible(tester, find.byKey(const ValueKey('reward-1')));
    expect(repo.value.accessory, 1);
    expect(audio.spoken.last, ['r1']);
    expect(tester.widget<FriendsScene>(find.byType(FriendsScene)).accessory, 1);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(ReginaApp(repository: repo, audio: audio));
    await frame(tester);
    expect(tester.widget<FriendsScene>(find.byType(FriendsScene)).accessory, 1);
    expect(repo.value.stars, 6);
  });
  testWidgets('álbum y narración accesibles con texto doble en 320 por 480', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(
      ReginaApp(
        repository: MemoryProgressRepository(GameProgress().complete(1)),
        audio: FakeAudio(),
      ),
    );
    await frame(tester);
    await tapVisible(tester, find.text('Premios de Nuny'));
    await tapVisible(tester, find.byKey(const ValueKey('reward-1')));
    expect(tester.takeException(), isNull);
  });
}
