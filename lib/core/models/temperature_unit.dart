enum TemperatureUnit {
  celsius,
  fahrenheit;

  String get label => switch (this) {
        TemperatureUnit.celsius => '°C',
        TemperatureUnit.fahrenheit => '°F',
      };

  /// Convert a Celsius value to this unit, rounded to nearest integer string.
  String format(double celsius) {
    final value = switch (this) {
      TemperatureUnit.celsius => celsius,
      TemperatureUnit.fahrenheit => celsius * 9 / 5 + 32,
    };
    return '${value.round()}$label';
  }

  /// Raw converted value (unformatted).
  double convert(double celsius) => switch (this) {
        TemperatureUnit.celsius => celsius,
        TemperatureUnit.fahrenheit => celsius * 9 / 5 + 32,
      };
}
