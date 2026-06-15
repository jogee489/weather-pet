import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_pet/core/services/location_service.dart';

void main() {
  // No geolocator plugin is registered in the test environment, so every
  // platform call (isLocationServiceEnabled, getCurrentPosition, …) throws.
  // This exercises the web-robustness path: the service must swallow those
  // failures and fall back to the cached location instead of bubbling up.
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocationService.getCurrentLocation', () {
    test('falls back to cached location when geolocation is unavailable',
        () async {
      SharedPreferences.setMockInitialValues({
        'last_lat': 48.85,
        'last_lon': 2.35,
      });

      final result = await const LocationService().getCurrentLocation();

      expect(result.lat, 48.85);
      expect(result.lon, 2.35);
    });

    test('throws LocationServiceException when no cache is available',
        () async {
      SharedPreferences.setMockInitialValues({});

      expect(
        () => const LocationService().getCurrentLocation(),
        throwsA(isA<LocationServiceException>()),
      );
    });

    test('saveLocation persists a location that getCurrentLocation can reuse',
        () async {
      SharedPreferences.setMockInitialValues({});

      await const LocationService().saveLocation((lat: 51.5, lon: -0.12));
      final result = await const LocationService().getCurrentLocation();

      expect(result.lat, 51.5);
      expect(result.lon, -0.12);
    });
  });
}
