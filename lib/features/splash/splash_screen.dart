import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/location_provider.dart';
import '../../core/providers/selected_character_provider.dart';
import '../../core/providers/weather_provider.dart';

/// Entry point: loads persisted preferences, requests location permission,
/// and kicks off the initial weather fetch before navigating to HomeScreen.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  String _status = 'Starting up…';
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // Load persisted character selection
    await ref.read(selectedCharacterProvider.notifier).load();

    if (!mounted) return;
    setState(() => _status = 'Getting your location…');

    // Trigger location fetch (fires permission dialog if needed)
    final locationAsync = ref.read(locationProvider);
    if (locationAsync is AsyncError) {
      // Location unavailable — proceed anyway; weatherProvider will error too
      // and HomeScreen will show a retry button.
      _navigate();
      return;
    }

    setState(() => _status = 'Fetching weather…');

    // Wait for the weather fetch to complete (or fail) before proceeding
    try {
      await ref.read(weatherProvider.future);
    } catch (_) {
      // Error shown on HomeScreen — don't block the user here
    }

    _navigate();
  }

  void _navigate() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    // Once weather resolves, navigate immediately (handles fast cache hits)
    ref.listen(weatherProvider, (_, next) {
      if (next is AsyncData || next is AsyncError) _navigate();
    });

    return Scaffold(
      backgroundColor: const Color(0xFF4A90D9),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🐱', style: TextStyle(fontSize: 80)),
            const SizedBox(height: 16),
            const Text(
              'Weather Pet',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _status,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 32),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.white54,
                strokeWidth: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
