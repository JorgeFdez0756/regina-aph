import 'dart:math' as math;

import 'package:flutter/material.dart';

enum FriendsMood { curious, happy, surprised }

/// Arte vectorial original. Sustituir este widget por sprites conserva las pantallas.
class FriendsScene extends StatefulWidget {
  const FriendsScene({
    super.key,
    this.mood = FriendsMood.curious,
    this.height = 190,
  });
  final FriendsMood mood;
  final double height;
  @override
  State<FriendsScene> createState() => _FriendsSceneState();
}

class _FriendsSceneState extends State<FriendsScene>
    with SingleTickerProviderStateMixin {
  late final _motion = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  );
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _motion.stop();
    } else if (!_motion.isAnimating) {
      _motion.repeat();
    }
  }

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    image: true,
    label: switch (widget.mood) {
      FriendsMood.happy => 'Regina y su perrita Nuny celebran juntas',
      FriendsMood.surprised => 'Nuny te acompaña a intentarlo otra vez',
      FriendsMood.curious => 'Regina y Nuny, una pequeña perrita chihuahua',
    },
    child: SizedBox(
      height: widget.height,
      width: double.infinity,
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _motion,
          builder:
              (context, child) => CustomPaint(
                painter: _FriendsPainter(_motion.value, widget.mood),
              ),
        ),
      ),
    ),
  );
}

class _FriendsPainter extends CustomPainter {
  _FriendsPainter(this.time, this.mood);
  final double time;
  final FriendsMood mood;
  final Paint ink = Paint()..isAntiAlias = true;
  void oval(Canvas c, Rect rect, int color) {
    ink.color = Color(color);
    c.drawOval(rect, ink);
  }

