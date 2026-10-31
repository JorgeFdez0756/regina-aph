import 'package:flutter/material.dart';
import '../../../core/audio/game_audio.dart';
import '../../../core/audio/voice_cue.dart';
import '../../../core/widgets/companion.dart';
import '../../../core/widgets/game_shell.dart';
import '../domain/rewards.dart';

class RewardsPage extends StatelessWidget {
  const RewardsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final game = GameScope.of(context);
    return GameShell(
      title: 'Premios de Nuny',
      instructions: VoiceCue.album,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              children: [
                const NunyCompanion(height: 160),
                const Text(
                  '¡Un regalo para tu mejor amiga!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 18),
                LayoutBuilder(
                  builder:
                      (context, constraints) => Wrap(
                        spacing: 12,
                        runSpacing: 14,
                        children:
                            nunyRewards.map((reward) {
                              final available = game.progress.isCompleted(
                                reward.id,
                              );
                              final selected =
                                  game.progress.accessory == reward.id;
                              return SizedBox(
                                width: (constraints.maxWidth - 12) / 2,
                                child: ElevatedButton(
                                  key: ValueKey('reward-${reward.id}'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        selected
                                            ? const Color(0xFFFFE6A0)
                                            : const Color(0xFFFFFCF4),
                                    padding: const EdgeInsets.all(12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(28),
                                      side: BorderSide(
                                        width: 3,
                                        color:
                                            selected
                                                ? const Color(0xFFBF8C30)
                                                : const Color(0xFFBAA1DA),
                                      ),
                                    ),
                                  ),
                                  onPressed:
                                      !available
                                          ? null
                                          : () {
                                            game.wear(reward.id);
                                            game.sound(GameSound.correct);
                                            game.narrate(
                                              VoiceCue.prize(reward.id),
                                            );
                                          },
                                  child: Column(
                                    children: [
                                      if (available)
                                        RewardSticker(id: reward.id)
                                      else
                                        const Padding(
                                          padding: EdgeInsets.all(18),
                                          child: Icon(
                                            Icons.lock_rounded,
                                            size: 44,
                                          ),
                                        ),
                                      const SizedBox(height: 8),
                                      Text(
                                        reward.name,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (selected)
                                        const Icon(
                                          Icons.check_circle_rounded,
                                          color: Color(0xFF4D845D),
                                          size: 32,
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                ),
                const SizedBox(height: 22),
                AdventureButton(
                  label: 'Sin accesorio',
                  icon: Icons.pets_rounded,
                  onPressed: () {
                    game.wear(0);
                    game.narrate(const ['none']);
                  },
                ),
                const SizedBox(height: 18),
                AdventureButton(
                  label: 'Volver a jugar',
                  icon: Icons.play_arrow_rounded,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RewardSticker extends StatelessWidget {
  const RewardSticker({super.key, required this.id, this.size = 82});
  final int id;
  final double size;
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: const LinearGradient(
        colors: [Color(0xFFFCE1AE), Color(0xFFE7C5F1)],
      ),
      border: Border.all(color: Colors.white, width: 4),
    ),
    child:
        id == 2
            ? DinoBuddy(size: size)
            : Icon(
              switch (id) {
                1 => Icons.star_rounded,
                3 => Icons.shield_rounded,
                4 => Icons.local_florist_rounded,
                5 => Icons.music_note_rounded,
                _ => Icons.workspace_premium_rounded,
              },
              color: const Color(0xFF9A58B7),
              size: size * .65,
            ),
  );
}
