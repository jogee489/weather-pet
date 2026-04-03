import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Entry point that handles location permission and the initial weather fetch.
/// Currently navigates straight to /home — permission + fetch logic added in Phase 2.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _proceed();
  }

  Future<void> _proceed() async {
    // Phase 2: request location permission + await initial weather fetch here.
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF4A90D9),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '🐱',
              style: TextStyle(fontSize: 80),
            ),
            SizedBox(height: 16),
            Text(
              'Weather Pet',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Getting your weather…',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
