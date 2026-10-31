import 'dart:async';
import 'package:flutter/material.dart';
import '../audio/game_audio.dart';
import 'forest_art.dart';
import 'game_shell.dart';

class NunyCompanion extends StatefulWidget {
  const NunyCompanion({
    super.key,
    this.height = 190,
    this.mood = FriendsMood.curious,
    this.help = const ['friend'],
    this.helping = false,
  });
  final double height;
  final FriendsMood mood;
  final List<String> help;
  final bool helping;
  @override
  State<NunyCompanion> createState() => _NunyCompanionState();
}

class _NunyCompanionState extends State<NunyCompanion> {
  Timer? _timer;
  bool _petted = false;
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _pet() {
    final game = GameScope.of(context);
    game.sound(GameSound.tap);
    game.narrate(widget.help);
    _timer?.cancel();
    setState(() => _petted = true);
    _timer = Timer(const Duration(milliseconds: 1400), () {
      if (mounted) setState(() => _petted = false);
    });
  }

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label:
        widget.helping
            ? 'Nuny te ayuda. Tócala para escuchar una pista'
            : 'Acariciar a Nuny',
    child: GestureDetector(
      key: const ValueKey('pet-nuny'),
      behavior: HitTestBehavior.opaque,
      onTap: _pet,
      child: Stack(
        children: [
          AnimatedScale(
            scale: _petted ? 1.04 : 1,
            duration:
                MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : const Duration(milliseconds: 200),
            child: FriendsScene(
              height: widget.height,
              mood:
                  _petted && !widget.helping ? FriendsMood.happy : widget.mood,
              accessory: GameScope.of(context).progress.accessory,
              helping: widget.helping,
            ),
          ),
          const Positioned(
            right: 8,
            bottom: 6,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Color(0xFFFFF2BE),
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Icon(
                  Icons.pets_rounded,
                  color: Color(0xFF8457AE),
                  size: 26,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class DinoBuddy extends StatelessWidget {
  const DinoBuddy({super.key, this.size = 78});
  final double size;
  @override
  Widget build(BuildContext context) => Semantics(
    image: true,
    label: 'Dinosaurio pequeño y amistoso',
    child: SizedBox(
      width: size,
      height: size,
      child: const CustomPaint(painter: _DinoPainter()),
    ),
  );
}

class _DinoPainter extends CustomPainter {
  const _DinoPainter();
  @override
  void paint(Canvas c, Size size) {
    c.save();
    c.scale(size.width / 100, size.height / 100);
    final p = Paint()..color = const Color(0xFF77BF98);
    c.drawOval(const Rect.fromLTWH(18, 48, 61, 40), p);
    c.drawPath(
      Path()
        ..moveTo(25, 68)
        ..quadraticBezierTo(1, 70, 3, 42)
        ..quadraticBezierTo(11, 60, 33, 56),
      p,
    );
    c.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(60, 16, 20, 57),
        const Radius.circular(14),
      ),
      p,
    );
    c.drawOval(const Rect.fromLTWH(57, 12, 40, 32), p);
    c.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(28, 72, 12, 22),
        const Radius.circular(6),
      ),
      p,
    );
    c.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(59, 72, 12, 22),
        const Radius.circular(6),
      ),
      p,
    );
    p.color = const Color(0xFFB5D874);
    for (var i = 0; i < 4; i++) {
      final x = 22.0 + i * 10;
      c.drawPath(
        Path()
          ..moveTo(x, 51)
          ..lineTo(x + 4, 37)
          ..lineTo(x + 10, 51)
          ..close(),
        p,
      );
    }
    p.color = const Color(0xFF413E55);
    c.drawCircle(const Offset(83, 24), 3, p);
    p.color = const Color(0xFFF5ADB9);
    c.drawOval(const Rect.fromLTWH(84, 31, 10, 5), p);
    p
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF413E55);
    c.drawArc(const Rect.fromLTWH(81, 29, 10, 8), 0, 2.7, false, p);
    c.restore();
  }

  @override
  bool shouldRepaint(_DinoPainter old) => false;
}
