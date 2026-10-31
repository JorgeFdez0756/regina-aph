import 'package:flutter/material.dart';
import '../../../core/audio/game_audio.dart';
import '../../../core/widgets/forest_art.dart';
import '../../../core/widgets/game_shell.dart';
import '../../world/domain/world.dart';
import '../../world/presentation/minigame_page.dart';

class AdventurePage extends StatelessWidget {
  const AdventurePage({super.key});
  @override
  Widget build(BuildContext context) {
    final game = GameScope.of(context);
    return GameShell(
      title: 'Bosque mágico',
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              children: [
                const FriendsScene(height: 145),
                MagicCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Color(0xFFBE851C),
                        size: 32,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          '${game.progress.stars} estrellas · ${game.progress.levelStars.length}/6 paradas',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                for (final level in forestLevels) ...[
                  Align(
                    alignment:
                        level.id.isOdd
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 340),
                      child: _LevelStone(level: level),
                    ),
                  ),
                  if (level.id != forestLevels.length)
                    const SizedBox(
                      height: 40,
                      child: Center(
                        child: Icon(
                          Icons.more_vert_rounded,
                          size: 36,
                          color: Color(0xFF72A576),
                        ),
                      ),
                    ),
                ],
                if (game.progress.levelStars.length == forestLevels.length)
                  const Padding(
                    padding: EdgeInsets.only(top: 24),
                    child: MagicCard(
                      child: Text(
                        '¡El bosque brilla gracias a ti! Puedes volver a explorar cada parada.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 22),
                      ),
                    ),
                  ),
                const SizedBox(height: 28),
                TextButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.home_rounded),
                  label: const Text('Volver al inicio'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LevelStone extends StatelessWidget {
  const _LevelStone({required this.level});
  final ForestLevel level;
  @override
  Widget build(BuildContext context) {
    final game = GameScope.of(context);
    final unlocked = game.progress.isUnlocked(level.id);
    final completed = game.progress.isCompleted(level.id);
    return Semantics(
      label:
          'Parada ${level.id}, ${level.title}, ${completed
              ? 'completada'
              : unlocked
              ? 'disponible'
              : 'bloqueada'}',
      child: ElevatedButton(
        key: ValueKey('level-${level.id}'),
        style: ElevatedButton.styleFrom(
          foregroundColor: const Color(0xFF493C68),
          backgroundColor:
              completed ? const Color(0xFFFFEAA2) : const Color(0xFFFFFCF3),
          disabledBackgroundColor: const Color(0xFFDEDFDA),
          disabledForegroundColor: const Color(0xFF636C66),
          padding: const EdgeInsets.all(18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
            side: BorderSide(
              color:
                  completed ? const Color(0xFFE2BB57) : const Color(0xFFA7C8A3),
              width: 3,
            ),
          ),
        ),
        onPressed:
            !unlocked
                ? null
                : () {
                  game.sound(GameSound.tap);
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => MinigamePage(level: level),
                    ),
                  );
                },
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFFE8E0F5),
                shape: BoxShape.circle,
              ),
              child:
                  unlocked && level.kind == ActivityKind.letters
                      ? const Text(
                        'R',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                        ),
                      )
                      : Icon(
                        unlocked ? Icons.star_rounded : Icons.lock_rounded,
                        size: 32,
                      ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${level.id}. ${level.title}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (completed)
                    const EarnedStars(size: 24)
                  else
                    Text(
                      unlocked ? '¡Vamos, Nuny!' : 'Sigue el sendero',
                      style: const TextStyle(fontSize: 15),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
