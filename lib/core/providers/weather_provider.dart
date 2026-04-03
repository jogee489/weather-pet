import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/weather_data.dart';

/// Fetches and caches weather data for the current location.
/// Implemented in Phase 2.
class WeatherNotifier extends AsyncNotifier<WeatherData> {
  @override
  Future<WeatherData> build() async {
    // TODO Phase 2: call LocationService + WeatherApi
    throw UnimplementedError('WeatherNotifier — implemented in Phase 2');
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }
}

final weatherProvider =
    AsyncNotifierProvider<WeatherNotifier, WeatherData>(WeatherNotifier.new);
