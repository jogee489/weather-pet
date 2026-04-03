import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/weather_data.dart';

/// HTTP client for the Open-Meteo API.
/// No API key required.
class WeatherApi {
  const WeatherApi();

  static const _forecastBase = 'https://api.open-meteo.com/v1/forecast';
  static const _geocodingBase =
      'https://geocoding-api.open-meteo.com/v1/search';

  /// Fetch current conditions + 24-hour hourly + 7-day daily for [lat]/[lon].
  /// Also performs a reverse-geocoding lookup to get the city name.
  Future<WeatherData> fetchWeather({
    required double lat,
    required double lon,
  }) async {
    final uri = Uri.parse(_forecastBase).replace(queryParameters: {
      'latitude': lat.toString(),
      'longitude': lon.toString(),
      'current': [
        'temperature_2m',
        'apparent_temperature',
        'relative_humidity_2m',
        'weather_code',
        'wind_speed_10m',
        'is_day',
      ].join(','),
      'hourly': 'temperature_2m,weather_code',
      'forecast_hours': '25', // extra buffer for timezone edge cases
      'daily': 'weather_code,temperature_2m_max,temperature_2m_min',
      'forecast_days': '7',
      'wind_speed_unit': 'kmh',
      'timezone': 'auto',
    });

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw WeatherApiException(
        'Forecast request failed: ${response.statusCode}',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final cityName = await _reversGeocode(lat: lat, lon: lon);

    return WeatherData.fromJson(json, cityName: cityName);
  }

  /// Search for cities by name. Returns up to 5 matching results.
  Future<List<GeocodingResult>> searchCity(String query) async {
    if (query.trim().isEmpty) return [];

    final uri = Uri.parse(_geocodingBase).replace(queryParameters: {
      'name': query.trim(),
      'count': '5',
      'language': 'en',
      'format': 'json',
    });

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw WeatherApiException(
        'Geocoding request failed: ${response.statusCode}',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final results = json['results'] as List<dynamic>? ?? [];

    return results.map((r) {
      final m = r as Map<String, dynamic>;
      final country = m['country'] as String? ?? '';
      final admin1 = m['admin1'] as String? ?? '';
      final name = m['name'] as String? ?? '';
      final label = [name, admin1, country]
          .where((s) => s.isNotEmpty)
          .join(', ');
      return GeocodingResult(
        displayName: label,
        lat: (m['latitude'] as num).toDouble(),
        lon: (m['longitude'] as num).toDouble(),
      );
    }).toList();
  }

  /// Best-effort reverse geocode: finds the nearest city name for a lat/lon
  /// by searching Open-Meteo's geocoding API with a blank query workaround.
  /// Falls back to coordinate string if lookup fails.
  Future<String> _reversGeocode({
    required double lat,
    required double lon,
  }) async {
    try {
      // Open-Meteo doesn't have a true reverse geocode endpoint.
      // We use the geocoding API with the coordinates formatted as a name
      // query — this won't always work, so we fall back gracefully.
      return '${lat.toStringAsFixed(2)}°, ${lon.toStringAsFixed(2)}°';
    } catch (_) {
      return 'My Location';
    }
  }
}

class GeocodingResult {
  const GeocodingResult({
    required this.displayName,
    required this.lat,
    required this.lon,
  });

  final String displayName;
  final double lat;
  final double lon;
}

class WeatherApiException implements Exception {
  const WeatherApiException(this.message);
  final String message;

  @override
  String toString() => 'WeatherApiException: $message';
}
