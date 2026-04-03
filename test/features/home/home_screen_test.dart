import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_pet/core/models/weather_data.dart';
import 'package:weather_pet/core/providers/weather_provider.dart';
import 'package:weather_pet/features/home/home_screen.dart';

/// A minimal valid [WeatherData] for use in widget tests.
WeatherData _fakeWeather({
  double temp = 18.0,
  String city = 'Test City',
  int wmoCode = 0,
  bool isDay = true,
}) =>
    WeatherData(
      temperatureC: temp,
      apparentTemperatureC: temp - 2,
      wmoCode: wmoCode,
      windSpeedKmh: 10,
      isDay: isDay,
      humidity: 65,
      cityName: city,
      hourly: [],
      daily: [],
    );

/// Wraps [child] in [ProviderScope] with the given [overrides] and
/// a [MaterialApp] so navigation-dependent widgets don't crash.
Widget _wrap(Widget child, {List<Override> overrides = const []}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(home: child),
  );
}

void main() {
  group('HomeScreen', () {
    testWidgets('shows loading spinner while weather is loading',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          const HomeScreen(),
          overrides: [
            // overrideWithValue sets state synchronously — no async race
            weatherProvider.overrideWithValue(const AsyncLoading()),
          ],
        ),
      );

      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.textContaining('°C'), findsNothing);
    });

    testWidgets('shows error message and retry button on failure',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          const HomeScreen(),
          overrides: [
            weatherProvider.overrideWithValue(
              AsyncError(Exception('Network error'), StackTrace.empty),
            ),
          ],
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('Could not fetch weather'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
    });

    testWidgets('shows temperature when data loads', (tester) async {
      final weather = _fakeWeather(temp: 23.0);

      await tester.pumpWidget(
        _wrap(
          const HomeScreen(),
          overrides: [
            weatherProvider.overrideWithValue(AsyncData(weather)),
          ],
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('23°C'), findsOneWidget);
    });

    testWidgets('shows city name when data loads', (tester) async {
      final weather = _fakeWeather(city: 'Paris');

      await tester.pumpWidget(
        _wrap(
          const HomeScreen(),
          overrides: [
            weatherProvider.overrideWithValue(AsyncData(weather)),
          ],
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Paris'), findsOneWidget);
    });

    testWidgets('shows humidity and wind pills when data loads',
        (tester) async {
      final weather = _fakeWeather();

      await tester.pumpWidget(
        _wrap(
          const HomeScreen(),
          overrides: [
            weatherProvider.overrideWithValue(AsyncData(weather)),
          ],
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('%'), findsOneWidget);    // humidity
      expect(find.textContaining('km/h'), findsOneWidget); // wind
    });

    testWidgets('shows daytime greeting when is_day is true', (tester) async {
      final weather = _fakeWeather(isDay: true);

      await tester.pumpWidget(
        _wrap(
          const HomeScreen(),
          overrides: [
            weatherProvider.overrideWithValue(AsyncData(weather)),
          ],
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Good day!'), findsOneWidget);
    });

    testWidgets('shows evening greeting when is_day is false', (tester) async {
      final weather = _fakeWeather(isDay: false);

      await tester.pumpWidget(
        _wrap(
          const HomeScreen(),
          overrides: [
            weatherProvider.overrideWithValue(AsyncData(weather)),
          ],
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Good evening!'), findsOneWidget);
    });
  });
}
