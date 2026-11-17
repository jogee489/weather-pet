import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../core/models/pet_character.dart';
import '../../core/models/pet_state.dart';

/// Animated pet, driven by one Lottie file per character.
///
/// Each file holds three marked segments per [PetState]: `<state>.enter`,
/// `<state>.loop` and `<state>.exit`. When [petState] changes the pet plays
/// the old state's exit, the new state's enter, then loops — so weather
/// changes are acted out rather than cut.
///
/// [intensity] (0–1) says how strong the current weather is. It speeds up
/// the loop and, when windy, widens the ear and whisker flutter.
///
/// Tapping the pet makes it bounce. With the OS "reduce motion" setting on,
/// the pet holds a still pose for the current state instead.
class PetWidget extends StatefulWidget {
  const PetWidget({
    super.key,
    required this.character,
    required this.petState,
    this.size = 200,
    this.intensity = 0.5,
  });

  final PetCharacter character;
  final PetState petState;
  final double size;
  final double intensity;

  @override
  State<PetWidget> createState() => _PetWidgetState();
}

enum _Phase { idle, enter, loop, exit }

/// Fades the wind flutter in and out so it never switches on mid-frame.
@visibleForTesting
class GustEnvelope {
  static const double rampMs = 300;

  double _from = 0;
  double _target = 0;
  double _sinceMs = -rampMs;

  /// Heads for [target] (0 or 1), starting from the level at [nowMs].
  void aim(double target, double nowMs) {
    if (target == _target) return;
    _from = level(nowMs);
    _target = target;
    _sinceMs = nowMs;
  }

  double level(double nowMs) {
    final t = ((nowMs - _sinceMs) / rampMs).clamp(0.0, 1.0);
    return _from + (_target - _from) * t * t * (3 - 2 * t);
  }
}

/// Degrees of flutter to add to a part's rotation. [intensity] is clamped to
/// 0–1; [level] is the [GustEnvelope] fade.
@visibleForTesting
double gustOffset({
  required double degrees,
  required double intensity,
  required double level,
  required double seconds,
  required double phase,
}) =>
    degrees *
    intensity.clamp(0.0, 1.0) *
    level *
    math.sin(seconds * 2 * math.pi * 5 + phase);

