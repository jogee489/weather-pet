import '../models/weather_data.dart';

/// HTTP client for the Open-Meteo API.
/// Implemented in Phase 2.
///
/// Base URL: https://api.open-meteo.com/v1/forecast
/// No API key required.
class WeatherApi {
  const WeatherApi();

  /// Fetch current conditions + 24-hour hourly + 7-day daily for [lat]/[lon].
  Future<WeatherData> fetchWeather({
    required double lat,
    required double lon,
  }) {
    // TODO Phase 2: implement HTTP call
    throw UnimplementedError('WeatherApi.fetchWeather — implemented in Phase 2');
  }

  /// Search for cities by name using the Open-Meteo geocoding API.
  /// Returns a list of (name, lat, lon) results.
  Future<List<({String name, double lat, double lon})>> searchCity(
      String query) {
    // TODO Phase 6: implement city search
    throw UnimplementedError('WeatherApi.searchCity — implemented in Phase 6');
  }
}
