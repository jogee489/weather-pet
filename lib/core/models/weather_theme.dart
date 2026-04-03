import 'package:flutter/material.dart';

import 'pet_state.dart';

/// Color theme derived from the current [PetState].
/// Drives the animated gradient background and accent colours across all screens.
class WeatherTheme {
  const WeatherTheme({
    required this.gradientTop,
    required this.gradientBottom,
    required this.cardColor,
    required this.textPrimary,
    required this.accentColor,
  });

  final Color gradientTop;
  final Color gradientBottom;
  final Color cardColor;
  final Color textPrimary;
  final Color accentColor;

  LinearGradient get gradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [gradientTop, gradientBottom],
      );

  /// Returns the [WeatherTheme] for a given [PetState].
  static WeatherTheme forState(PetState state) => switch (state) {
        PetState.sunny => const WeatherTheme(
            gradientTop: Color(0xFFFFD700),
            gradientBottom: Color(0xFFFF8C00),
            cardColor: Color(0x33FFFFFF),
            textPrimary: Colors.white,
            accentColor: Colors.white,
          ),
        PetState.cloudy => const WeatherTheme(
            gradientTop: Color(0xFF8FA8C8),
            gradientBottom: Color(0xFF4A6888),
            cardColor: Color(0x33FFFFFF),
            textPrimary: Colors.white,
            accentColor: Color(0xFFD0E4F7),
          ),
        PetState.rainy => const WeatherTheme(
            gradientTop: Color(0xFF4A5568),
            gradientBottom: Color(0xFF2D3748),
            cardColor: Color(0x33FFFFFF),
            textPrimary: Colors.white,
            accentColor: Color(0xFF63B3ED),
          ),
        PetState.snowy => const WeatherTheme(
            gradientTop: Color(0xFFE8F4FD),
            gradientBottom: Color(0xFFBEE3F8),
            cardColor: Color(0x33FFFFFF),
            textPrimary: Color(0xFF2D3748),
            accentColor: Color(0xFF90CDF4),
          ),
        PetState.stormy => const WeatherTheme(
            gradientTop: Color(0xFF1A202C),
            gradientBottom: Color(0xFF2D3748),
            cardColor: Color(0x33FFFFFF),
            textPrimary: Colors.white,
            accentColor: Color(0xFFECC94B),
          ),
        PetState.windy => const WeatherTheme(
            gradientTop: Color(0xFF718096),
            gradientBottom: Color(0xFF4A5568),
            cardColor: Color(0x33FFFFFF),
            textPrimary: Colors.white,
            accentColor: Color(0xFFE2E8F0),
          ),
        PetState.hot => const WeatherTheme(
            gradientTop: Color(0xFFFF6B35),
            gradientBottom: Color(0xFFF7931E),
            cardColor: Color(0x33FFFFFF),
            textPrimary: Colors.white,
            accentColor: Color(0xFFFEF3C7),
          ),
        PetState.cold => const WeatherTheme(
            gradientTop: Color(0xFF2C5282),
            gradientBottom: Color(0xFF2B4C7E),
            cardColor: Color(0x33FFFFFF),
            textPrimary: Colors.white,
            accentColor: Color(0xFFEBF8FF),
          ),
        PetState.night => const WeatherTheme(
            gradientTop: Color(0xFF1A1A2E),
            gradientBottom: Color(0xFF16213E),
            cardColor: Color(0x33FFFFFF),
            textPrimary: Colors.white,
            accentColor: Color(0xFFECC94B),
          ),
        PetState.foggy => const WeatherTheme(
            gradientTop: Color(0xFF718096),
            gradientBottom: Color(0xFF4A5568),
            cardColor: Color(0x33FFFFFF),
            textPrimary: Colors.white,
            accentColor: Color(0xFFF7FAFC),
          ),
        PetState.loading => const WeatherTheme(
            gradientTop: Color(0xFF4A90D9),
            gradientBottom: Color(0xFF2C6FAC),
            cardColor: Color(0x33FFFFFF),
            textPrimary: Colors.white,
            accentColor: Colors.white,
          ),
      };
}
