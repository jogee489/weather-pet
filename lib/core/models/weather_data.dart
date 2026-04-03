/// Parsed response from the Open-Meteo /v1/forecast endpoint.
/// Populated in Phase 2.
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
