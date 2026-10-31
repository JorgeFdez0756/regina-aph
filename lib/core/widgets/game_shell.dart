import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../../features/world/presentation/game_controller.dart';
import 'forest_art.dart';

class GameScope extends InheritedNotifier<GameController> {
  const GameScope({
    super.key,
    required GameController controller,
    required super.child,
  }) : super(notifier: controller);
  static GameController of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<GameScope>()!.notifier!;
}

class GameShell extends StatefulWidget {
  const GameShell({
    super.key,
    required this.title,
    required this.child,
    this.instructions = const [],
  });
  final String title;
  final Widget child;
  final List<String> instructions;
  @override
  State<GameShell> createState() => _GameShellState();
}

class _GameShellState extends State<GameShell> {
  GameController? _game;
  bool _visible = false;
  List<String>? _last;
  int _revision = 0;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _game = GameScope.of(context);
    final visible = ModalRoute.of(context)?.isCurrent ?? true;
    if (!visible) {
      _visible = false;
      _revision++;
      _last = null;
      _game!.releaseVoice(this);
    } else {
      _visible = true;
      _game!.claimVoice(this);
      _schedule();
    }
  }

  @override
  void didUpdateWidget(GameShell old) {
    super.didUpdateWidget(old);
    if (!listEquals(old.instructions, widget.instructions)) _schedule();
  }

  void _schedule() {
    if (!_visible ||
        widget.instructions.isEmpty ||
        listEquals(_last, widget.instructions))
      return;
    final clips = List<String>.of(widget.instructions);
    _last = clips;
    final revision = ++_revision;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _visible && revision == _revision)
        _game!.narrate(clips, owner: this);
    });
  }

  @override
  void dispose() {
    _revision++;
    _game?.releaseVoice(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = GameScope.of(context);
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        title: Text(widget.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        leading:
            Navigator.canPop(context)
                ? IconButton(
                  tooltip: 'Volver',
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => Navigator.of(context).maybePop(),
                )
                : null,
        backgroundColor: const Color(0xE6E5F5DF),
        actions: [
          IconButton(
            tooltip:
                game.progress.soundEnabled
                    ? 'Desactivar sonido'
                    : 'Activar sonido',
            onPressed: game.toggleSound,
            icon: Icon(
              game.progress.soundEnabled
                  ? Icons.volume_up_rounded
                  : Icons.volume_off_rounded,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ForestBackground(
        child: SafeArea(
          child: Column(
            children: [
              if (game.saveFailed)
                MaterialBanner(
                  content: const Text(
                    'El progreso sigue aquí. Vamos a guardarlo de nuevo.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: game.retrySave,
                      child: const Text('Guardar'),
                    ),
                  ],
                ),
              if (game.audioFailed)
                const Padding(
                  padding: EdgeInsets.all(4),
                  child: Text(
                    'Los sonidos descansan. ¡Podemos seguir jugando!',
                  ),
                ),
              if (widget.instructions.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: Tooltip(
                    message: 'Repetir instrucciones',
                    child: FilledButton.tonalIcon(
                      key: const ValueKey('repeat-voice'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(180, 60),
                      ),
                      onPressed:
                          () => game.repeatInstructions(
                            widget.instructions,
                            this,
                          ),
                      icon: const Icon(
                        Icons.record_voice_over_rounded,
                        size: 30,
                      ),
                      label: const Text(
                        'Escuchar',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              Expanded(child: widget.child),
            ],
          ),
        ),
      ),
    );
  }
}

class AdventureButton extends StatelessWidget {
  const AdventureButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) => FilledButton.icon(
    onPressed: onPressed,
    icon: Icon(icon, size: 30),
    label: Text(
      label,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
    ),
  );
}

class MagicCard extends StatelessWidget {
  const MagicCard({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: const Color(0xF5FFFEF5),
      borderRadius: BorderRadius.circular(32),
      border: Border.all(color: const Color(0xFFFFE5A1), width: 3),
      boxShadow: const [
        BoxShadow(
          color: Color(0x16536A4F),
          offset: Offset(0, 5),
          blurRadius: 10,
        ),
      ],
    ),
    child: child,
  );
}

class EarnedStars extends StatelessWidget {
  const EarnedStars({super.key, this.size = 32});
  final double size;
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Tres estrellas obtenidas',
    child: Wrap(
      alignment: WrapAlignment.center,
      children: List.generate(
        3,
        (_) => Icon(
          Icons.star_rounded,
          size: size,
          color: const Color(0xFFBB811C),
        ),
      ),
    ),
  );
}