  void line(Canvas c, Offset a, Offset b, int color, double width) {
    ink
      ..color = Color(color)
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;
    c.drawLine(a, b, ink);
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    final scale = math.min(size.width / 310, size.height / 200);
    canvas.translate(
      (size.width - 310 * scale) / 2,
      (size.height - 200 * scale) / 2,
    );
    canvas.scale(scale);
    oval(canvas, const Rect.fromLTWH(35, 175, 245, 18), 0x22306457);
    final wave = math.sin(time * math.pi * 2);
    final bounce = mood == FriendsMood.happy ? -wave.abs() * 16 : wave * 2;
    canvas.save();
    canvas.translate(0, bounce);
    // Regina: cabello, vestido, brazos, rostro y botas.
    oval(canvas, const Rect.fromLTWH(68, 10, 95, 106), 0xFF633C3B);
    line(canvas, const Offset(100, 143), const Offset(96, 177), 0xFFF7C5A1, 13);
    line(
      canvas,
      const Offset(133, 143),
      const Offset(138, 177),
      0xFFF7C5A1,
      13,
    );
    oval(canvas, const Rect.fromLTWH(81, 171, 27, 16), 0xFF6E4BB1);
    oval(canvas, const Rect.fromLTWH(128, 171, 27, 16), 0xFF6E4BB1);
    line(
      canvas,
      const Offset(90, 104),
      Offset(66, mood == FriendsMood.happy ? 69 : 133),
      0xFFF7C5A1,
      13,
    );
    line(
      canvas,
      const Offset(144, 104),
      Offset(168, mood == FriendsMood.happy ? 69 : 127 + wave * 4),
      0xFFF7C5A1,
      13,
    );
    ink.color = const Color(0xFF9471D8);
    canvas.drawPath(
      Path()
        ..moveTo(95, 93)
        ..lineTo(139, 93)
        ..lineTo(157, 152)
        ..quadraticBezierTo(117, 168, 77, 152)
        ..close(),
      ink,
    );
    oval(canvas, const Rect.fromLTWH(83, 23, 68, 73), 0xFFFFD3AE);
    ink.color = const Color(0xFF633C3B);
    canvas.drawPath(
      Path()
        ..moveTo(81, 51)
        ..quadraticBezierTo(83, -1, 139, 23)
        ..lineTo(153, 52)
        ..quadraticBezierTo(122, 49, 109, 27)
        ..quadraticBezierTo(100, 46, 81, 51),
      ink,
    );
    oval(canvas, const Rect.fromLTWH(143, 18, 23, 16), 0xFFFFACBC);
    oval(canvas, const Rect.fromLTWH(94, 60, 7, 9), 0xFF453743);
    oval(canvas, const Rect.fromLTWH(130, 60, 7, 9), 0xFF453743);
    oval(canvas, const Rect.fromLTWH(87, 70, 14, 7), 0xFFFFACAE);
    oval(canvas, const Rect.fromLTWH(134, 70, 14, 7), 0xFFFFACAE);
    if (mood == FriendsMood.surprised) {
      oval(canvas, const Rect.fromLTWH(112, 75, 9, 12), 0xFFB46A66);
    } else {
      ink
        ..color = const Color(0xFFB46A66)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawArc(
        const Rect.fromLTWH(106, 70, 22, 15),
        0,
        math.pi,
        false,
        ink,
      );
      ink.style = PaintingStyle.fill;
    }
    oval(canvas, const Rect.fromLTWH(105, 108, 25, 25), 0xFFFFDE79);
    ink
      ..color = const Color(0xFF65489C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6;
    canvas.drawPath(
      Path()
        ..moveTo(112, 128)
        ..lineTo(112, 113)
        ..lineTo(118, 113)
        ..quadraticBezierTo(126, 113, 124, 119)
        ..quadraticBezierTo(123, 123, 112, 121)
        ..moveTo(119, 121)
        ..lineTo(125, 128),
      ink,
    );
    ink.style = PaintingStyle.fill;
    canvas.restore();
    // Nuny: orejas grandes de chihuahua y cola que se mueve.
    canvas.save();
    canvas.translate(0, mood == FriendsMood.happy ? -wave.abs() * 10 : 0);
    line(
      canvas,
      const Offset(259, 142),
      Offset(281 + wave * 5, 116 + wave * 8),
      0xFFC69160,
      10,
    );
    oval(canvas, const Rect.fromLTWH(199, 127, 71, 43), 0xFFDCAA77);
    line(
      canvas,
      const Offset(214, 156),
      const Offset(209, 179),
      0xFFC69160,
      10,
    );
    line(
      canvas,
      const Offset(255, 156),
      const Offset(260, 179),
      0xFFC69160,
      10,
    );
    ink.color = const Color(0xFFDCAA77);
    canvas.drawPath(
      Path()
        ..moveTo(204, 118)
        ..lineTo(192, 63)
        ..quadraticBezierTo(222, 67, 227, 111)
        ..close(),
      ink,
    );
    canvas.drawPath(
      Path()
        ..moveTo(231, 110)
        ..quadraticBezierTo(250, 61, 267, 70)
        ..lineTo(254, 127)
        ..close(),
      ink,
    );
    ink.color = const Color(0xFFF4ACB0);
    canvas.drawPath(
      Path()
        ..moveTo(204, 99)
        ..lineTo(200, 77)
        ..lineTo(218, 106)
        ..close(),
      ink,
    );
    canvas.drawPath(
      Path()
        ..moveTo(241, 108)
        ..lineTo(258, 82)
        ..lineTo(250, 115)
        ..close(),
      ink,
    );
    oval(canvas, const Rect.fromLTWH(198, 94, 66, 58), 0xFFE4B888);
    oval(canvas, const Rect.fromLTWH(207, 113, 8, 10), 0xFF453743);
    oval(canvas, const Rect.fromLTWH(242, 113, 8, 10), 0xFF453743);
    oval(canvas, const Rect.fromLTWH(216, 124, 30, 22), 0xFFFFE5C4);
    oval(canvas, const Rect.fromLTWH(226, 126, 10, 7), 0xFF65473E);
    if (mood == FriendsMood.happy)
      oval(canvas, const Rect.fromLTWH(229, 138, 9, 10), 0xFFF294A7);
    line(canvas, const Offset(211, 150), const Offset(250, 150), 0xFF68BAB4, 6);
    oval(canvas, const Rect.fromLTWH(227, 150, 9, 10), 0xFFFFD66C);
    canvas.restore();
    if (mood == FriendsMood.happy) {
      for (var i = 0; i < 5; i++) {
        final x = 40.0 + i * 55;
        final y = 15 + math.sin(time * math.pi * 2 + i) * 10;
        drawStar(canvas, Offset(x, y), 7, const Color(0xFFFFC94F));
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_FriendsPainter old) =>
      old.time != time || old.mood != mood;
}

void drawStar(Canvas canvas, Offset center, double radius, Color color) {
  final path = Path();
  for (var i = 0; i < 10; i++) {
    final angle = -math.pi / 2 + i * math.pi / 5;
    final r = i.isEven ? radius : radius * .46;
    final point = center + Offset(math.cos(angle) * r, math.sin(angle) * r);
    if (i == 0) {
      path.moveTo(point.dx, point.dy);
    } else {
      path.lineTo(point.dx, point.dy);
    }
  }
  canvas.drawPath(path..close(), Paint()..color = color);
}

class ForestBackground extends StatelessWidget {
  const ForestBackground({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Stack(
    children: [
      const Positioned.fill(
        child: RepaintBoundary(child: CustomPaint(painter: _ForestPainter())),
      ),
      child,
    ],
  );
}

class _ForestPainter extends CustomPainter {
  const _ForestPainter();
  @override
  void paint(Canvas c, Size s) {
    final p = Paint()..isAntiAlias = true;
    p.shader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFD9F6F1), Color(0xFFF7F4D9), Color(0xFFC9E9B4)],
    ).createShader(Offset.zero & s);
    c.drawRect(Offset.zero & s, p);
    p.shader = null;
    p.color = const Color(0xFFFFE9A2);
    c.drawCircle(Offset(s.width * .83, s.height * .12), 44, p);
    p.color = const Color(0xFFC4E6B1);
    c.drawOval(
      Rect.fromLTWH(
        -s.width * .6,
        s.height * .62,
        s.width * 1.6,
        s.height * .65,
      ),
      p,
    );
    p.color = const Color(0xFFAFD89E);
    c.drawOval(
      Rect.fromLTWH(s.width * .3, s.height * .75, s.width * 1.2, s.height * .6),
      p,
    );
    for (final right in [false, true]) {
      final x = right ? s.width + 12 : -12.0;
      p.color = const Color(0xFFA57D5C);
      c.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - 14, s.height * .17, 28, s.height * .65),
          const Radius.circular(15),
        ),
        p,
      );
      for (var i = 0; i < 4; i++) {
        p.color = i.isEven ? const Color(0xFF74B994) : const Color(0xFF91CCA4);
        c.drawCircle(
          Offset(x + (i.isEven ? -15 : 15), s.height * .14 + i * 44),
          65,
          p,
        );
      }
    }
    for (var i = 0; i < 13; i++) {
      final center = Offset(
        s.width * (i + .5) / 13,
        s.height - 18 - (i % 3) * 15,
      );
      p.color = const Color(0xFF689B69);
      p.strokeWidth = 2;
      c.drawLine(center, center + const Offset(0, 24), p);
      p.color = i.isEven ? const Color(0xFFF2A5C2) : const Color(0xFFB399DC);
      for (var j = 0; j < 5; j++) {
        c.drawCircle(
          center + Offset(math.cos(j * 1.256) * 5, math.sin(j * 1.256) * 5),
          4,
          p,
        );
      }
      p.color = const Color(0xFFFFE799);
      c.drawCircle(center, 3, p);
    }
    for (var i = 0; i < 3; i++) {
      final center = Offset(
        s.width * (.18 + .31 * i),
        s.height * (.19 + .07 * i),
      );
      p.color = i.isEven ? const Color(0xFFB29ADE) : const Color(0xFFFFB1B8);
      c.drawOval(
        Rect.fromCenter(
          center: center - const Offset(5, 0),
          width: 10,
          height: 15,
        ),
        p,
      );
      c.drawOval(
        Rect.fromCenter(
          center: center + const Offset(5, 0),
          width: 10,
          height: 15,
        ),
        p,
      );
      p.color = const Color(0xFF74577F);
      c.drawCircle(center, 2, p);
    }
  }

  @override
  bool shouldRepaint(_ForestPainter old) => false;
}
