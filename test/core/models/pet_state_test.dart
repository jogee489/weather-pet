import 'package:flutter_test/flutter_test.dart';
import 'package:weather_pet/core/models/pet_state.dart';

void main() {
  group('PetState.fromWeather', () {
    // ─── Night overrides everything ───────────────────────────────────────
    test('returns night when is_day is false, regardless of WMO code', () {
      expect(
        PetState.fromWeather(
          wmoCode: 0,
          windSpeedKmh: 0,
          apparentTempC: 20,
          isDay: false,
        ),
        PetState.night,
      );
    });

    test('returns night even with extreme heat at night', () {
      expect(
        PetState.fromWeather(
          wmoCode: 0,
          windSpeedKmh: 0,
          apparentTempC: 40,
          isDay: false,
        ),
        PetState.night,
      );
    });

    // ─── Extreme temperature overrides ────────────────────────────────────
    test('returns hot when apparent temp >= 35°C during day', () {
      expect(
        PetState.fromWeather(
          wmoCode: 0,
          windSpeedKmh: 0,
          apparentTempC: 35,
          isDay: true,
        ),
        PetState.hot,
      );
    });

    test('returns cold when apparent temp < 0°C during day', () {
      expect(
        PetState.fromWeather(
          wmoCode: 0,
          windSpeedKmh: 0,
          apparentTempC: -1,
          isDay: true,
        ),
        PetState.cold,
      );
    });

    // ─── Wind override ────────────────────────────────────────────────────
    test('returns windy when wind > 40 km/h with mild condition', () {
      expect(
        PetState.fromWeather(
          wmoCode: 1,
          windSpeedKmh: 41,
          apparentTempC: 18,
          isDay: true,
        ),
        PetState.windy,
      );
    });

    test('returns windy when wind is exactly 40 km/h (boundary)', () {
      expect(
        PetState.fromWeather(
          wmoCode: 1,
          windSpeedKmh: 40,
          apparentTempC: 18,
          isDay: true,
        ),
        PetState.windy,
      );
    });

    // ─── WMO code mapping ─────────────────────────────────────────────────
    test('WMO 0 → sunny', () {
      expect(
        PetState.fromWeather(
            wmoCode: 0, windSpeedKmh: 5, apparentTempC: 20, isDay: true),
        PetState.sunny,
      );
    });

    test('WMO 1, 2, 3 → cloudy', () {
      for (final code in [1, 2, 3]) {
        expect(
          PetState.fromWeather(
              wmoCode: code, windSpeedKmh: 5, apparentTempC: 20, isDay: true),
          PetState.cloudy,
          reason: 'WMO $code should map to cloudy',
        );
      }
    });

    test('WMO 45, 48 → foggy', () {
      for (final code in [45, 48]) {
        expect(
          PetState.fromWeather(
              wmoCode: code, windSpeedKmh: 5, apparentTempC: 20, isDay: true),
          PetState.foggy,
          reason: 'WMO $code should map to foggy',
        );
      }
    });

    test('WMO 51–67 → rainy', () {
      for (final code in [51, 53, 55, 61, 63, 65, 67]) {
        expect(
          PetState.fromWeather(
              wmoCode: code, windSpeedKmh: 5, apparentTempC: 20, isDay: true),
          PetState.rainy,
          reason: 'WMO $code should map to rainy',
        );
      }
    });

    test('WMO 71–77 → snowy', () {
      for (final code in [71, 73, 75, 77]) {
        expect(
          PetState.fromWeather(
              wmoCode: code, windSpeedKmh: 5, apparentTempC: 5, isDay: true),
          PetState.snowy,
          reason: 'WMO $code should map to snowy',
        );
      }
    });

    test('WMO 80–82 → rainy', () {
      for (final code in [80, 81, 82]) {
        expect(
          PetState.fromWeather(
              wmoCode: code, windSpeedKmh: 5, apparentTempC: 20, isDay: true),
          PetState.rainy,
          reason: 'WMO $code should map to rainy',
        );
      }
    });

    test('WMO 85, 86 → snowy', () {
      for (final code in [85, 86]) {
        expect(
          PetState.fromWeather(
              wmoCode: code, windSpeedKmh: 5, apparentTempC: 5, isDay: true),
          PetState.snowy,
          reason: 'WMO $code should map to snowy',
        );
      }
    });

    test('WMO 95–99 → stormy', () {
      for (final code in [95, 96, 99]) {
        expect(
          PetState.fromWeather(
              wmoCode: code, windSpeedKmh: 5, apparentTempC: 20, isDay: true),
          PetState.stormy,
          reason: 'WMO $code should map to stormy',
        );
      }
    });

    test('Unknown WMO code → cloudy (default fallback)', () {
      expect(
        PetState.fromWeather(
            wmoCode: 999, windSpeedKmh: 5, apparentTempC: 20, isDay: true),
        PetState.cloudy,
      );
    });

    // ─── Priority order ───────────────────────────────────────────────────
    test('hot takes priority over windy', () {
      expect(
        PetState.fromWeather(
          wmoCode: 0,
          windSpeedKmh: 60,
          apparentTempC: 38,
          isDay: true,
        ),
        PetState.hot,
      );
    });

    test('cold takes priority over windy', () {
      expect(
        PetState.fromWeather(
          wmoCode: 0,
          windSpeedKmh: 60,
          apparentTempC: -5,
          isDay: true,
        ),
        PetState.cold,
      );
    });
  });

  group('PetState.displayName', () {
    test('every state has a non-empty display name', () {
      for (final state in PetState.values) {
        expect(state.displayName, isNotEmpty,
            reason: '$state.displayName should not be empty');
      }
    });
  });

  group('PetState.intensityFor', () {
    double at(PetState s, {int wmo = 0, double wind = 10, double temp = 15}) =>
        PetState.intensityFor(s,
            wmoCode: wmo, windSpeedKmh: wind, apparentTempC: temp);

    test('stronger wind gives a higher windy intensity', () {
      expect(at(PetState.windy, wind: 40), 0.0);
      expect(at(PetState.windy, wind: 60), closeTo(0.5, 1e-9));
      expect(at(PetState.windy, wind: 120), 1.0);
    });

    test('hotter and colder both scale and clamp', () {
      expect(at(PetState.hot, temp: 35), 0.0);
      expect(at(PetState.hot, temp: 40), closeTo(0.5, 1e-9));
      expect(at(PetState.hot, temp: 60), 1.0);
      expect(at(PetState.cold, temp: -7.5), closeTo(0.5, 1e-9));
      expect(at(PetState.cold, temp: -40), 1.0);
    });

    test('precipitation follows the WMO light / moderate / heavy tiers', () {
      expect(at(PetState.rainy, wmo: 61), lessThan(at(PetState.rainy, wmo: 63)));
      expect(at(PetState.rainy, wmo: 63), lessThan(at(PetState.rainy, wmo: 65)));
      expect(at(PetState.snowy, wmo: 71), lessThan(at(PetState.snowy, wmo: 75)));
      expect(at(PetState.stormy, wmo: 95), lessThan(at(PetState.stormy, wmo: 99)));
    });

    test('states without a scale sit in the middle', () {
      for (final s in [PetState.sunny, PetState.night, PetState.loading]) {
        expect(at(s), 0.5);
      }
    });
  });
}
