import 'dart:math' as math;
import 'package:flutter/material.dart';

enum BuddyMood { idle, thinking, talking, happy }

class BuddyCharacter extends StatefulWidget {
  final BuddyMood mood;
  final double size;

  const BuddyCharacter({super.key, required this.mood, this.size = 180});

  @override
  State<BuddyCharacter> createState() => _BuddyCharacterState();
}

class _BuddyCharacterState extends State<BuddyCharacter>
    with TickerProviderStateMixin {
  late final AnimationController _breathe;
  late final AnimationController _mouth;
  late final AnimationController _bounce;
  bool _eyeOpen = true;

  @override
  void initState() {
    super.initState();

    _breathe = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);

    _mouth = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    )..repeat(reverse: true);

    _bounce = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    )..repeat(reverse: true);

    _runBlinkLoop();
  }

  Future<void> _runBlinkLoop() async {
    while (mounted) {
      await Future.delayed(
          Duration(milliseconds: 2200 + math.Random().nextInt(2800)));
      if (!mounted) return;
      setState(() => _eyeOpen = false);
      await Future.delayed(const Duration(milliseconds: 130));
      if (!mounted) return;
      setState(() => _eyeOpen = true);
    }
  }

  @override
  void dispose() {
    _breathe.dispose();
    _mouth.dispose();
    _bounce.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_breathe, _mouth, _bounce]),
      builder: (context, _) {
        final isHappy = widget.mood == BuddyMood.happy;
        final bobY = isHappy
            ? math.sin(_bounce.value * math.pi) * 7.0
            : math.sin(_breathe.value * math.pi) * 3.5;

        return Transform.translate(
          offset: Offset(0, bobY),
          child: CustomPaint(
            size: Size(widget.size, widget.size * 1.25),
            painter: _BuddyPainter(
              mood: widget.mood,
              eyeOpen: _eyeOpen,
              mouthAnim: _mouth.value,
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _BuddyPainter extends CustomPainter {
  final BuddyMood mood;
  final bool eyeOpen;
  final double mouthAnim;

  const _BuddyPainter({
    required this.mood,
    required this.eyeOpen,
    required this.mouthAnim,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final headR = size.width * 0.37;
    final headCY = size.height * 0.37;

    _drawGroundShadow(canvas, cx, headCY + headR + size.height * 0.25, size);
    _drawBody(canvas, size, cx, headCY + headR * 0.72);
    _drawHead(canvas, cx, headCY, headR);
    _drawAntenna(canvas, cx, headCY, headR);
    _drawEyes(canvas, cx, headCY, headR);
    _drawMouth(canvas, cx, headCY, headR);
    _drawCheeks(canvas, cx, headCY, headR);
    if (mood == BuddyMood.happy) _drawSparkles(canvas, cx, headCY, headR);
  }

  // ── Ground shadow ───────────────────────────────────────────────────────────

  void _drawGroundShadow(Canvas canvas, double cx, double gy, Size size) {
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(cx, gy),
          width: size.width * 0.58,
          height: size.height * 0.06),
      Paint()
        ..color = const Color(0xFF7C3AED).withValues(alpha: 0.13)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );
  }

  // ── Antenna ─────────────────────────────────────────────────────────────────

  void _drawAntenna(Canvas canvas, double cx, double cy, double r) {
    canvas.drawLine(
      Offset(cx, cy - r * 0.93),
      Offset(cx, cy - r * 1.32),
      Paint()
        ..color = const Color(0xFF7C3AED)
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );

    final tipY = cy - r * 1.41;

    // Outer glow
    canvas.drawCircle(
      Offset(cx, tipY),
      12,
      Paint()
        ..color = const Color(0xFFF5A623).withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    // Orb
    canvas.drawCircle(
      Offset(cx, tipY),
      7,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.4),
          colors: const [Color(0xFFFFE08A), Color(0xFFF5A623)],
        ).createShader(Rect.fromCircle(center: Offset(cx, tipY), radius: 7)),
    );

    // Shine
    canvas.drawCircle(Offset(cx - 2, tipY - 2.5), 2.2,
        Paint()..color = Colors.white.withValues(alpha: 0.82));
  }

  // ── Head ────────────────────────────────────────────────────────────────────

  void _drawHead(Canvas canvas, double cx, double cy, double r) {
    // Drop shadow
    canvas.drawCircle(
      Offset(cx + 2, cy + 5),
      r,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );

    // Head — radial gradient for soft 3-D look
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.38, -0.46),
          radius: 1.1,
          colors: const [
            Color(0xFFCBA9FF),
            Color(0xFF9F67F5),
            Color(0xFF7C3AED),
            Color(0xFF5B21B6),
          ],
          stops: const [0.0, 0.32, 0.68, 1.0],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r)),
    );

    // Top-left specular
    canvas.drawCircle(
      Offset(cx - r * 0.38, cy - r * 0.44),
      r * 0.22,
      Paint()..color = Colors.white.withValues(alpha: 0.17),
    );
  }

  // ── Eyes ────────────────────────────────────────────────────────────────────

  void _drawEyes(Canvas canvas, double cx, double cy, double r) {
    final eyeY = cy - r * 0.06;
    final ox = r * 0.34;
    final ew = r * 0.34;
    final eh = eyeOpen ? r * 0.40 : r * 0.05;

    for (final ex in [cx - ox, cx + ox]) {
      // White sclera
      canvas.drawOval(
        Rect.fromCenter(center: Offset(ex, eyeY), width: ew, height: eh),
        Paint()..color = Colors.white,
      );

      if (eyeOpen) {
        // Iris
        canvas.drawOval(
          Rect.fromCenter(
              center: Offset(ex, eyeY), width: ew * 0.68, height: eh * 0.78),
          Paint()..color = const Color(0xFF3B0764),
        );

        // Pupil
        canvas.drawOval(
          Rect.fromCenter(
              center: Offset(ex + 0.8, eyeY + 1),
              width: ew * 0.30,
              height: eh * 0.36),
          Paint()..color = const Color(0xFF0A0318),
        );

        // Primary shine
        canvas.drawCircle(Offset(ex - ew * 0.13, eyeY - eh * 0.17),
            r * 0.050, Paint()..color = Colors.white);

        // Secondary shine
        canvas.drawCircle(Offset(ex + ew * 0.09, eyeY + eh * 0.09),
            r * 0.024,
            Paint()..color = Colors.white.withValues(alpha: 0.55));

        // Eyelash arc
        canvas.drawArc(
          Rect.fromCenter(
              center: Offset(ex, eyeY), width: ew + 4, height: eh + 4),
          math.pi * 1.12,
          math.pi * 0.76,
          false,
          Paint()
            ..color = const Color(0xFF2D0A6B)
            ..strokeWidth = 2.2
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round,
        );
      }
    }

    _drawEyebrows(canvas, cx, eyeY, r, ox, ew, eh);
  }

  void _drawEyebrows(Canvas canvas, double cx, double eyeY, double r,
      double ox, double ew, double eh) {
    final p = Paint()
      ..color = Colors.white.withValues(alpha: 0.88)
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    switch (mood) {
      case BuddyMood.idle:
        for (final ex in [cx - ox, cx + ox]) {
          canvas.drawLine(Offset(ex - ew * 0.38, eyeY - r * 0.36),
              Offset(ex + ew * 0.38, eyeY - r * 0.36), p);
        }
        break;

      case BuddyMood.thinking:
        canvas.drawLine(Offset(cx - ox - ew * 0.38, eyeY - r * 0.36),
            Offset(cx - ox + ew * 0.38, eyeY - r * 0.36), p);
        final arc = Path()
          ..moveTo(cx + ox - ew * 0.40, eyeY - r * 0.40)
          ..quadraticBezierTo(
              cx + ox, eyeY - r * 0.56, cx + ox + ew * 0.40, eyeY - r * 0.46);
        canvas.drawPath(arc, p);
        break;

      case BuddyMood.talking:
      case BuddyMood.happy:
        for (final ex in [cx - ox, cx + ox]) {
          final arc = Path()
            ..moveTo(ex - ew * 0.40, eyeY - r * 0.38)
            ..quadraticBezierTo(
                ex, eyeY - r * 0.54, ex + ew * 0.40, eyeY - r * 0.38);
          canvas.drawPath(arc, p);
        }
        break;
    }
  }

  // ── Mouth ───────────────────────────────────────────────────────────────────

  void _drawMouth(Canvas canvas, double cx, double cy, double r) {
    final my = cy + r * 0.40;
    final sp = Paint()
      ..color = Colors.white.withValues(alpha: 0.94)
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    switch (mood) {
      case BuddyMood.idle:
        canvas.drawPath(
          Path()
            ..moveTo(cx - r * 0.24, my)
            ..quadraticBezierTo(cx, my + r * 0.16, cx + r * 0.24, my),
          sp,
        );
        break;

      case BuddyMood.thinking:
        canvas.drawPath(
          Path()
            ..moveTo(cx - r * 0.05, my + r * 0.04)
            ..quadraticBezierTo(
                cx + r * 0.08, my - r * 0.02, cx + r * 0.24, my),
          sp,
        );
        // Thought dots
        for (int i = 0; i < 3; i++) {
          canvas.drawCircle(
            Offset(cx - r * 0.50 + i * r * 0.18, cy - r * 0.70),
            2.8 - i * 0.4,
            Paint()..color = Colors.white.withValues(alpha: 0.72 - i * 0.18),
          );
        }
        break;

      case BuddyMood.talking:
        final open = r * (0.09 + mouthAnim * 0.20);
        final mp = Path()
          ..moveTo(cx - r * 0.28, my)
          ..quadraticBezierTo(cx, my + open * 2.3, cx + r * 0.28, my)
          ..close();
        canvas.drawPath(mp, Paint()..color = const Color(0xFF3B0764));
        canvas.drawPath(mp, sp);
        break;

      case BuddyMood.happy:
        // Clean wide smile — simple arc, no dark fill or rectangular teeth
        final smilePath = Path()
          ..moveTo(cx - r * 0.32, my)
          ..quadraticBezierTo(cx, my + r * 0.26, cx + r * 0.32, my);
        canvas.drawPath(smilePath, sp..strokeWidth = 3.2);
        break;
    }
  }

  // ── Cheeks ──────────────────────────────────────────────────────────────────

  void _drawCheeks(Canvas canvas, double cx, double cy, double r) {
    final alpha = mood == BuddyMood.happy ? 0.54 : 0.22;
    canvas.drawCircle(
      Offset(cx - r * 0.54, cy + r * 0.26),
      r * 0.20,
      Paint()
        ..color = const Color(0xFFFF8FA3).withValues(alpha: alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9),
    );
    canvas.drawCircle(
      Offset(cx + r * 0.54, cy + r * 0.26),
      r * 0.20,
      Paint()
        ..color = const Color(0xFFFF8FA3).withValues(alpha: alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9),
    );
  }

  // ── Body ────────────────────────────────────────────────────────────────────

  void _drawBody(Canvas canvas, Size size, double cx, double topY) {
    final bw = size.width * 0.52;
    final bh = size.height * 0.30;
    final bcy = topY + bh / 2;
    final rect = Rect.fromCenter(center: Offset(cx, bcy), width: bw, height: bh);
    const rad = Radius.circular(28);

    // Shadow
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(cx + 2, bcy + 5), width: bw, height: bh), rad),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );

    // Fill
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, rad),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: const [Color(0xFFAD7BFF), Color(0xFF7C3AED), Color(0xFF5118B0)],
        ).createShader(rect),
    );

    // Belly circle — hidden on happy so the heart sits cleanly
    if (mood != BuddyMood.happy) {
      canvas.drawCircle(Offset(cx, bcy + bh * 0.06), bh * 0.27,
          Paint()..color = Colors.white.withValues(alpha: 0.14));
    } else {
      _drawHeart(canvas, cx, bcy + bh * 0.06, bh * 0.09);
    }

    _drawArms(canvas, cx, topY, bw, bh);
  }

  void _drawArms(Canvas canvas, double cx, double topY, double bw, double bh) {
    final arm = Paint()
      ..color = const Color(0xFF7C3AED)
      ..strokeWidth = 11
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final raised = mood == BuddyMood.happy;

    for (final side in [-1.0, 1.0]) {
      final sx = cx + side * bw / 2;
      final ex = sx + side * 16;
      final ey = topY + bh * (raised ? 0.05 : 0.28);
      canvas.drawLine(Offset(sx, topY + bh * 0.18), Offset(ex, ey), arm);
      canvas.drawCircle(
        Offset(ex, ey),
        7,
        Paint()
          ..shader = RadialGradient(
            colors: const [Color(0xFFBB8BFF), Color(0xFF7C3AED)],
          ).createShader(Rect.fromCircle(center: Offset(ex, ey), radius: 8)),
      );
    }
  }

  void _drawHeart(Canvas canvas, double cx, double cy, double r) {
    final path = Path()
      ..moveTo(cx, cy + r * 1.1)
      ..cubicTo(cx - r * 2.2, cy - r * 0.8, cx - r * 3.0, cy + r * 0.5, cx, cy + r * 1.1)
      ..cubicTo(cx + r * 3.0, cy + r * 0.5, cx + r * 2.2, cy - r * 0.8, cx, cy + r * 1.1);
    canvas.drawPath(path,
        Paint()..color = const Color(0xFFF5A623).withValues(alpha: 0.85));
  }

  // ── Sparkles (happy) ────────────────────────────────────────────────────────

  void _drawSparkles(Canvas canvas, double cx, double cy, double r) {
    final positions = [
      Offset(cx - r * 0.92, cy - r * 0.48),
      Offset(cx + r * 0.90, cy - r * 0.56),
      Offset(cx - r * 1.08, cy + r * 0.10),
      Offset(cx + r * 1.05, cy + r * 0.10),
    ];
    final sizes = [6.0, 5.0, 4.0, 5.5];
    for (int i = 0; i < positions.length; i++) {
      _drawStar(canvas, positions[i], sizes[i]);
    }
  }

  void _drawStar(Canvas canvas, Offset c, double s) {
    final paint = Paint()..color = const Color(0xFFF5A623);
    final path = Path();
    for (int i = 0; i < 4; i++) {
      final a = i * math.pi / 2 - math.pi / 4;
      final ia = a + math.pi / 4;
      final pt = Offset(c.dx + s * math.cos(a), c.dy + s * math.sin(a));
      final ip = Offset(
          c.dx + s * 0.38 * math.cos(ia), c.dy + s * 0.38 * math.sin(ia));
      i == 0 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
      path.lineTo(ip.dx, ip.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_BuddyPainter old) =>
      old.mood != mood ||
      old.eyeOpen != eyeOpen ||
      old.mouthAnim != mouthAnim;
}
