import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/models/pet_character.dart';
import '../../core/models/pet_state.dart';

/// Animated emoji fallback for a pet character.
///
/// Used while Rive assets are loading or when no `.riv` file is present.
/// Drives a simple transform animation (float, sway, shiver, etc.) using
/// [_AnimConfig] — no external asset required.
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
    return _AnimatedCat(
      petState: petState,
      character: character,
      size: size,
    );
  }
}

// ─── Animated emoji ───────────────────────────────────────────────────────────

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

  void _start() => _controller.repeat(reverse: true);

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
            widget.character.emojiForState(widget.petState),
            style: TextStyle(fontSize: widget.size * 0.46),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }
}

// ─── Animation configs ────────────────────────────────────────────────────────

typedef _MatrixFn = Matrix4 Function(double t);

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
        PetState.loading => _AnimConfig(
            duration: const Duration(milliseconds: 900),
            matrixForT: (t) => Matrix4.identity()..scale(0.90 + 0.10 * t),
          ),
        PetState.hot => _AnimConfig(
            duration: const Duration(milliseconds: 1400),
            matrixForT: (t) => Matrix4.identity()..scale(1.00 + 0.07 * t),
          ),
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
        PetState.windy => _AnimConfig(
            duration: const Duration(milliseconds: 1400),
            matrixForT: (t) => Matrix4.rotationZ((t - 0.5) * 0.15),
          ),
        PetState.rainy => _AnimConfig(
            duration: const Duration(milliseconds: 1800),
            matrixForT: (t) => Matrix4.translationValues(-8 + 16 * t, 0, 0),
          ),
        PetState.stormy => _AnimConfig(
            duration: const Duration(milliseconds: 90),
            matrixForT: (t) => Matrix4.translationValues(-9 + 18 * t, 0, 0),
            curve: Curves.linear,
          ),
        PetState.cold => _AnimConfig(
            duration: const Duration(milliseconds: 110),
            matrixForT: (t) => Matrix4.translationValues(-5 + 10 * t, 0, 0),
            curve: Curves.linear,
          ),
        _ => _AnimConfig(
            duration: const Duration(milliseconds: 3000),
            matrixForT: (t) => Matrix4.translationValues(
                4 * math.sin(t * math.pi), -8 * t, 0),
          ),
      };
}
