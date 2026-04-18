import 'package:flutter_test/flutter_test.dart';
import 'package:weather_pet/core/models/temperature_unit.dart';

void main() {
  group('TemperatureUnit.label', () {
    test('celsius label is °C', () {
      expect(TemperatureUnit.celsius.label, '°C');
    });

    test('fahrenheit label is °F', () {
      expect(TemperatureUnit.fahrenheit.label, '°F');
    });
  });

  group('TemperatureUnit.convert', () {
    test('celsius convert is identity', () {
      expect(TemperatureUnit.celsius.convert(20), 20);
    });

    test('0°C → 32°F', () {
      expect(TemperatureUnit.fahrenheit.convert(0), 32);
    });

    test('100°C → 212°F', () {
      expect(TemperatureUnit.fahrenheit.convert(100), 212);
    });

    test('-40°C → -40°F (crossover point)', () {
      expect(TemperatureUnit.fahrenheit.convert(-40), -40);
    });

    test('37°C → 98.6°F', () {
      expect(TemperatureUnit.fahrenheit.convert(37), closeTo(98.6, 0.01));
    });
  });

  group('TemperatureUnit.format', () {
    test('celsius format appends °C', () {
      expect(TemperatureUnit.celsius.format(20), '20°C');
    });

    test('fahrenheit format converts and appends °F', () {
      expect(TemperatureUnit.fahrenheit.format(0), '32°F');
    });

    test('celsius format rounds down', () {
      expect(TemperatureUnit.celsius.format(20.4), '20°C');
    });

    test('celsius format rounds up', () {
      expect(TemperatureUnit.celsius.format(20.6), '21°C');
    });

    test('fahrenheit format rounds result', () {
      // 37°C = 98.6°F → rounds to 99°F
      expect(TemperatureUnit.fahrenheit.format(37), '99°F');
    });

    test('negative celsius formats correctly', () {
      expect(TemperatureUnit.celsius.format(-5.0), '-5°C');
    });

    test('negative fahrenheit formats correctly', () {
      // -10°C = 14°F
      expect(TemperatureUnit.fahrenheit.format(-10), '14°F');
    });

    test('freezing point formats correctly in both units', () {
      expect(TemperatureUnit.celsius.format(0), '0°C');
      expect(TemperatureUnit.fahrenheit.format(0), '32°F');
    });
  });
}
