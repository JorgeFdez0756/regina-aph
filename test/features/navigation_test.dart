import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:las_aventuras_de_regina/app/regina_app.dart';
import 'package:las_aventuras_de_regina/features/world/domain/world.dart';
import 'package:las_aventuras_de_regina/features/world/presentation/minigame_page.dart';
import '../support/fakes.dart';

Future<void> frame(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

Future<void> tapVisible(WidgetTester tester, Finder target) async {
  await tester.ensureVisible(target);
  await tester.pump();
  await tester.tap(target);
  await frame(tester);
}

void main() {
  testWidgets('bienvenida, mapa, bloqueo inicial y regreso', (tester) async {
    await tester.pumpWidget(
      ReginaApp(repository: MemoryProgressRepository(), audio: FakeAudio()),
    );
    await frame(tester);
    expect(find.text('REGINA'), findsOneWidget);
    await tapVisible(tester, find.text('Jugar'));
    expect(find.text('Bosque mágico'), findsOneWidget);
    expect(
      tester
          .widget<ElevatedButton>(find.byKey(const ValueKey('level-1')))
          .onPressed,
      isNotNull,
    );
    expect(
      tester
          .widget<ElevatedButton>(find.byKey(const ValueKey('level-2')))
          .onPressed,
      isNull,
    );
    await tapVisible(tester, find.text('Volver al inicio'));
    expect(find.text('Jugar'), findsOneWidget);
  });
  testWidgets(
    'regreso del sistema conserva el sonido y se restaura al reiniciar',
    (tester) async {
      final repo = MemoryProgressRepository();
      final audio = FakeAudio();
      await tester.pumpWidget(ReginaApp(repository: repo, audio: audio));
      await frame(tester);
      await tapVisible(tester, find.byTooltip('Desactivar sonido'));
      await tapVisible(tester, find.text('Jugar'));
      await tester.binding.handlePopRoute();
      await frame(tester);
      expect(find.text('Jugar'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(ReginaApp(repository: repo, audio: audio));
      await frame(tester);
      expect(find.byTooltip('Activar sonido'), findsOneWidget);
      expect(audio.played, isEmpty);
    },
  );
  testWidgets('bosque completo: pistas, ambos juegos, desbloqueo y reinicio', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 850);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repo = MemoryProgressRepository();
    await tester.pumpWidget(ReginaApp(repository: repo, audio: FakeAudio()));
    await frame(tester);
    await tapVisible(tester, find.text('Jugar'));
    for (final level in forestLevels) {
      await tapVisible(tester, find.byKey(ValueKey('level-${level.id}')));
      final rounds = level.id == 6 ? 6 : 5;
      for (var i = 0; i < rounds; i++) {
        final q =
            tester.widget<QuestionBoard>(find.byType(QuestionBoard)).question;
        if (i == 0) {
          final wrong = q.options.firstWhere((x) => x != q.answer);
          await tapVisible(tester, find.byKey(ValueKey('answer-$wrong')));
          expect(
            find.textContaining(
              level.kind == ActivityKind.counting
                  ? 'Contemos juntas'
                  : 'Mira la letra grande',
            ),
            findsOneWidget,
          );
          expect(
            tester.widget<QuestionBoard>(find.byType(QuestionBoard)).question,
            same(q),
          );
        }
        await tapVisible(tester, find.byKey(ValueKey('answer-${q.answer}')));
        if (i < rounds - 1)
          await tapVisible(tester, find.text('Otra aventura'));
      }
      expect(find.text('¡Lo logramos!'), findsOneWidget);
      await tapVisible(tester, find.text('Seguir el sendero'));
      expect(repo.value.stars, level.id * 3);
    }
    expect(repo.value.learning['counting:5']!.correct, greaterThanOrEqualTo(1));
    for (final letter in 'REGINA'.split('')) {
      expect(
        repo.value.learning['letters:$letter']!.correct,
        greaterThanOrEqualTo(1),
      );
    }
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(ReginaApp(repository: repo, audio: FakeAudio()));
    await frame(tester);
    await tapVisible(tester, find.text('Jugar'));
    expect(find.text('18 estrellas · 6/6 paradas'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'pantalla pequeña y texto doble: jugar, pista y volver sin desbordar',
    (tester) async {
      tester.view.physicalSize = const Size(320, 480);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpWidget(
        ReginaApp(repository: MemoryProgressRepository(), audio: FakeAudio()),
      );
      await frame(tester);
      await tapVisible(tester, find.text('Jugar'));
      await tapVisible(tester, find.byKey(const ValueKey('level-1')));
      final q =
          tester.widget<QuestionBoard>(find.byType(QuestionBoard)).question;
      await tapVisible(
        tester,
        find.byKey(
          ValueKey('answer-${q.options.firstWhere((x) => x != q.answer)}'),
        ),
      );
      await tapVisible(tester, find.byKey(ValueKey('answer-${q.answer}')));
      await tapVisible(tester, find.byTooltip('Volver'));
      expect(find.text('Bosque mágico'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('un doble toque correcto registra una sola respuesta', (
    tester,
  ) async {
    final repo = MemoryProgressRepository();
    await tester.pumpWidget(ReginaApp(repository: repo, audio: FakeAudio()));
    await frame(tester);
    await tapVisible(tester, find.text('Jugar'));
    await tapVisible(tester, find.byKey(const ValueKey('level-1')));
    final q = tester.widget<QuestionBoard>(find.byType(QuestionBoard)).question;
    final answer = find.byKey(ValueKey('answer-${q.answer}'));
    await tester.ensureVisible(answer);
    await tester.tap(answer);
    await tester.tap(answer);
    await frame(tester);
    expect(repo.value.learning[q.learningKey]!.correct, 1);
    expect(find.text('Otra aventura'), findsOneWidget);
  });
}
