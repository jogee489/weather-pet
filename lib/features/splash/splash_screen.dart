import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/location_provider.dart';
import '../../core/providers/selected_character_provider.dart';
import '../../core/providers/weather_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  bool _hasNavigated = false;

  // Entrance animations
  late final AnimationController _entranceCtrl;
  late final Animation<double> _catScale;
  late final Animation<double> _catOpacity;
  late final Animation<double> _titleOpacity;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _statusOpacity;

  // Idle float loop
  late final AnimationController _floatCtrl;
  late final Animation<double> _floatY;

  @override
  void initState() {
    super.initState();

    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _catScale = CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    );

    _catOpacity = CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
    );

    _titleOpacity = CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.35, 0.75, curve: Curves.easeIn),
    );

    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.35, 0.75, curve: Curves.easeOut),
    ));

    _statusOpacity = CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
    );

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _floatY = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut),
    );

    _entranceCtrl.forward();
    _init();
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _floatCtrl.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    await ref.read(selectedCharacterProvider.notifier).load();
    if (!mounted) return;

    final locationAsync = ref.read(locationProvider);
    if (locationAsync is AsyncError) {
      _navigate();
      return;
    }

    try {
      await ref.read(weatherProvider.future);
    } catch (_) {}

    _navigate();
  }

  void _navigate() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(weatherProvider, (_, next) {
      if (next is AsyncData || next is AsyncError) _navigate();
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF4A90D9), Color(0xFF1A4A8A)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Animated cat ──────────────────────────────────────────
                AnimatedBuilder(
                  animation: Listenable.merge([_entranceCtrl, _floatCtrl]),
                  builder: (_, __) => Transform.translate(
                    offset: Offset(0, _floatY.value),
                    child: Transform.scale(
                      scale: _catScale.value,
                      child: Opacity(
                        opacity: _catOpacity.value,
                        child: _PulsingCat(floatCtrl: _floatCtrl),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // ── App name ──────────────────────────────────────────────
                FadeTransition(
                  opacity: _titleOpacity,
                  child: SlideTransition(
                    position: _titleSlide,
                    child: Column(
                      children: [
                        const Text(
                          'Weather Pet',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Your weather, with personality',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.65),
                            fontSize: 15,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 48),

                // ── Status + spinner ──────────────────────────────────────
                FadeTransition(
                  opacity: _statusOpacity,
                  child: Column(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white.withOpacity(0.5),
                          strokeWidth: 2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Getting your weather…',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.55),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Pulsing cat with glow ────────────────────────────────────────────────────

class _PulsingCat extends StatelessWidget {
  const _PulsingCat({required this.floatCtrl});
  final AnimationController floatCtrl;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: floatCtrl,
      builder: (_, __) {
        final t = (math.sin(floatCtrl.value * math.pi) * 0.5 + 0.5);
        final glowRadius = 20.0 + 10.0 * t;
        return Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.15 + 0.1 * t),
                blurRadius: glowRadius,
                spreadRadius: glowRadius / 2,
              ),
            ],
          ),
          child: const Center(
            child: Text('🐱', style: TextStyle(fontSize: 72)),
          ),
        );
      },
    );
  }
}
