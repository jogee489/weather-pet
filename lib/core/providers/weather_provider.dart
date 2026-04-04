import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/weather_data.dart';
import '../services/weather_api.dart';
import 'location_provider.dart';

/// Fetches and caches weather data for the current location.
/// Automatically re-fetches when [locationProvider] changes.
class WeatherNotifier extends AsyncNotifier<WeatherData> {
  @override
  Future<WeatherData> build() async {
    // Watch location — any change triggers a new weather fetch.
    final location = await ref.watch(locationProvider.future);

    return const WeatherApi().fetchWeather(
      lat: location.lat,
      lon: location.lon,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    // Re-fetch location first (handles the case where location also failed).
    await ref.read(locationProvider.notifier).refresh();
    state = await AsyncValue.guard(() async {
      final location = await ref.read(locationProvider.future);
      return const WeatherApi().fetchWeather(
        lat: location.lat,
        lon: location.lon,
      );
    });
  }
}

final weatherProvider =
    AsyncNotifierProvider<WeatherNotifier, WeatherData>(WeatherNotifier.new);
