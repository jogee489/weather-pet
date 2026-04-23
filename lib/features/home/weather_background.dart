import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/models/pet_state.dart';

/// Full-bleed animated background layer that reacts to [petState].
///
/// Renders weather-specific particle/effect paintings behind the pet.
/// The widget is completely pet-agnostic — it knows nothing about characters.
/// Drop it into a [Stack] behind the rest of the UI.
class WeatherBackground extends StatefulWidget {
  const WeatherBackground({super.key, required this.petState});

  final PetState petState;

  @override
  State<WeatherBackground> createState() => _WeatherBackgroundState();
}

class _WeatherBackgroundState extends State<WeatherBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) => CustomPaint(
          painter: _WeatherPainter(
            state: widget.petState,
            t: _controller.value,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

// ─── Painter ─────────────────────────────────────────────────────────────────

class _WeatherPainter extends CustomPainter {
  _WeatherPainter({required this.state, required this.t});

  final PetState state;

  /// Animation progress [0, 1), repeating.
  final double t;

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
      old.state != state || old.t != t;

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

    // Soft radial glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withOpacity(0.22),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(cx, cy),
        radius: size.width * 0.35,
      ));
    canvas.drawCircle(Offset(cx, cy), size.width * 0.35, glowPaint);
  }

  // ─── Cloudy: slow-drifting cloud blobs ───────────────────────────────────

  void _paintCloudy(Canvas canvas, Size size) {
    final cloudPaint = Paint()..color = Colors.white.withOpacity(0.1);

    // 4 clouds at different heights and horizontal offsets
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

  // ─── Rainy: diagonal streaks falling ─────────────────────────────────────

  void _paintRainy(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.lightBlueAccent.withOpacity(0.25)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    const count = 45;
    const angle = 20 * math.pi / 180; // 20° lean
    final dx = math.sin(angle);
    final dy = math.cos(angle);
    final len = size.height * 0.05;

    for (var i = 0; i < count; i++) {
      final seed = _lcg(i + 1);
      final x0 = _rnd(seed, -0.1, 1.1) * size.width;
      // Phase offset per drop so they fall at different times
      final phase = _rnd(_lcg(seed), 0.0, 1.0);
      final y0 = ((t + phase) % 1.0) * (size.height + len) - len;
      canvas.drawLine(
        Offset(x0, y0),
        Offset(x0 + dx * len, y0 + dy * len),
        paint,
      );
    }
  }

  // ─── Stormy: heavy rain + lightning flash ────────────────────────────────

  void _paintStormy(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blueGrey.withOpacity(0.40)
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    const count = 70;
    const angle = 25 * math.pi / 180;
    final dx = math.sin(angle);
    final dy = math.cos(angle);
    final len = size.height * 0.07;

    for (var i = 0; i < count; i++) {
      final seed = _lcg(i + 1);
      final x0 = _rnd(seed, -0.1, 1.1) * size.width;
      final phase = _rnd(_lcg(seed), 0.0, 1.0);
      // Stormy drops fall faster (t * 1.8 effective speed)
      final y0 = ((t * 1.8 + phase) % 1.0) * (size.height + len) - len;
      canvas.drawLine(
        Offset(x0, y0),
        Offset(x0 + dx * len, y0 + dy * len),
        paint,
      );
    }

    // Lightning — fires briefly when sin peak is very narrow
    final lightning = math.sin(t * math.pi * 23);
    if (lightning > 0.93) {
      final flashPaint = Paint()
        ..color = Colors.white.withOpacity((lightning - 0.93) / 0.07 * 0.35);
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        flashPaint,
      );
    }
  }

  // ─── Snowy: drifting snowflakes ───────────────────────────────────────────

  void _paintSnowy(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.55);

    const count = 40;
    for (var i = 0; i < count; i++) {
      final seed = _lcg(i + 1);
      final xBase = _rnd(seed, 0.0, 1.0) * size.width;
      final phase = _rnd(_lcg(seed), 0.0, 1.0);
      // Slow fall — full screen in 3× the base duration (≈12 s per flake)
      final y = ((t * 0.33 + phase) % 1.0) * (size.height * 1.05);
      // Gentle horizontal sine drift
      final xDrift = math.sin(t * math.pi * 2 + phase * math.pi * 4) * 12;
      final r = _rnd(_lcg(_lcg(seed)), 2.0, 5.5);
      canvas.drawCircle(Offset(xBase + xDrift, y), r, paint);
    }
  }

  // ─── Windy: horizontal speed streaks ─────────────────────────────────────

  void _paintWindy(Canvas canvas, Size size) {
    const count = 20;
    for (var i = 0; i < count; i++) {
      final seed = _lcg(i + 1);
      final y = _rnd(seed, 0.0, 1.0) * size.height;
      final speed = _rnd(_lcg(seed), 0.3, 0.8);
      final length = _rnd(_lcg(_lcg(seed)), 0.10, 0.25) * size.width;
      final opacity = _rnd(_lcg(_lcg(_lcg(seed))), 0.08, 0.22);
      final phase = _rnd(_lcg(_lcg(_lcg(_lcg(seed)))), 0.0, 1.0);

      final x = ((t * speed + phase) % 1.0) * (size.width + length) - length;

      final paint = Paint()
        ..color = Colors.white.withOpacity(opacity)
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(Offset(x, y), Offset(x + length, y), paint);
    }
  }

  // ─── Hot: wavy rising heat lines ─────────────────────────────────────────

  void _paintHot(Canvas canvas, Size size) {
    const lineCount = 7;
    for (var i = 0; i < lineCount; i++) {
      final seed = _lcg(i + 1);
      final xBase = _rnd(seed, 0.05, 0.95) * size.width;
      final phase = _rnd(_lcg(seed), 0.0, 1.0);
      final amplitude = _rnd(_lcg(_lcg(seed)), 6.0, 14.0);

      final paint = Paint()
        ..color = Colors.orange.withOpacity(0.15)
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      final path = Path();
      const steps = 30;
      // Lines rise from bottom; offset by phase so they stagger
      final yOffset = ((1.0 - t + phase) % 1.0) * size.height;

      for (var s = 0; s <= steps; s++) {
        final progress = s / steps;
        final y = yOffset - progress * size.height * 0.5;
        if (y < 0 || y > size.height) continue;
        final x = xBase + math.sin(progress * math.pi * 4 + t * math.pi * 2) * amplitude;
        if (s == 0 || y == yOffset) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(path, paint);
    }
  }

  // ─── Cold: frost crystals at corners + ice particles ─────────────────────

  void _paintCold(Canvas canvas, Size size) {
    final frostPaint = Paint()
      ..color = Colors.white.withOpacity(0.20)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Frost crystal branches from 4 corners
    final corners = [
      const Offset(0, 0),
      Offset(size.width, 0),
      Offset(0, size.height),
      Offset(size.width, size.height),
    ];
    for (final corner in corners) {
      _drawFrostCrystal(canvas, corner, size.width * 0.15, frostPaint);
    }

    // Slow-rising ice particles
    final particlePaint = Paint()..color = Colors.lightBlue.withOpacity(0.30);
    const count = 12;
    for (var i = 0; i < count; i++) {
      final seed = _lcg(i + 7);
      final x = _rnd(seed, 0.05, 0.95) * size.width;
      final phase = _rnd(_lcg(seed), 0.0, 1.0);
      // Rise from bottom, loop
      final y = size.height - ((t * 0.25 + phase) % 1.0) * size.height * 1.1;
      final r = _rnd(_lcg(_lcg(seed)), 2.0, 4.5);
      if (y >= 0 && y <= size.height) {
        canvas.drawCircle(Offset(x, y), r, particlePaint);
      }
    }
  }

  void _drawFrostCrystal(Canvas canvas, Offset origin, double len, Paint paint) {
    const branches = 6;
    for (var i = 0; i < branches; i++) {
      final angle = (i / branches) * math.pi * 2;
      final end = origin + Offset(math.cos(angle) * len, math.sin(angle) * len);
      canvas.drawLine(origin, end, paint);
      // Side twigs
      const twigAngle = math.pi / 6;
      for (final sign in [-1, 1]) {
        final mid = origin + Offset(
          math.cos(angle) * len * 0.5,
          math.sin(angle) * len * 0.5,
        );
        final twigEnd = mid + Offset(
          math.cos(angle + sign * twigAngle) * len * 0.3,
          math.sin(angle + sign * twigAngle) * len * 0.3,
        );
        canvas.drawLine(mid, twigEnd, paint);
      }
    }
  }

  // ─── Night: twinkling stars ───────────────────────────────────────────────

  void _paintNight(Canvas canvas, Size size) {
    const count = 60;
    for (var i = 0; i < count; i++) {
      final seed = _lcg(i + 1);
      final x = _rnd(seed, 0.0, 1.0) * size.width;
      final y = _rnd(_lcg(seed), 0.0, 0.75) * size.height;
      final r = _rnd(_lcg(_lcg(seed)), 0.8, 2.2);
      // Each star twinkles at its own frequency
      final freq = _rnd(_lcg(_lcg(_lcg(seed))), 1.0, 3.5);
      final phase = _rnd(_lcg(_lcg(_lcg(_lcg(seed)))), 0.0, math.pi * 2);
      final opacity = (0.3 + 0.55 * (0.5 + 0.5 * math.sin(t * math.pi * 2 * freq + phase)))
          .clamp(0.0, 1.0);

      canvas.drawCircle(
        Offset(x, y),
        r,
        Paint()..color = Colors.white.withOpacity(opacity),
      );
    }
  }

  // ─── Foggy: drifting gradient fog bands ──────────────────────────────────

  void _paintFoggy(Canvas canvas, Size size) {
    final bands = [
      (dy: 0.15, speed: 0.04,  opacity: 0.12),
      (dy: 0.35, speed: -0.03, opacity: 0.09),
      (dy: 0.55, speed: 0.05,  opacity: 0.11),
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

      canvas.drawRect(
        Rect.fromLTWH(0, y, size.width, bandHeight),
        paint,
      );
    }
  }

  // ─── Pseudo-random helpers ────────────────────────────────────────────────

  /// Linear congruential generator — deterministic, no mutable state.
  static int _lcg(int seed) =>
      (seed * 1664525 + 1013904223) & 0xFFFFFFFF;

  /// Map an LCG seed to a double in [min, max].
  static double _rnd(int seed, double min, double max) =>
      min + (seed / 0xFFFFFFFF) * (max - min);
}
