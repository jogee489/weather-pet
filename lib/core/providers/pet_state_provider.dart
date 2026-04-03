import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pet_state.dart';
import 'weather_provider.dart';

/// Derives the current [PetState] from live weather data.
/// Returns [PetState.loading] while the weather fetch is in-flight or on error.
final petStateProvider = Provider<PetState>((ref) {
  final weatherAsync = ref.watch(weatherProvider);

  return weatherAsync.when(
    loading: () => PetState.loading,
    error: (_, __) => PetState.loading,
    data: (weather) => PetState.fromWeather(
      wmoCode: weather.wmoCode,
      windSpeedKmh: weather.windSpeedKmh,
      apparentTempC: weather.apparentTemperatureC,
      isDay: weather.isDay,
    ),
  );
});
