import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/models/pet_state.dart';

// ─── Tunable constants ───────────────────────────────────────────────────────

/// How often the lightning fires during [PetState.stormy], in seconds.
/// The flash itself lasts ~250 ms. Tune this until the storm feels right.
const Duration kLightningPeriod = Duration(seconds: 7);

// ─────────────────────────────────────────────────────────────────────────────

/// Full-bleed animated background layer that reacts to [petState].
///
/// All particle positions are computed as `((t * N + phase) % 1.0)` where
/// N is always a **positive integer**. This guarantees the scene is identical
/// at t = 0 and t = 1, so the 8-second controller loop is seamless.
class WeatherBackground extends StatefulWidget {
  const WeatherBackground({super.key, required this.petState});

  final PetState petState;

  @override
  State<WeatherBackground> createState() => _WeatherBackgroundState();
}

class _WeatherBackgroundState extends State<WeatherBackground>
    with TickerProviderStateMixin {
  /// Main loop — 8 s period. All particle speeds use integer N so positions
  /// are continuous at the boundary (t = 1 → t = 0).
  late final AnimationController _ctrl;

  /// Separate long-period loop for the storm lightning flash.
  late final AnimationController _lightningCtrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    _lightningCtrl = AnimationController(
      vsync: this,
      duration: kLightningPeriod,
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _lightningCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: Listenable.merge([_ctrl, _lightningCtrl]),
        builder: (_, __) => CustomPaint(
          painter: _WeatherPainter(
            state: widget.petState,
            t: _ctrl.value,
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

  /// Animation progress in [0, 1) over the 8-second main loop.
  final double t;

  /// Animation progress in [0, 1) over [kLightningPeriod].
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

  // ─── Sunny ───────────────────────────────────────────────────────────────

  void _paintSunny(Canvas canvas, Size size) {
    final cx = size.width * 0.5;
    final cy = size.height * 0.13;
    // N=1 → 1 full rotation per 8-s loop. ✓
    final rotation = t * math.pi * 2;

    final rayPaint = Paint()
      ..color = Colors.white.withOpacity(0.18)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    const rayCount = 10;
    for (var i = 0; i < rayCount; i++) {
      final angle = rotation + (i / rayCount) * math.pi * 2;
      canvas.drawLine(
        Offset(cx + math.cos(angle) * size.width * 0.08,
            cy + math.sin(angle) * size.width * 0.08),
        Offset(cx + math.cos(angle) * size.width * 0.22,
            cy + math.sin(angle) * size.width * 0.22),
        rayPaint,
      );
    }

    canvas.drawCircle(
      Offset(cx, cy),
      size.width * 0.35,
      Paint()
        ..shader = RadialGradient(
          colors: [Colors.white.withOpacity(0.22), Colors.transparent],
        ).createShader(Rect.fromCircle(
          center: Offset(cx, cy),
          radius: size.width * 0.35,
        )),
    );
  }

  // ─── Cloudy ──────────────────────────────────────────────────────────────

  void _paintCloudy(Canvas canvas, Size size) {
    // N=1 → each cloud drifts across the full screen in 8 s.
    // Phases spread the 5 clouds evenly so the screen is never empty. ✓
    final cloudPaint = Paint()..color = Colors.white.withOpacity(0.12);
    final clouds = [
      (phase: 0.00, dy: 0.10, radius: 0.18),
      (phase: 0.20, dy: 0.28, radius: 0.14),
      (phase: 0.40, dy: 0.16, radius: 0.20),
      (phase: 0.60, dy: 0.38, radius: 0.16),
      (phase: 0.80, dy: 0.22, radius: 0.15),
    ];
    for (final c in clouds) {
      final xFrac = (t + c.phase) % 1.0; // N=1, integer ✓
      final cx = xFrac * (size.width * 1.4) - size.width * 0.2;
      _drawCloud(canvas, Offset(cx, c.dy * size.height),
          c.radius * size.width, cloudPaint);
    }
  }

  void _drawCloud(Canvas canvas, Offset center, double r, Paint paint) {
    canvas.drawCircle(center, r, paint);
    canvas.drawCircle(center + Offset(r * 0.7, r * 0.1), r * 0.75, paint);
    canvas.drawCircle(center + Offset(-r * 0.6, r * 0.15), r * 0.65, paint);
    canvas.drawCircle(center + Offset(r * 0.1, r * 0.4), r * 0.80, paint);
  }

  // ─── Rainy ───────────────────────────────────────────────────────────────

  void _paintRainy(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.lightBlueAccent.withOpacity(0.30)
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round;

    const count = 80;
    const angle = 20 * math.pi / 180;
    final dx = math.sin(angle);
    final dy = math.cos(angle);
    final len = size.height * 0.055;

    for (var i = 0; i < count; i++) {
      final r = _rng(i, 2);
      final x0 = (-0.1 + r[0] * 1.2) * size.width;
      // N=2 → fall twice per 8-s loop (≈ 4 s per pass). ✓
      final y0 = ((t * 2 + r[1]) % 1.0) * (size.height + len) - len;
      canvas.drawLine(
        Offset(x0, y0),
        Offset(x0 + dx * len, y0 + dy * len),
        paint,
      );
    }
  }

  // ─── Stormy ──────────────────────────────────────────────────────────────

  void _paintStormy(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blueGrey.withOpacity(0.45)
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    const count = 110;
    const angle = 25 * math.pi / 180;
    final dx = math.sin(angle);
    final dy = math.cos(angle);
    final len = size.height * 0.075;

    for (var i = 0; i < count; i++) {
      final r = _rng(i + 1000, 2);
      final x0 = (-0.1 + r[0] * 1.2) * size.width;
      // N=4 → fall 4× per 8-s loop (≈ 2 s per pass, fast storm). ✓
      final y0 = ((t * 4 + r[1]) % 1.0) * (size.height + len) - len;
      canvas.drawLine(
        Offset(x0, y0),
        Offset(x0 + dx * len, y0 + dy * len),
        paint,
      );
    }

    final flash = _lightningIntensity(lightningT);
    if (flash > 0) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = Colors.white.withOpacity(flash * 0.55),
      );
    }
  }

  /// Sharp flash, exponential decay, brief secondary flicker for thunder feel.
  static double _lightningIntensity(double lt) {
    if (lt < 0.03) {
      final p = lt / 0.03;
      return p < 0.15
          ? p / 0.15
          : math.pow(1.0 - (p - 0.15) / 0.85, 2.0).toDouble();
    }
    if (lt > 0.04 && lt < 0.06) {
      return (1.0 - (lt - 0.04) / 0.02) * 0.45;
    }
    return 0.0;
  }

  // ─── Snowy ───────────────────────────────────────────────────────────────

  void _paintSnowy(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.60);

    const count = 70;
    for (var i = 0; i < count; i++) {
      final r = _rng(i + 100, 4);
      final xBase = r[0] * size.width;
      // N=1 → fall once per 8-s loop (slow, floaty). ✓
      final y = ((t + r[1]) % 1.0) * (size.height * 1.05);
      // Horizontal drift — N=1 sin wave completes 1 cycle per 8 s. ✓
      final xDrift = math.sin(t * math.pi * 2 + r[2] * math.pi * 4) * 15;
      canvas.drawCircle(Offset(xBase + xDrift, y), 2.0 + r[3] * 3.5, paint);
    }
  }

  // ─── Windy ───────────────────────────────────────────────────────────────

  void _paintWindy(Canvas canvas, Size size) {
    final swirlPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const swirlCount = 6;
    for (var i = 0; i < swirlCount; i++) {
      final r = _rng(i + 200, 4);
      final y = (0.1 + r[0] * 0.8) * size.height;
      final phase = r[1];
      final radius = (0.05 + r[2] * 0.04) * size.width;

      // N=1 → cross screen in 8 s. ✓
      final xCenter =
          ((t + phase) % 1.0) * (size.width + radius * 4) - radius * 2;
      // N=2 rotation → 2 full spins per 8-s loop. ✓
      final rot = t * math.pi * 2 * 2 + r[3] * math.pi * 4;

      swirlPaint
        ..color = Colors.white.withOpacity(0.20)
        ..strokeWidth = 1.8;
      _drawArc(canvas, Offset(xCenter, y), radius, rot, math.pi * 1.1, swirlPaint);
      _drawArc(canvas, Offset(xCenter, y), radius * 0.6, rot + math.pi,
          math.pi * 0.8, swirlPaint);
    }

    // Leaves: N=1 → cross in 8 s. Position resets off-screen so spin jump
    // at the loop boundary is invisible. ✓
    const leafCount = 4;
    for (var i = 0; i < leafCount; i++) {
      final r = _rng(i + 220, 5);
      final yBase = (0.15 + r[0] * 0.70) * size.height;
      final phase = r[1];

      final progress = (t + phase) % 1.0; // N=1 ✓
      final x = progress * (size.width + 80) - 40;
      // N=2 vertical bob. ✓
      final y = yBase + math.sin(t * math.pi * 2 * 2 + phase * math.pi * 4) * 22;
      final rotation = r[2] * math.pi * 2 + progress * math.pi * 6;

      _drawLeaf(
        canvas,
        Offset(x, y),
        12.0,
        rotation,
        Color.lerp(
            const Color(0xFF8FBC4A), const Color(0xFFD4A256), r[3])!,
      );
    }
  }

  void _drawArc(Canvas canvas, Offset center, double radius,
      double startAngle, double sweep, Paint paint) {
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweep,
      false,
      paint,
    );
  }

  void _drawLeaf(Canvas canvas, Offset center, double leafSize,
      double rotation, Color color) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    final path = Path()
      ..moveTo(0, -leafSize)
      ..quadraticBezierTo(leafSize * 0.7, -leafSize * 0.2, 0, leafSize)
      ..quadraticBezierTo(-leafSize * 0.7, -leafSize * 0.2, 0, -leafSize)
      ..close();
    canvas.drawPath(path, Paint()..color = color.withOpacity(0.65));
    canvas.drawLine(
      Offset(0, -leafSize * 0.9),
      Offset(0, leafSize * 0.9),
      Paint()
        ..color = color.withOpacity(0.90)
        ..strokeWidth = 1.0,
    );
    canvas.restore();
  }

  // ─── Hot ─────────────────────────────────────────────────────────────────

  void _paintHot(Canvas canvas, Size size) {
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

    const lineCount = 14;
    for (var i = 0; i < lineCount; i++) {
      final r = _rng(i + 50, 4);
      final xBase = (0.04 + r[0] * 0.92) * size.width;
      final amplitude = 8.0 + r[2] * 14.0;

      // N=2 → each heat column rises twice per 8-s loop (≈ 4 s per rise). ✓
      final cycleProgress = (t * 2 + r[1]) % 1.0;
      final yTop = size.height * (1.0 - cycleProgress * 1.4);
      final colHeight = size.height * 0.5;

      final paint = Paint()
        ..color = Colors.deepOrange.withOpacity(0.32)
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      final path = Path();
      const steps = 36;
      var started = false;
      for (var s = 0; s <= steps; s++) {
        final p = s / steps;
        final y = yTop + p * colHeight;
        if (y < -10 || y > size.height + 10) continue;
        // N=2 lateral wave. ✓
        final wave = math.sin(p * math.pi * 4 + t * math.pi * 2 * 2) *
            amplitude *
            (0.4 + p * 0.6);
        if (!started) {
          path.moveTo(xBase + wave, y);
          started = true;
        } else {
          path.lineTo(xBase + wave, y);
        }
      }
      canvas.drawPath(path, paint);
    }
  }

  // ─── Cold ────────────────────────────────────────────────────────────────

  void _paintCold(Canvas canvas, Size size) {
    // Frosted-glass vignette — white gradient feathered in from the edges.
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
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
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Frost crystals in each corner — drawn on top of the vignette.
    final frostPaint = Paint()
      ..color = Colors.white.withOpacity(0.28)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    final crystalLen = size.width * 0.16;
    _drawFrostCrystal(canvas, Offset.zero, crystalLen, frostPaint);
    _drawFrostCrystal(canvas, Offset(size.width, 0), crystalLen, frostPaint);
    _drawFrostCrystal(
        canvas, Offset(0, size.height), crystalLen, frostPaint);
    _drawFrostCrystal(
        canvas, Offset(size.width, size.height), crystalLen, frostPaint);

    // Slow-drifting ice motes. N=1 → rise in 8 s. ✓
    const count = 18;
    for (var i = 0; i < count; i++) {
      final r = _rng(i + 300, 4);
      final xBase = r[0] * size.width;
      final y = size.height - ((t + r[1]) % 1.0) * size.height * 1.1;
      // N=1 lateral drift. ✓
      final xDrift =
          math.sin(t * math.pi * 2 + r[2] * math.pi * 4) * 10;
      if (y >= -10 && y <= size.height + 10) {
        canvas.drawCircle(
          Offset(xBase + xDrift, y),
          1.6 + r[3] * 2.5,
          Paint()..color = Colors.white.withOpacity(0.55),
        );
      }
    }
  }

  void _drawFrostCrystal(
      Canvas canvas, Offset origin, double len, Paint paint) {
    const branches = 6;
    for (var i = 0; i < branches; i++) {
      final angle = (i / branches) * math.pi * 2;
      final end = origin +
          Offset(math.cos(angle) * len, math.sin(angle) * len);
      canvas.drawLine(origin, end, paint);
      const twigAngle = math.pi / 6;
      for (final sign in [-1.0, 1.0]) {
        final mid = origin +
            Offset(math.cos(angle) * len * 0.5,
                math.sin(angle) * len * 0.5);
        canvas.drawLine(
          mid,
          mid +
              Offset(
                math.cos(angle + sign * twigAngle) * len * 0.3,
                math.sin(angle + sign * twigAngle) * len * 0.3,
              ),
          paint,
        );
      }
    }
  }

  // ─── Night ───────────────────────────────────────────────────────────────

  void _paintNight(Canvas canvas, Size size) {
    const count = 90;
    for (var i = 0; i < count; i++) {
      final r = _rng(i + 400, 6);
      final x = r[0] * size.width;
      final y = r[1] * size.height;
      final baseRadius = 0.7 + r[2] * 2.5;

      // Three colour temperatures for variety.
      final Color baseColor;
      if (r[3] < 0.22) {
        baseColor = const Color(0xFFFFD09A); // warm amber giant
      } else if (r[3] > 0.78) {
        baseColor = const Color(0xFFB0D4FF); // cool blue-white
      } else {
        baseColor = Colors.white;
      }

      // Integer twinkling frequencies: 1, 2, or 3 cycles per 8-s loop. ✓
      final freqN = 1 + (r[4] * 3).floor(); // → 1, 2, or 3
      final phase = r[5] * math.pi * 2;
      // Wide range 0.0 → 1.0 so bright stars can go fully dark.
      final twinkle =
          (0.5 + 0.5 * math.sin(t * math.pi * 2 * freqN + phase))
              .clamp(0.0, 1.0);

      // ~15% of stars get a soft glow halo for depth.
      if (r[2] > 0.85) {
        canvas.drawCircle(
          Offset(x, y),
          baseRadius * 4.5,
          Paint()..color = baseColor.withOpacity(0.12 * twinkle),
        );
      }

      canvas.drawCircle(
        Offset(x, y),
        baseRadius,
        Paint()..color = baseColor.withOpacity(twinkle),
      );
    }
  }

  // ─── Foggy ───────────────────────────────────────────────────────────────

  void _paintFoggy(Canvas canvas, Size size) {
    // Soft elliptical mist blobs drifting at different heights.
    // Each blob is a radial-gradient circle squashed into an oval via
    // canvas.scale so it looks like a low-hanging fog patch.
    const count = 14;
    for (var i = 0; i < count; i++) {
      final r = _rng(i + 500, 6);
      final yBase = (0.05 + r[0] * 0.90) * size.height;
      final phase = r[1];
      final blobW = (0.45 + r[2] * 0.55) * size.width;
      final blobH = (0.07 + r[3] * 0.11) * size.height;
      final opacity = 0.05 + r[4] * 0.13;

      // Alternate N=1 (slow) and N=2 (faster) for layered parallax. ✓
      final N = (i % 3 == 0) ? 2 : 1;
      final cx = ((t * N + phase) % 1.0) * (size.width + blobW) - blobW * 0.5;
      // N=1 vertical bob. ✓
      final yBob = yBase +
          math.sin(t * math.pi * 2 + r[5] * math.pi * 6) * 18;

      final radius = blobW * 0.5;
      final scaleY = blobH / radius; // squash circle into flat oval

      canvas.save();
      canvas.translate(cx, yBob);
      canvas.scale(1.0, scaleY);
      canvas.drawCircle(
        Offset.zero,
        radius,
        Paint()
          ..shader = RadialGradient(
            colors: [
              Colors.white.withOpacity(opacity),
              Colors.transparent,
            ],
          ).createShader(
              Rect.fromCircle(center: Offset.zero, radius: radius)),
      );
      canvas.restore();
    }
  }

  // ─── Pseudo-random helpers ────────────────────────────────────────────────

  /// Returns `n` independent doubles in [0, 1) for particle index `i`.
  /// The hash is warmed up with 4 LCG iterations before sampling so that
  /// sequential small seeds produce well-distributed outputs across the screen.
  static List<double> _rng(int i, int n) {
    var h = (i * 1664525 + 1013904223) & 0xFFFFFFFF;
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