class _PetWidgetState extends State<PetWidget> with TickerProviderStateMixin {
  late final AnimationController _frames = AnimationController(vsync: this);
  late final AnimationController _tap = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
  );
  final _random = math.Random();
  final _clock = Stopwatch()..start();

  LottieComposition? _composition;
  bool _failed = false;
  bool _reduceMotion = false;

  /// State whose segments are on screen, which of its segments is playing,
  /// and a token that cancels a running sequence when a newer one starts.
  PetState? _shown;
  _Phase _phase = _Phase.idle;
  int _sequence = 0;
  final _gustEnvelope = GustEnvelope();

  Timer? _blinkTimer;
  double _blinkStartMs = -1e9;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduce = MediaQuery.disableAnimationsOf(context);
    if (reduce != _reduceMotion) {
      _reduceMotion = reduce;
      _restart();
    }
  }

  @override
  void didUpdateWidget(PetWidget old) {
    super.didUpdateWidget(old);
    if (old.character.id != widget.character.id) {
      _composition = null;
      _shown = null;
      _phase = _Phase.idle;
      _sequence++;
      _frames.stop();
      _load();
    } else if (old.petState != widget.petState) {
      _restart();
    }
  }

  @override
  void dispose() {
    _sequence++;
    _blinkTimer?.cancel();
    _frames.dispose();
    _tap.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final id = widget.character.id;
    try {
      final composition = await AssetLottie(widget.character.lottieAsset).load();
      if (!mounted || widget.character.id != id) return;
      setState(() {
        _composition = composition;
        _failed = false;
      });
      _restart();
    } catch (e) {
      debugPrint('Missing pet animation: ${widget.character.lottieAsset} ($e)');
      if (mounted) setState(() => _failed = true);
    }
  }

  // ─── Sequencing ────────────────────────────────────────────────────────────

  Marker? _marker(PetState state, String part) =>
      _composition?.getMarker('${state.name}.$part');

  double get _loopSpeed => 0.8 + 0.6 * widget.intensity.clamp(0.0, 1.0);

  /// Animates from the current frame (or from [from]) to [to], forwards or
  /// backwards. Returns false if a newer sequence took over.
  Future<bool> _run(double to, int token,
      {double speed = 1, double? from}) async {
    final composition = _composition!;
    if (from != null) _frames.value = from;
    final frames = (to - _frames.value).abs() * composition.durationFrames;
    final ms = frames / composition.frameRate * 1000 / speed;
    try {
      await _frames
          .animateTo(to,
              duration: Duration(milliseconds: math.max(1, ms.round())))
          .orCancel;
    } on TickerCanceled {
      return false;
    }
    return mounted && token == _sequence;
  }

  /// Brings the pet to [PetWidget.petState] from wherever it is right now.
  ///
  /// Every route goes through frames that are already on screen or through
  /// the neutral pose shared by all enters and exits, so an interruption at
  /// any point — mid-loop, mid-enter, mid-exit — never cuts.
  Future<void> _restart() async {
    if (_composition == null) return;
    final token = ++_sequence;
    final target = widget.petState;
    final loop = _marker(target, 'loop');
    if (loop == null) return;

    if (_reduceMotion) {
      _blinkTimer?.cancel();
      _frames.stop();
      _frames.value = loop.start;
      _shown = target;
      _phase = _Phase.loop;
      return;
    }
    _scheduleBlink();

    final shown = _shown;
    var atNeutral = shown == null || _phase == _Phase.idle;
    if (shown != null && !atNeutral) {
      final staying = shown == target;
      switch (_phase) {
        case _Phase.loop when staying:
          // Already looping the right state: carry on from this frame.
          if (!await _run(loop.end, token, speed: _loopSpeed)) return;
        case _Phase.loop:
          // Hurry the old loop to its end pose so the exit starts cleanly.
          final oldLoop = _marker(shown, 'loop');
          final exit = _marker(shown, 'exit');
          if (oldLoop != null && !await _run(oldLoop.end, token, speed: 4)) {
            return;
          }
          _phase = _Phase.exit;
          if (exit != null &&
              !await _run(exit.end, token, from: exit.start)) {
            return;
          }
          atNeutral = true;
        case _Phase.enter when staying:
          final enter = _marker(shown, 'enter');
          if (enter != null && !await _run(enter.end, token)) return;
        case _Phase.enter:
          // Back out of the half-played enter to neutral.
          final enter = _marker(shown, 'enter');
          if (enter != null && !await _run(enter.start, token)) return;
          atNeutral = true;
        case _Phase.exit:
          // Let the exit finish; neutral is the quickest way anywhere.
          final exit = _marker(shown, 'exit');
          if (exit != null && !await _run(exit.end, token)) return;
          atNeutral = true;
        case _Phase.idle:
          atNeutral = true;
      }
    }

    if (atNeutral) {
      _shown = target;
      _phase = _Phase.enter;
      final enter = _marker(target, 'enter');
      if (enter != null && !await _run(enter.end, token, from: enter.start)) {
        return;
      }
    }

    _phase = _Phase.loop;
    while (await _run(loop.end, token, speed: _loopSpeed, from: loop.start)) {}
  }

  // ─── Live touches layered on the baked animation ───────────────────────────

  void _scheduleBlink() {
    _blinkTimer?.cancel();
    _blinkTimer = Timer(
      Duration(milliseconds: 2200 + _random.nextInt(4200)),
      () {
        _blinkStartMs = _clock.elapsedMilliseconds.toDouble();
        if (mounted && !_reduceMotion) _scheduleBlink();
      },
    );
  }

  /// 1 when the eyes are open, dipping towards 0 for ~160 ms during a blink.
  double get _eyeOpen {
    final t = (_clock.elapsedMilliseconds - _blinkStartMs) / 160.0;
    if (t < 0 || t > 1) return 1;
    return 1 - 0.92 * math.sin(t * math.pi);
  }

  // lottie 3.1 does not export its frame-info type, so the callbacks below
  // are inline closures that hand the keyframe values to these helpers.

  Offset _blinkScale(Offset? from, Offset? to, double t) {
    final baked = Offset.lerp(from, to, t) ?? const Offset(1, 1);
    return Offset(baked.dx, baked.dy * _eyeOpen);
  }

  /// Extra flutter added on top of the baked rotation when it is windy.
  double _gust(double? from, double? to, double t, double degrees,
      double phase) {
    final baked = lerpDouble(from, to, t) ?? 0;
    final now = _clock.elapsedMilliseconds.toDouble();
    final windy = _shown == PetState.windy && _phase == _Phase.loop;
    _gustEnvelope.aim(windy ? 1 : 0, now);
    return baked +
        gustOffset(
          degrees: degrees,
          intensity: widget.intensity,
          level: _gustEnvelope.level(now),
          seconds: now / 1000.0,
          phase: phase,
        );
  }

  // The live blink targets eye<S>Blink, which holds only the open-eye
  // variants: brows and line-art (closed) eyes sit outside it.
  late final LottieDelegates _delegates = LottieDelegates(values: [
    for (final eye in const ['eyeLBlink', 'eyeRBlink'])
      ValueDelegate.transformScale(
        ['**', eye],
        callback: (i) => _blinkScale(
            i.startValue, i.endValue, i.interpolatedKeyframeProgress),
      ),
    for (final (part, degrees, phase) in const [
      ('earL', 9.0, 0.0),
      ('earR', 9.0, 1.3),
      ('whiskersL', 7.0, 0.6),
      ('whiskersR', 7.0, 2.1),
    ])
      ValueDelegate.transformRotation(
        ['**', part],
        callback: (i) => _gust(i.startValue, i.endValue,
            i.interpolatedKeyframeProgress, degrees, phase),
      ),
  ]);

  void _onTap() {
    if (_reduceMotion) return;
    _tap.forward(from: 0);
  }

  /// Squash, stretch, settle: anchored at the feet.
  Matrix4 _bounce(double t) {
    final wobble = math.sin(t * math.pi * 3) * math.pow(1 - t, 2);
    return Matrix4.diagonal3Values(1 + 0.14 * wobble, 1 - 0.14 * wobble, 1);
  }

  @override
  Widget build(BuildContext context) {
    final composition = _composition;
    final Widget child;
    if (composition != null) {
      child = Lottie(
        composition: composition,
        controller: _frames,
        delegates: _delegates,
        width: widget.size,
        height: widget.size,
        fit: BoxFit.contain,
      );
    } else if (_failed) {
      child = Center(
        child: Text(
          widget.character.emojiForState(widget.petState),
          style: TextStyle(fontSize: widget.size * 0.46),
          textAlign: TextAlign.center,
        ),
      );
    } else {
      child = const SizedBox.shrink();
    }

    return Semantics(
      image: true,
      label: '${widget.character.displayName}, ${widget.petState.name}',
      child: GestureDetector(
        onTap: _onTap,
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: AnimatedBuilder(
            animation: _tap,
            builder: (_, c) => Transform(
              alignment: Alignment.bottomCenter,
              transform: _bounce(_tap.value),
              child: c,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
