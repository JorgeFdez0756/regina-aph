import 'package:flutter/material.dart';
import '../core/audio/game_audio.dart';
import '../core/theme/regina_theme.dart';
import '../core/widgets/game_shell.dart';
import '../features/welcome/presentation/welcome_page.dart';
import '../features/world/data/progress_repository.dart';
import '../features/world/presentation/game_controller.dart';

class ReginaApp extends StatefulWidget {
  const ReginaApp({super.key, this.repository, this.audio});
  final ProgressRepository? repository;
  final GameAudio? audio;
  @override
  State<ReginaApp> createState() => _ReginaAppState();
}

class _ReginaAppState extends State<ReginaApp> {
  late final game = GameController(
    widget.repository ?? AndroidProgressRepository(),
    widget.audio ?? AndroidGameAudio(),
  );
  @override
  void initState() {
    super.initState();
    game.initialize();
  }

  @override
  void dispose() {
    game.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GameScope(
    controller: game,
    child: MaterialApp(
      title: 'Regina y Nuny',
      debugShowCheckedModeBanner: false,
      theme: ReginaTheme.light,
      home: ListenableBuilder(
        listenable: game,
        builder: (context, child) {
          if (game.loaded) return const WelcomePage();
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child:
                    game.loadFailed
                        ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.folder_open_rounded, size: 50),
                            const Text(
                              'Vamos a buscar tu aventura guardada. Tu progreso no se borrará.',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            FilledButton(
                              onPressed: game.initialize,
                              child: const Text('Intentar de nuevo'),
                            ),
                          ],
                        )
                        : const CircularProgressIndicator(
                          semanticsLabel: 'Preparando el bosque',
                        ),
              ),
            ),
          );
        },
      ),
    ),
  );
}
