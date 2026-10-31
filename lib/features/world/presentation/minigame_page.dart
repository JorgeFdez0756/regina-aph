import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/audio/game_audio.dart';
import '../../../core/widgets/forest_art.dart';
import '../../../core/widgets/game_shell.dart';
import '../domain/world.dart';

class MinigamePage extends StatefulWidget {
  const MinigamePage({super.key, required this.level, this.random});
  final ForestLevel level;
  final Random? random;
  @override
  State<MinigamePage> createState() => _MinigamePageState();
}

class _MinigamePageState extends State<MinigamePage> {
  late final session = AdventureSession(widget.level, random: widget.random);
  bool busy = false;
  bool completed = false;
  int? touchedStar;

  Future<void> _answer(String choice) async {
    if (busy) return;
    final correct = session.answer(choice);
    if (correct == null) return;
    final game = GameScope.of(context);
    setState(() {
      busy = true;
    });
    game.sound(correct ? GameSound.correct : GameSound.hint);
    await game.record(session.question, correct);
    if (session.finished) {
      await game.complete(widget.level.id);
      game.sound(GameSound.complete);
      if (mounted)
        setState(() {
          completed = true;
        });
    }
    if (mounted)
      setState(() {
        busy = false;
      });
  }

  @override
  Widget build(BuildContext context) => GameShell(
    title: widget.level.title,
    child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: completed ? _completion() : _challenge(),
        ),
      ),
    ),
  );

  Widget _completion() => Column(
    children: [
      const FriendsScene(mood: FriendsMood.happy, height: 210),
      MagicCard(
        child: Column(
          children: [
            const Text(
              '¡Lo logramos!',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const EarnedStars(size: 48),
            const SizedBox(height: 12),
            Text(
              widget.level.id == forestLevels.last.id
                  ? '¡El bosque entero vuelve a brillar!'
                  : 'Una nueva parte del bosque brilla para ti.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      AdventureButton(
        label: 'Seguir el sendero',
        icon: Icons.explore_rounded,
        onPressed: () => Navigator.of(context).pop(),
      ),
    ],
  );

  Widget _challenge() {
    final question = session.question;
    final correct = session.answered;
    final hint = session.hintVisible;
    return Column(
      children: [
        Semantics(
          label: 'Reto ${session.round + 1} de ${session.totalRounds}',
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            children: List.generate(
              session.totalRounds,
              (i) => Icon(
                i < session.round || (i == session.round && correct)
                    ? Icons.local_florist_rounded
                    : Icons.circle_outlined,
                size: 23,
                color:
                    i <= session.round
                        ? const Color(0xFF8B62BB)
                        : const Color(0xFF81957D),
              ),
            ),
          ),
        ),
        FriendsScene(
          height: 155,
          mood:
              correct
                  ? FriendsMood.happy
                  : hint
                  ? FriendsMood.surprised
                  : FriendsMood.curious,
        ),
        MagicCard(
          child: Column(
            children: [
              Text(
                question.kind == ActivityKind.counting
                    ? '¿Cuántas estrellas hay?'
                    : 'Encuentra su pareja',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              QuestionBoard(
                question: question,
                hint: hint,
                touchedStar: touchedStar,
                onStarTap: (index) {
                  setState(() {
                    touchedStar = index;
                  });
                  GameScope.of(context).sound(GameSound.tap);
                },
              ),
              const SizedBox(height: 16),
              Semantics(
                liveRegion: true,
                child: Text(
                  correct
                      ? '¡Brillas como una estrella!'
                      : hint
                      ? question.kind == ActivityKind.counting
                          ? '¡Contemos juntas! Toca cada estrella.'
                          : 'Mira la letra grande. ¡Busca una igual!'
                      : question.kind == ActivityKind.counting
                      ? 'Ayuda a Nuny a reunir sus estrellas'
                      : 'La magia está en tu nombre: REGINA',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Color(0xFF5D5B72),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (!correct)
          LayoutBuilder(
            builder: (context, constraints) {
              final width = max(
                82.0,
                min(150.0, (constraints.maxWidth - 20) / 3),
              );
              return Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 12,
                children:
                    question.options
                        .map(
                          (option) => SizedBox(
                            width: width,
                            child: ElevatedButton(
                              key: ValueKey('answer-$option'),
                              onPressed: busy ? null : () => _answer(option),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFFCF2),
                                foregroundColor: const Color(0xFF614496),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                  horizontal: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(26),
                                  side: const BorderSide(
                                    color: Color(0xFFB39BDA),
                                    width: 3,
                                  ),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    option,
                                    style: const TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  if (question.kind == ActivityKind.counting)
                                    Wrap(
                                      alignment: WrapAlignment.center,
                                      children: List.generate(
                                        int.parse(option),
                                        (_) => const Icon(
                                          Icons.circle,
                                          size: 9,
                                          color: Color(0xFFB58CDA),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        )
                        .toList(),
              );
            },
          )
        else
          AdventureButton(
            label: 'Otra aventura',
            icon: Icons.arrow_forward_rounded,
            onPressed:
                busy
                    ? null
                    : () {
                      setState(() {
                        session.next();
                        touchedStar = null;
                      });
                      GameScope.of(context).sound(GameSound.tap);
                    },
          ),
      ],
    );
  }
}

class QuestionBoard extends StatelessWidget {
  const QuestionBoard({
    super.key,
    required this.question,
    required this.hint,
    this.touchedStar,
    required this.onStarTap,
  });
  final Question question;
  final bool hint;
  final int? touchedStar;
  final ValueChanged<int> onStarTap;
  @override
  Widget build(BuildContext context) {
    if (question.kind == ActivityKind.letters)
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFE9DFF7),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Text(
              question.answer,
              key: const ValueKey('target-letter'),
              style: const TextStyle(
                fontSize: 78,
                fontWeight: FontWeight.w900,
                color: Color(0xFF70469D),
              ),
            ),
          ),
          const Icon(
            Icons.arrow_downward_rounded,
            size: 36,
            color: Color(0xFF956EBA),
          ),
        ],
      );
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 10,
      children: List.generate(
        question.starCount,
        (i) => Semantics(
          label: 'Estrella ${i + 1}',
          button: true,
          child: InkWell(
            key: ValueKey('star-$i'),
            borderRadius: BorderRadius.circular(24),
            onTap: () => onStarTap(i),
            child: AnimatedScale(
              scale: touchedStar == i ? 1.15 : 1,
              duration: const Duration(milliseconds: 180),
              child: SizedBox(
                width: 70,

                child: Column(
                  children: [
                    Icon(
                      Icons.star_rounded,
                      size: 68,
                      color:
                          touchedStar == i
                              ? const Color(0xFFEFAB28)
                              : const Color(0xFFFFC84E),
                    ),
                    if (hint)
                      Text(
                        '${i + 1}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
