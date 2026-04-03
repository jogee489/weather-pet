import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_pet/core/models/pet_state.dart';
import 'package:weather_pet/core/models/weather_theme.dart';

void main() {
  group('WeatherTheme.forState', () {
    test('every PetState has a theme (no missing cases)', () {
      for (final state in PetState.values) {
        expect(
          () => WeatherTheme.forState(state),
          returnsNormally,
          reason: 'PetState.$state should have a corresponding WeatherTheme',
        );
      }
    });

    test('sunny theme has warm gradient top color', () {
      final theme = WeatherTheme.forState(PetState.sunny);
      // Sunny should be warm (high red channel)
      final topColor = theme.gradientTop;
      expect(topColor.red, greaterThan(200));
    });

    test('night theme has dark gradient', () {
      final theme = WeatherTheme.forState(PetState.night);
      // Night should be dark (all channels low)
      final topColor = theme.gradientTop;
      final brightness =
          (topColor.red + topColor.green + topColor.blue) / 3;
      expect(brightness, lessThan(60));
    });

    test('snowy theme has light gradient top (near white)', () {
      final theme = WeatherTheme.forState(PetState.snowy);
      final topColor = theme.gradientTop;
      final brightness =
          (topColor.red + topColor.green + topColor.blue) / 3;
      expect(brightness, greaterThan(180));
    });

    test('gradient has two distinct colors', () {
      for (final state in PetState.values) {
        final theme = WeatherTheme.forState(state);
        expect(
          theme.gradientTop != theme.gradientBottom,
          isTrue,
          reason: 'PetState.$state gradient top and bottom should differ',
        );
      }
    });

    test('gradient method returns a LinearGradient with 2 colors', () {
      final theme = WeatherTheme.forState(PetState.rainy);
      final gradient = theme.gradient;
      expect(gradient, isA<LinearGradient>());
      expect(gradient.colors.length, 2);
    });
  });
}
