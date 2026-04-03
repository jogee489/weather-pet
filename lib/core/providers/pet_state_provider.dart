import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pet_state.dart';
import 'weather_override_provider.dart';
import 'weather_provider.dart';

/// The current [PetState] driving the cat animation and theme.
///
/// Checks [weatherOverrideProvider] first (Preview Mode). If a state is
/// pinned there, the live API is bypassed entirely. Otherwise, derives the
/// state from live [weatherProvider] data.
final petStateProvider = Provider<PetState>((ref) {
  final override = ref.watch(weatherOverrideProvider);
  if (override != null) return override;

  return ref.watch(weatherProvider).when(
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
