import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/models/pet_state.dart';

// ─── Tunable constants ───────────────────────────────────────────────────────

/// How often a lightning flash fires during the [PetState.stormy] effect,
/// in seconds. The flash itself lasts ~250 ms with a fade-out for the
/// thunder feel. Increase this to make storms feel calmer; decrease for
/// a more chaotic storm.
const Duration kLightningPeriod = Duration(seconds: 7);

// ─────────────────────────────────────────────────────────────────────────────

/// Full-bleed animated background layer that reacts to [petState].
class WeatherBackground extends StatefulWidget {
  const WeatherBackground({super.key, required this.petState});

  final PetState petState;

  @override
  State<WeatherBackground> createState() => _WeatherBackgroundState();
}

class _WeatherBackgroundState extends State<WeatherBackground>
    with TickerProviderStateMixin {
  /// Main loop driving most particle motion (4 s).
  late final AnimationController _controller;

  /// Long-period loop driving lightning flashes only.
  late final AnimationController _lightningCtrl;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _lightningCtrl = AnimationController(
      vsync: this,
      duration: kLightningPeriod,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    _lightningCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: Listenable.merge([_controller, _lightningCtrl]),
        builder: (_, __) => CustomPaint(
          painter: _WeatherPainter(
            state: widget.petState,
            t: _controller.value,
            lightningT: _lightningCtrl.value,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

// ─── Painter ─────────────────────────────────────────────────────────────────

class _WeatherPainter extends CustomPainter {
  _WeatherPainter({
    required this.state,
    required this.t,
    required this.lightningT,
  });

  final PetState state;
  final double t;
  final double lightningT;

  @override
  void paint(Canvas canvas, Size size) {
    switch (state) {
      case PetState.sunny:
        _paintSunny(canvas, size);
      case PetState.cloudy:
        _paintCloudy(canvas, size);
      case PetState.rainy:
        _paintRainy(canvas, size);
      case PetState.stormy:
        _paintStormy(canvas, size);
      case PetState.snowy:
        _paintSnowy(canvas, size);
      case PetState.windy:
        _paintWindy(canvas, size);
      case PetState.hot:
        _paintHot(canvas, size);
      case PetState.cold:
        _paintCold(canvas, size);
      case PetState.night:
        _paintNight(canvas, size);
      case PetState.foggy:
        _paintFoggy(canvas, size);
      case PetState.loading:
        break;
    }
  }

  @override
  bool shouldRepaint(_WeatherPainter old) =>
      old.state != state || old.t != t || old.lightningT != lightningT;

  // ─── Sunny: rotating radial rays + soft glow ─────────────────────────────

  void _paintSunny(Canvas canvas, Size size) {
    final cx = size.width * 0.5;
    final cy = size.height * 0.13;
    const rayCount = 10;
    final rotation = t * math.pi * 2;

    final rayPaint = Paint()
      ..color = Colors.white.withOpacity(0.18)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < rayCount; i++) {
      final angle = rotation + (i / rayCount) * math.pi * 2;
      final r1 = size.width * 0.08;
      final r2 = size.width * 0.22;
      canvas.drawLine(
        Offset(cx + math.cos(angle) * r1, cy + math.sin(angle) * r1),
        Offset(cx + math.cos(angle) * r2, cy + math.sin(angle) * r2),
        rayPaint,
      );
    }

    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.white.withOpacity(0.22), Colors.transparent],
      ).createShader(Rect.fromCircle(
        center: Offset(cx, cy),
        radius: size.width * 0.35,
      ));
    canvas.drawCircle(Offset(cx, cy), size.width * 0.35, glowPaint);
  }

  // ─── Cloudy: slow-drifting cloud blobs ───────────────────────────────────

  void _paintCloudy(Canvas canvas, Size size) {
    final cloudPaint = Paint()..color = Colors.white.withOpacity(0.1);
    final clouds = [
      (dx: 0.15, dy: 0.10, speed: 0.18, radius: 0.18),
      (dx: 0.55, dy: 0.22, speed: 0.10, radius: 0.14),
      (dx: 0.30, dy: 0.35, speed: 0.14, radius: 0.20),
      (dx: 0.70, dy: 0.12, speed: 0.08, radius: 0.16),
    ];
    for (final c in clouds) {
      final cx = (c.dx + t * c.speed) % 1.2 * size.width;
      final cy = c.dy * size.height;
      final r = c.radius * size.width;
      _drawCloud(canvas, Offset(cx, cy), r, cloudPaint);
    }
  }

  void _drawCloud(Canvas canvas, Offset center, double r, Paint paint) {
    canvas.drawCircle(center, r, paint);
    canvas.drawCircle(center + Offset(r * 0.7, r * 0.1), r * 0.75, paint);
    canvas.drawCircle(center + Offset(-r * 0.6, r * 0.15), r * 0.65, paint);
    canvas.drawCircle(center + Offset(r * 0.1, r * 0.4), r * 0.8, paint);
  }

  // ─── Rainy: diagonal streaks falling everywhere ──────────────────────────

  void _paintRainy(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.lightBlueAccent.withOpacity(0.30)
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round;

    const count = 80;
    const angle = 20 * math.pi / 180;
    final dx = math.sin(angle);
    final dy = math.cos(angle);
    final len = size.height * 0.05;

    for (var i = 0; i < count; i++) {
      final r = _rng(i, 3);
      final x0 = (-0.1 + r[0] * 1.2) * size.width;
      final y0 = ((t + r[1]) % 1.0) * (size.height + len) - len;
      canvas.drawLine(
        Offset(x0, y0),
        Offset(x0 + dx * len, y0 + dy * len),
        paint,
      );
    }
  }

  // ─── Stormy: heavy rain + sparse lightning flash ─────────────────────────

  void _paintStormy(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blueGrey.withOpacity(0.45)
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    const count = 110;
    const angle = 25 * math.pi / 180;
    final dx = math.sin(angle);
    final dy = math.cos(angle);
    final len = size.height * 0.07;

    for (var i = 0; i < count; i++) {
      final r = _rng(i, 3);
      final x0 = (-0.1 + r[0] * 1.2) * size.width;
      final y0 = ((t * 1.8 + r[1]) % 1.0) * (size.height + len) - len;
      canvas.drawLine(
        Offset(x0, y0),
        Offset(x0 + dx * len, y0 + dy * len),
        paint,
      );
    }

    // Lightning — fires once per kLightningPeriod, ~250 ms long with decay.
    final flash = _lightningIntensity(lightningT);
    if (flash > 0) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = Colors.white.withOpacity(flash * 0.55),
      );
    }
  }

  /// Thunder-like flash curve. Sharp rise, quick decay, faint secondary.
  /// `lt` is in [0, 1) over [kLightningPeriod].
  static double _lightningIntensity(double lt) {
    // Primary flash — first ~3% of the cycle (~210 ms at 7 s period).
    if (lt < 0.03) {
      final p = lt / 0.03;
      // Fast rise (first 15%), then exponential-ish decay
      if (p < 0.15) return p / 0.15;
      return math.pow(1.0 - (p - 0.15) / 0.85, 2.0).toDouble();
    }
    // Secondary flicker right after for thunder feel.
    if (lt > 0.04 && lt < 0.06) {
      final p = (lt - 0.04) / 0.02;
      return (1.0 - p) * 0.45;
    }
    return 0.0;
  }

  // ─── Snowy: drifting snowflakes everywhere ───────────────────────────────

  void _paintSnowy(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.55);

    const count = 70;
    for (var i = 0; i < count; i++) {
      final r = _rng(i, 4);
      final xBase = r[0] * size.width;
      final phase = r[1];
      // Slow fall — full screen over ≈12 s.
      final y = ((t * 0.33 + phase) % 1.0) * (size.height * 1.05);
      // Gentle horizontal sine drift, unique per flake.
      final xDrift = math.sin(t * math.pi * 2 + r[2] * math.pi * 4) * 14;
      final radius = 2.0 + r[3] * 3.5;
      canvas.drawCircle(Offset(xBase + xDrift, y), radius, paint);
    }
  }

  // ─── Windy: swirl arcs + occasional drifting leaves ──────────────────────

  void _paintWindy(Canvas canvas, Size size) {
    // Wind swirl arcs — semi-circular gusts moving left → right.
    final swirlPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const swirlCount = 6;
    for (var i = 0; i < swirlCount; i++) {
      final r = _rng(i + 100, 4);
      final y = (0.1 + r[0] * 0.8) * size.height;
      final speed = 0.25 + r[1] * 0.35;
      final phase = r[2];
      final radius = (0.05 + r[3] * 0.04) * size.width;

      // Position cycles across screen with a wide overshoot for entry/exit.
      final xCenter = ((t * speed + phase) % 1.0) * (size.width + radius * 4) - radius * 2;

      // Each swirl draws two opposing arcs, rotating slowly.
      final rot = t * math.pi * 2 + r[2] * math.pi * 4;
      swirlPaint
        ..color = Colors.white.withOpacity(0.18)
        ..strokeWidth = 1.8;
      _drawArc(canvas, Offset(xCenter, y), radius, rot, math.pi * 1.1, swirlPaint);
      _drawArc(canvas, Offset(xCenter, y), radius * 0.6, rot + math.pi, math.pi * 0.8, swirlPaint);
    }

    // A handful of leaves spinning across the screen.
    const leafCount = 4;
    for (var i = 0; i < leafCount; i++) {
      final r = _rng(i + 200, 4);
      final yBase = (0.15 + r[0] * 0.7) * size.height;
      final speed = 0.15 + r[1] * 0.20;
      final phase = r[2];
      final spin = r[3] * math.pi * 2;

      // Move left → right with a vertical wobble.
      final progress = (t * speed + phase) % 1.0;
      final x = progress * (size.width + 80) - 40;
      final y = yBase + math.sin(progress * math.pi * 4) * 22;
      final rotation = spin + progress * math.pi * 6;

      _drawLeaf(canvas, Offset(x, y), 12.0, rotation,
          Color.lerp(const Color(0xFF8FBC4A), const Color(0xFFD4A256), r[0])!);
    }
  }

  void _drawArc(Canvas canvas, Offset center, double radius, double startAngle,
      double sweep, Paint paint) {
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(rect, startAngle, sweep, false, paint);
  }

  void _drawLeaf(
      Canvas canvas, Offset center, double size, double rotation, Color color) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    final path = Path()
      ..moveTo(0, -size)
      ..quadraticBezierTo(size * 0.7, -size * 0.2, 0, size)
      ..quadraticBezierTo(-size * 0.7, -size * 0.2, 0, -size)
      ..close();
    canvas.drawPath(
      path,
      Paint()..color = color.withOpacity(0.6),
    );
    // Center vein
    canvas.drawLine(
      Offset(0, -size * 0.9),
      Offset(0, size * 0.9),
      Paint()
        ..color = color.withOpacity(0.85)
        ..strokeWidth = 1.0,
    );
    canvas.restore();
  }

  // ─── Hot: prominent wavy heat shimmer rising everywhere ──────────────────

  void _paintHot(Canvas canvas, Size size) {
    // Warm tint overlay so "hot" is felt even before the lines register.
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.deepOrange.withOpacity(0.18),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Many wavy heat columns rising across the full screen.
    const lineCount = 14;
    for (var i = 0; i < lineCount; i++) {
      final r = _rng(i + 50, 4);
      final xBase = (0.04 + r[0] * 0.92) * size.width;
      final phase = r[1];
      final amplitude = 8.0 + r[2] * 12.0;
      final speed = 0.35 + r[3] * 0.4;

      final paint = Paint()
        ..color = Colors.deepOrange.withOpacity(0.32)
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      final path = Path();
      const steps = 36;
      // Each line rises from below and exits above; staggered by phase.
      final cycleProgress = (t * speed + phase) % 1.0;
      final yTop = size.height - cycleProgress * size.height * 1.4;
      final colHeight = size.height * 0.55;

      var started = false;
      for (var s = 0; s <= steps; s++) {
        final p = s / steps;
        final y = yTop + p * colHeight;
        if (y < -10 || y > size.height + 10) continue;
        // Wave gets stronger as it rises (heat distortion grows)
        final wave = math.sin(p * math.pi * 4 + t * math.pi * 6) * amplitude * (0.4 + p * 0.6);
        final x = xBase + wave;
        if (!started) {
          path.moveTo(x, y);
          started = true;
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(path, paint);
    }
  }

  // ─── Cold: frosted-glass vignette + slow ice particles ───────────────────

  void _paintCold(Canvas canvas, Size size) {
    // Frosted glass vignette — white feathered in from the edges.
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: Alignment.center,
          radius: 1.0,
          colors: [
            Colors.transparent,
            Colors.white.withOpacity(0.04),
            Colors.white.withOpacity(0.20),
            Colors.white.withOpacity(0.45),
          ],
          stops: const [0.0, 0.55, 0.85, 1.0],
        ).createShader(rect),
    );

    // Subtle frost dusting in each corner.
    final cornerPaint = Paint()
      ..color = Colors.white.withOpacity(0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    canvas.drawCircle(Offset.zero, size.width * 0.25, cornerPaint);
    canvas.drawCircle(Offset(size.width, 0), size.width * 0.22, cornerPaint);
    canvas.drawCircle(Offset(0, size.height), size.width * 0.22, cornerPaint);
    canvas.drawCircle(Offset(size.width, size.height), size.width * 0.25, cornerPaint);

    // Slow-drifting ice motes for life.
    final particlePaint = Paint()..color = Colors.white.withOpacity(0.55);
    const count = 18;
    for (var i = 0; i < count; i++) {
      final r = _rng(i + 300, 4);
      final xBase = r[0] * size.width;
      final phase = r[1];
      // Drift mostly upward, slow.
      final y = size.height - ((t * 0.25 + phase) % 1.0) * size.height * 1.1;
      final xDrift = math.sin(t * math.pi * 2 + r[2] * math.pi * 4) * 10;
      final radius = 1.6 + r[3] * 2.5;
      if (y >= -10 && y <= size.height + 10) {
        canvas.drawCircle(Offset(xBase + xDrift, y), radius, particlePaint);
      }
    }
  }

  // ─── Night: stars spread across the entire screen ────────────────────────

  void _paintNight(Canvas canvas, Size size) {
    const count = 90;
    for (var i = 0; i < count; i++) {
      final r = _rng(i + 400, 5);
      final x = r[0] * size.width;
      final y = r[1] * size.height; // full screen
      final baseRadius = 0.8 + r[2] * 2.4;
      final freq = 0.6 + r[3] * 2.5;
      final phase = r[4] * math.pi * 2;

      // Brightness twinkles from 0.45 → 1.0.
      final twinkle = 0.45 + 0.55 * (0.5 + 0.5 * math.sin(t * math.pi * 2 * freq + phase));

      // Bright stars (~15%) get a soft halo.
      if (r[2] > 0.85) {
        canvas.drawCircle(
          Offset(x, y),
          baseRadius * 4.5,
          Paint()
            ..color = Colors.white.withOpacity(0.10 * twinkle)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
        );
      }

      canvas.drawCircle(
        Offset(x, y),
        baseRadius,
        Paint()..color = Colors.white.withOpacity(twinkle.clamp(0.0, 1.0)),
      );
    }
  }

  // ─── Foggy: drifting gradient fog bands ──────────────────────────────────

  void _paintFoggy(Canvas canvas, Size size) {
    final bands = [
      (dy: 0.15, speed: 0.04, opacity: 0.12),
      (dy: 0.35, speed: -0.03, opacity: 0.09),
      (dy: 0.55, speed: 0.05, opacity: 0.11),
      (dy: 0.72, speed: -0.02, opacity: 0.08),
    ];
    for (final b in bands) {
      final xShift = math.sin(t * math.pi * 2 * b.speed * 10) * size.width * 0.06;
      final y = b.dy * size.height;
      final bandHeight = size.height * 0.12;
      final paint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.white.withOpacity(0),
            Colors.white.withOpacity(b.opacity),
            Colors.white.withOpacity(b.opacity * 0.6),
            Colors.white.withOpacity(0),
          ],
        ).createShader(Rect.fromLTWH(xShift, y, size.width, bandHeight));
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, bandHeight), paint);
    }
  }

  // ─── Pseudo-random helpers ───────────────────────────────────────────────

  /// Returns `n` independent doubles in [0, 1) for index `i`.
  ///
  /// The previous version called `_lcg(i)` directly with small consecutive
  /// seeds, which the LCG didn't decorrelate well — outputs clustered into
  /// a narrow range and all particles ended up in the same screen quadrant.
  /// We now warm up the hash with several iterations before sampling.
  static List<double> _rng(int i, int n) {
    var h = (i * 1664525 + 1013904223) & 0xFFFFFFFF;
    // Warm-up iterations to decorrelate sequential seeds.
    for (var k = 0; k < 4; k++) {
      h = (h * 1664525 + 1013904223) & 0xFFFFFFFF;
    }
    final out = List<double>.filled(n, 0);
    for (var k = 0; k < n; k++) {
      h = (h * 1664525 + 1013904223) & 0xFFFFFFFF;
      out[k] = h / 0xFFFFFFFF;
    }
    return out;
  }
}
