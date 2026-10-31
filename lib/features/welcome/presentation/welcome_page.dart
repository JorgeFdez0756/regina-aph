import 'package:flutter/material.dart';

import '../../adventure/presentation/adventure_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.auto_stories_rounded,
                    size: 96,
                    color: colors.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Las Aventuras de Regina',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '¡Aprender es una gran aventura!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Acompaña a Regina a descubrir un mundo lleno de curiosidad.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (context) => const AdventurePage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.explore_rounded),
                    label: const Text('Comenzar aventura'),
                  ),
                  const SizedBox(height: 24),
                  const Text('Primera exploración · Sin conexión'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
