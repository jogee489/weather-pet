import 'package:flutter_test/flutter_test.dart';
import 'package:weather_pet/core/models/weather_data.dart';

/// Minimal valid Open-Meteo JSON response for use in tests.
Map<String, dynamic> _makeJson({
  double temperature = 18.5,
  double apparentTemp = 16.0,
  int humidity = 72,
  int wmoCode = 2,
  double windSpeed = 15.0,
  int isDay = 1,
  int hourlyCount = 25,
  int dailyCount = 7,
}) {
  final now = DateTime.now();

  final hourlyTimes = List.generate(
    hourlyCount,
    (i) => now.add(Duration(hours: i)).toIso8601String().substring(0, 16),
  );

  return {
    'current': {
      'temperature_2m': temperature,
      'apparent_temperature': apparentTemp,
      'relative_humidity_2m': humidity,
      'weather_code': wmoCode,
      'wind_speed_10m': windSpeed,
      'is_day': isDay,
    },
    'hourly': {
      'time': hourlyTimes,
      'temperature_2m': List.filled(hourlyCount, 18.0),
      'weather_code': List.filled(hourlyCount, 2),
    },
    'daily': {
      'time': List.generate(
        dailyCount,
        (i) => DateTime.now().add(Duration(days: i)).toIso8601String().substring(0, 10),
      ),
      'weather_code': List.filled(dailyCount, 2),
      'temperature_2m_max': List.filled(dailyCount, 22.0),
      'temperature_2m_min': List.filled(dailyCount, 12.0),
    },
  };
}

void main() {
  group('WeatherData.fromJson', () {
    test('parses temperature correctly', () {
      final data = WeatherData.fromJson(
        _makeJson(temperature: 21.4),
        cityName: 'Test City',
      );
      expect(data.temperatureC, 21.4);
    });

    test('parses apparent temperature correctly', () {
      final data = WeatherData.fromJson(
        _makeJson(apparentTemp: 19.1),
        cityName: 'Test City',
      );
      expect(data.apparentTemperatureC, 19.1);
    });

    test('parses humidity correctly', () {
      final data = WeatherData.fromJson(
        _makeJson(humidity: 85),
        cityName: 'Test City',
      );
      expect(data.humidity, 85);
    });

    test('humidity defaults to 0 when missing from JSON', () {
      final json = _makeJson();
      (json['current'] as Map).remove('relative_humidity_2m');
      final data = WeatherData.fromJson(json, cityName: 'Test City');
      expect(data.humidity, 0);
    });

    test('parses WMO code correctly', () {
      final data = WeatherData.fromJson(
        _makeJson(wmoCode: 95),
        cityName: 'Test City',
      );
      expect(data.wmoCode, 95);
    });

    test('parses wind speed correctly', () {
      final data = WeatherData.fromJson(
        _makeJson(windSpeed: 42.5),
        cityName: 'Test City',
      );
      expect(data.windSpeedKmh, 42.5);
    });

    test('parses is_day = 1 as true', () {
      final data = WeatherData.fromJson(_makeJson(isDay: 1), cityName: 'TC');
      expect(data.isDay, isTrue);
    });

    test('parses is_day = 0 as false', () {
      final data = WeatherData.fromJson(_makeJson(isDay: 0), cityName: 'TC');
      expect(data.isDay, isFalse);
    });

    test('preserves cityName', () {
      final data = WeatherData.fromJson(_makeJson(), cityName: 'London');
      expect(data.cityName, 'London');
    });

    test('hourly list contains at most 24 entries', () {
      final data = WeatherData.fromJson(
        _makeJson(hourlyCount: 48),
        cityName: 'TC',
      );
      expect(data.hourly.length, lessThanOrEqualTo(24));
    });

    test('hourly entries are in chronological order', () {
      final data = WeatherData.fromJson(_makeJson(), cityName: 'TC');
      for (var i = 1; i < data.hourly.length; i++) {
        expect(
          data.hourly[i].time.isAfter(data.hourly[i - 1].time),
          isTrue,
        );
      }
    });

    test('daily list length matches API response', () {
      final data = WeatherData.fromJson(
        _makeJson(dailyCount: 7),
        cityName: 'TC',
      );
      expect(data.daily.length, 7);
    });

    test('daily max temp is parsed correctly', () {
      final data = WeatherData.fromJson(_makeJson(), cityName: 'TC');
      expect(data.daily.first.maxTempC, 22.0);
    });

    test('daily min temp is parsed correctly', () {
      final data = WeatherData.fromJson(_makeJson(), cityName: 'TC');
      expect(data.daily.first.minTempC, 12.0);
    });
  });
}
