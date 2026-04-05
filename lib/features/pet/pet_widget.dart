import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../core/models/pet_character.dart';
import '../../core/models/pet_state.dart';

/// Displays an animated pet character for the given [petState].
///
/// Loads a Lottie JSON from [character.lottiePath]. Falls back to a Flutter
/// animated emoji widget if the asset file is not present — this allows the
/// app to run fully before real Lottie files are produced.
///
/// To add real animations: drop `assets/lottie/<id>/<state>.json` files in
/// and they will be picked up automatically.
class PetWidget extends StatelessWidget {
  const PetWidget({
    super.key,
    required this.character,
    required this.petState,
    this.size = 200,
  });

  final PetCharacter character;
  final PetState petState;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Lottie.asset(
        character.lottiePath(petState),
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _AnimatedCat(
          petState: petState,
          character: character,
          size: size,
        ),
      ),
    );
  }
}

// ─── Animated emoji fallback ──────────────────────────────────────────────────

class _AnimatedCat extends StatefulWidget {
  const _AnimatedCat({
    required this.petState,
    required this.character,
    required this.size,
  });

  final PetState petState;
  final PetCharacter character;
  final double size;

  @override
  State<_AnimatedCat> createState() => _AnimatedCatState();
}

class _AnimatedCatState extends State<_AnimatedCat>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late _AnimConfig _config;

  @override
  void initState() {
    super.initState();
    _config = _AnimConfig.forState(widget.petState);
    _controller = AnimationController(vsync: this, duration: _config.duration);
    _start();
  }

  @override
  void didUpdateWidget(_AnimatedCat old) {
    super.didUpdateWidget(old);
    if (old.petState != widget.petState) {
      _config = _AnimConfig.forState(widget.petState);
      _controller
        ..stop()
        ..duration = _config.duration
        ..reset();
      _start();
    }
  }

  void _start() {
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        final t = _config.curve.transform(_controller.value);
        return Transform(
          alignment: Alignment.center,
          transform: _config.matrixForT(t),
          child: Text(
            _emojiForState(widget.petState, widget.character.emoji),
            style: TextStyle(fontSize: widget.size * 0.46),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }

  static String _emojiForState(PetState state, String fallback) =>
      switch (state) {
        PetState.sunny => '😸',
        PetState.hot => '😹',
        PetState.windy => '😼',
        PetState.rainy => '🙀',
        PetState.stormy => '🙀',
        PetState.snowy => '😿',
        PetState.cold => '😿',
        PetState.night => '😴',
        _ => fallback, // cloudy, foggy, loading → character default emoji
      };
}

// ─── Animation configs ────────────────────────────────────────────────────────

typedef _MatrixFn = Matrix4 Function(double t);

/// Describes one animation loop: duration, matrix transform at time t ∈ [0,1],
/// and easing curve. All animations repeat with auto-reverse.
class _AnimConfig {
  const _AnimConfig({
    required this.duration,
    required this.matrixForT,
    this.curve = Curves.easeInOut,
  });

  final Duration duration;
  final _MatrixFn matrixForT;
  final Curve curve;

  static _AnimConfig forState(PetState state) => switch (state) {
        // Pulse: loading and hot — scale breathe
        PetState.loading => _AnimConfig(
            duration: const Duration(milliseconds: 900),
            matrixForT: (t) => Matrix4.identity()..scale(0.90 + 0.10 * t),
          ),
        PetState.hot => _AnimConfig(
            duration: const Duration(milliseconds: 1400),
            matrixForT: (t) => Matrix4.identity()..scale(1.00 + 0.07 * t),
          ),

        // Gentle float: sunny, snowy, night
        PetState.sunny => _AnimConfig(
            duration: const Duration(milliseconds: 2000),
            matrixForT: (t) => Matrix4.translationValues(0, -14 * t, 0),
          ),
        PetState.snowy => _AnimConfig(
            duration: const Duration(milliseconds: 3500),
            matrixForT: (t) => Matrix4.translationValues(0, -10 * t, 0),
          ),
        PetState.night => _AnimConfig(
            duration: const Duration(milliseconds: 4000),
            matrixForT: (t) => Matrix4.identity()..scale(0.96 + 0.04 * t),
          ),

        // Sway: windy — rotation
        PetState.windy => _AnimConfig(
            duration: const Duration(milliseconds: 1400),
            matrixForT: (t) =>
                Matrix4.rotationZ((t - 0.5) * 0.15), // ±~8.5°
          ),

        // Side-to-side: rainy (gentle), stormy (rapid), cold (shiver)
        PetState.rainy => _AnimConfig(
            duration: const Duration(milliseconds: 1800),
            matrixForT: (t) =>
                Matrix4.translationValues(-8 + 16 * t, 0, 0),
          ),
        PetState.stormy => _AnimConfig(
            duration: const Duration(milliseconds: 90),
            matrixForT: (t) =>
                Matrix4.translationValues(-9 + 18 * t, 0, 0),
            curve: Curves.linear,
          ),
        PetState.cold => _AnimConfig(
            duration: const Duration(milliseconds: 110),
            matrixForT: (t) =>
                Matrix4.translationValues(-5 + 10 * t, 0, 0),
            curve: Curves.linear,
          ),

        // Default float: cloudy, foggy
        _ => _AnimConfig(
            duration: const Duration(milliseconds: 3000),
            matrixForT: (t) => Matrix4.translationValues(
                4 * math.sin(t * math.pi), -8 * t, 0),
          ),
      };
}
