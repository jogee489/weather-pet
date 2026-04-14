import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_pet/core/models/weather_data.dart';
import 'package:weather_pet/core/providers/weather_provider.dart';
import 'package:weather_pet/features/forecast/forecast_screen.dart';

WeatherData _fakeWeather({
  List<HourlyForecast>? hourly,
  List<DailyForecast>? daily,
}) {
  final now = DateTime.now();
  return WeatherData(
    temperatureC: 20,
    apparentTemperatureC: 18,
    wmoCode: 1,
    windSpeedKmh: 10,
    isDay: true,
    humidity: 60,
    cityName: 'Test City',
    hourly: hourly ??
        List.generate(
          6,
          (i) => HourlyForecast(
            time: now.add(Duration(hours: i)),
            temperatureC: 18.0 + i,
            wmoCode: 0,
          ),
        ),
    daily: daily ??
        List.generate(
          7,
          (i) => DailyForecast(
            date: now.add(Duration(days: i)),
            wmoCode: 1,
            maxTempC: 22.0,
            minTempC: 12.0,
          ),
        ),
  );
}

Widget _wrap(Widget child, {List<Override> overrides = const []}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(home: child),
  );
}

void main() {
  group('ForecastScreen', () {
    testWidgets('shows loading spinner while data is loading', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const ForecastScreen(),
          overrides: [
            weatherProvider.overrideWith(() => _LoadingNotifier()),
          ],
        ),
      );
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error message on failure', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const ForecastScreen(),
          overrides: [
            weatherProvider.overrideWith(() => _ErrorNotifier()),
          ],
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.textContaining('Could not load forecast'), findsOneWidget);
    });

    testWidgets('shows Forecast heading when data loads', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const ForecastScreen(),
          overrides: [
            weatherProvider.overrideWith(() => _DataNotifier(_fakeWeather())),
          ],
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Forecast'), findsOneWidget);
    });

    testWidgets('shows Next 24 hours section label', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const ForecastScreen(),
          overrides: [
            weatherProvider.overrideWith(() => _DataNotifier(_fakeWeather())),
          ],
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Next 24 hours'), findsOneWidget);
    });

    testWidgets('shows Now tile in hourly strip', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const ForecastScreen(),
          overrides: [
            weatherProvider.overrideWith(() => _DataNotifier(_fakeWeather())),
          ],
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Now'), findsOneWidget);
    });

    testWidgets('shows 7-Day Forecast section label', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const ForecastScreen(),
          overrides: [
            weatherProvider.overrideWith(() => _DataNotifier(_fakeWeather())),
          ],
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('7-Day Forecast'), findsOneWidget);
    });

    testWidgets('shows Today label for first daily card', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const ForecastScreen(),
          overrides: [
            weatherProvider.overrideWith(() => _DataNotifier(_fakeWeather())),
          ],
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Today'), findsOneWidget);
    });

    testWidgets('shows correct number of daily cards', (tester) async {
      final weather = _fakeWeather(
        daily: List.generate(
          7,
          (i) => DailyForecast(
            date: DateTime.now().add(Duration(days: i)),
            wmoCode: 0,
            maxTempC: 20,
            minTempC: 10,
          ),
        ),
      );
      await tester.pumpWidget(
        _wrap(
          const ForecastScreen(),
          overrides: [
            weatherProvider.overrideWith(() => _DataNotifier(weather)),
          ],
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      // 7 cards: one "Today" + 6 day-name cards
      expect(find.text('Today'), findsOneWidget);
    });
  });
}

class _LoadingNotifier extends WeatherNotifier {
  @override
  Future<WeatherData> build() => Completer<WeatherData>().future;
}

class _ErrorNotifier extends WeatherNotifier {
  @override
  Future<WeatherData> build() async => throw Exception('Network error');
}

class _DataNotifier extends WeatherNotifier {
  _DataNotifier(this._data);
  final WeatherData _data;

  @override
  Future<WeatherData> build() async => _data;
}
