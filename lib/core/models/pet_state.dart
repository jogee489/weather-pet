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

  // ─── Thresholds ────────────────────────────────────────────────────────────

  /// Apparent temperature at or above which the pet enters [hot] state (°C).
  static const double kHotThresholdC = 35.0;

  /// Apparent temperature below which the pet enters [cold] state (°C).
  static const double kColdThresholdC = 0.0;

  /// Wind speed above which the pet enters [windy] state (km/h).
  static const double kWindyThresholdKmh = 40.0;

  // ─── Factory ───────────────────────────────────────────────────────────────

  /// Derive a [PetState] from an Open-Meteo WMO weather code,
  /// wind speed (km/h), apparent temperature (°C), and whether it is daytime.
  static PetState fromWeather({
    required int wmoCode,
    required double windSpeedKmh,
    required double apparentTempC,
    required bool isDay,
  }) {
    if (!isDay) return PetState.night;
    if (apparentTempC >= kHotThresholdC) return PetState.hot;
    if (apparentTempC < kColdThresholdC) return PetState.cold;
    if (windSpeedKmh >= kWindyThresholdKmh) return PetState.windy;

    return switch (wmoCode) {
      0 => PetState.sunny,
      1 || 2 || 3 => PetState.cloudy,
      45 || 48 => PetState.foggy,
      >= 51 && <= 67 => PetState.rainy, // includes freezing rain codes 66–67
      >= 71 && <= 77 => PetState.snowy,
      >= 80 && <= 82 => PetState.rainy,
      85 || 86 => PetState.snowy,
      >= 95 && <= 99 => PetState.stormy,
      _ => PetState.cloudy,
    };
  }

  // ─── Getters ───────────────────────────────────────────────────────────────

  /// Human-readable label used in the preview and settings screens.
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

  /// Generic condition emoji — not character-specific.
  /// Use [PetCharacter.emojiForState] for character-expressive reactions.
  String get conditionEmoji => switch (this) {
        PetState.sunny => '☀️',
        PetState.cloudy => '☁️',
        PetState.rainy => '🌧️',
        PetState.snowy => '❄️',
        PetState.stormy => '⛈️',
        PetState.windy => '💨',
        PetState.hot => '🔥',
        PetState.cold => '🥶',
        PetState.night => '🌙',
        PetState.foggy => '🌫️',
        PetState.loading => '⏳',
      };
}
