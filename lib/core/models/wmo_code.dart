/// Open-Meteo WMO weather interpretation code helpers.
///
/// Reference: https://open-meteo.com/en/docs#weathervariables
class WmoCode {
  WmoCode._();

  /// Human-readable condition description for a WMO [code].
  static String description(int code) => switch (code) {
        0 => 'Clear sky',
        1 => 'Mainly clear',
        2 => 'Partly cloudy',
        3 => 'Overcast',
        45 || 48 => 'Foggy',
        51 || 53 || 55 => 'Drizzle',
        61 || 63 || 65 => 'Rain',
        66 || 67 => 'Freezing rain',
        71 || 73 || 75 => 'Snow',
        77 => 'Snow grains',
        80 || 81 || 82 => 'Rain showers',
        85 || 86 => 'Snow showers',
        95 => 'Thunderstorm',
        96 || 99 => 'Thunderstorm with hail',
        _ => 'Cloudy',
      };

  /// Emoji icon for a WMO [code].
  static String icon(int code) => switch (code) {
        0 => '☀️',
        1 => '🌤️',
        2 => '⛅',
        3 => '☁️',
        45 || 48 => '🌫️',
        51 || 53 || 55 => '🌦️',
        61 || 63 || 65 => '🌧️',
        66 || 67 => '🌨️',
        71 || 73 || 75 || 77 => '❄️',
        80 || 81 || 82 => '🌦️',
        85 || 86 => '🌨️',
        95 || 96 || 99 => '⛈️',
        _ => '🌥️',
      };
}
