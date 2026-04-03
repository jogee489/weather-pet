/// Parsed response from the Open-Meteo /v1/forecast endpoint.
class WeatherData {
  const WeatherData({
    required this.temperatureC,
    required this.apparentTemperatureC,
    required this.wmoCode,
    required this.windSpeedKmh,
    required this.isDay,
    required this.humidity,
    required this.cityName,
    required this.hourly,
    required this.daily,
  });

  final double temperatureC;
  final double apparentTemperatureC;
  final int wmoCode;
  final double windSpeedKmh;
  final bool isDay;
  final int humidity;
  final String cityName;
  final List<HourlyForecast> hourly;
  final List<DailyForecast> daily;

  /// Parse from the combined Open-Meteo JSON response.
  /// [cityName] is resolved separately via the geocoding API.
  factory WeatherData.fromJson(
    Map<String, dynamic> json, {
    required String cityName,
  }) {
    final current = json['current'] as Map<String, dynamic>;
    final hourlyJson = json['hourly'] as Map<String, dynamic>;
    final dailyJson = json['daily'] as Map<String, dynamic>;

    // Open-Meteo returns humidity under 'current' when requested.
    // If not present default to 0.
    final humidity =
        (current['relative_humidity_2m'] as num?)?.toInt() ?? 0;

    // Parse hourly (next 24 entries)
    final hourlyTimes = hourlyJson['time'] as List<dynamic>;
    final hourlyTemps = hourlyJson['temperature_2m'] as List<dynamic>;
    final hourlyCodes = hourlyJson['weather_code'] as List<dynamic>;
    final now = DateTime.now();

    final hourly = <HourlyForecast>[];
    for (var i = 0; i < hourlyTimes.length; i++) {
      final time = DateTime.parse(hourlyTimes[i] as String);
      // Only include hours from now forward (up to 24)
      if (time.isAfter(now.subtract(const Duration(hours: 1))) &&
          hourly.length < 24) {
        hourly.add(HourlyForecast(
          time: time,
          temperatureC: (hourlyTemps[i] as num).toDouble(),
          wmoCode: (hourlyCodes[i] as num).toInt(),
        ));
      }
    }

    // Parse daily (7 days)
    final dailyDates = dailyJson['time'] as List<dynamic>;
    final dailyCodes = dailyJson['weather_code'] as List<dynamic>;
    final dailyMaxTemps = dailyJson['temperature_2m_max'] as List<dynamic>;
    final dailyMinTemps = dailyJson['temperature_2m_min'] as List<dynamic>;

    final daily = List.generate(
      dailyDates.length,
      (i) => DailyForecast(
        date: DateTime.parse(dailyDates[i] as String),
        wmoCode: (dailyCodes[i] as num).toInt(),
        maxTempC: (dailyMaxTemps[i] as num).toDouble(),
        minTempC: (dailyMinTemps[i] as num).toDouble(),
      ),
    );

    return WeatherData(
      temperatureC: (current['temperature_2m'] as num).toDouble(),
      apparentTemperatureC:
          (current['apparent_temperature'] as num).toDouble(),
      wmoCode: (current['weather_code'] as num).toInt(),
      windSpeedKmh: (current['wind_speed_10m'] as num).toDouble(),
      isDay: (current['is_day'] as num) == 1,
      humidity: humidity,
      cityName: cityName,
      hourly: hourly,
      daily: daily,
    );
  }
}

class HourlyForecast {
  const HourlyForecast({
    required this.time,
    required this.temperatureC,
    required this.wmoCode,
  });

  final DateTime time;
  final double temperatureC;
  final int wmoCode;
}

class DailyForecast {
  const DailyForecast({
    required this.date,
    required this.wmoCode,
    required this.maxTempC,
    required this.minTempC,
  });

  final DateTime date;
  final int wmoCode;
  final double maxTempC;
  final double minTempC;
}
