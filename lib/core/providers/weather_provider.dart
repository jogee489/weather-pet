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
    state = await AsyncValue.guard(build);
  }
}

final weatherProvider =
    AsyncNotifierProvider<WeatherNotifier, WeatherData>(WeatherNotifier.new);
