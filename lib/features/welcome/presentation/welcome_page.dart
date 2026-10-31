import 'package:flutter/material.dart';
import '../../../core/audio/game_audio.dart';
import '../../../core/audio/voice_cue.dart';
import '../../../core/widgets/companion.dart';
import '../../../core/widgets/game_shell.dart';
import '../../adventure/presentation/adventure_page.dart';
import '../../world/presentation/rewards_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});
  @override
  Widget build(BuildContext context) => GameShell(
    title: 'Regina y Nuny',
    instructions: VoiceCue.welcome,
    child: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'LAS AVENTURAS DE',
                style: TextStyle(
                  letterSpacing: 3,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF496C60),
                ),
              ),
              const SizedBox(height: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'REGINA',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF7652AB),
                    letterSpacing: 3,
                  ),
                ),
              ),
              const Text(
                'y Nuny',
                style: TextStyle(
                  fontSize: 30,
                  color: Color(0xFFB65B78),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const NunyCompanion(height: 200),
              const SizedBox(height: 24),
              AdventureButton(
                label: 'Jugar',
                icon: Icons.play_arrow_rounded,
                onPressed: () {
                  GameScope.of(context).sound(GameSound.tap);
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const AdventurePage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              AdventureButton(
                label: 'Premios de Nuny',
                icon: Icons.card_giftcard_rounded,
                onPressed:
                    () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const RewardsPage(),
                      ),
                    ),
              ),
              const SizedBox(height: 16),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DinoBuddy(size: 54),
                  Flexible(
                    child: Text(
                      '¡Pequeñas heroínas, grandes aventuras!',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              const MagicCard(
                child: Column(
                  children: [
                    Text(
                      'Un bosque lleno de magia',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '¡Encuentra estrellas y despierta las letras!',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const Text('¡Aprender es una gran aventura!'),
              const SizedBox(height: 8),
              const Text(
                'Sin conexión · A tu ritmo',
                style: TextStyle(color: Color(0xFF496C60)),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
