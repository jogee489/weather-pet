/// The 11 possible weather-driven states for a pet character.
/// This enum is completely independent of which animal is displayed —
/// the same states drive any current or future pet character.
enum PetState {
  sunny,
  cloudy,
  rainy,
  snowy,
  stormy,
  windy,
  hot,
  cold,
  night,
  foggy,
  loading;

  /// Derive a [PetState] from an Open-Meteo WMO weather code,
  /// wind speed (km/h), apparent temperature (°C), and whether it is daytime.
  static PetState fromWeather({
    required int wmoCode,
    required double windSpeedKmh,
    required double apparentTempC,
    required bool isDay,
  }) {
    // Night overrides everything except extreme temps when is_day == 0
    if (!isDay) return PetState.night;

    // Extreme apparent temperature overrides condition-based states
    if (apparentTempC >= 35) return PetState.hot;
    if (apparentTempC < 0) return PetState.cold;

    // Strong wind overrides mild condition codes
    if (windSpeedKmh > 40) return PetState.windy;

    return switch (wmoCode) {
      0 => PetState.sunny,
      1 || 2 || 3 => PetState.cloudy,
      45 || 48 => PetState.foggy,
      >= 51 && <= 67 => PetState.rainy,
      >= 71 && <= 77 => PetState.snowy,
      >= 80 && <= 82 => PetState.rainy,
      85 || 86 => PetState.snowy,
      >= 95 && <= 99 => PetState.stormy,
      _ => PetState.cloudy,
    };
  }

  /// Human-readable label used in the Pet Showcase Screen.
  String get displayName => switch (this) {
        PetState.sunny => 'Sunny',
        PetState.cloudy => 'Cloudy',
        PetState.rainy => 'Rainy',
        PetState.snowy => 'Snowy',
        PetState.stormy => 'Stormy',
        PetState.windy => 'Windy',
        PetState.hot => 'Hot',
        PetState.cold => 'Cold',
        PetState.night => 'Night',
        PetState.foggy => 'Foggy',
        PetState.loading => 'Loading',
      };
}
