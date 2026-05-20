/// Formats a [DateTime] as a 12-hour clock label with am/pm suffix,
/// e.g. `3pm`, `12am`.
String formatHour(DateTime t) {
  final h = t.hour;
  final suffix = h < 12 ? 'am' : 'pm';
  final display = h % 12 == 0 ? 12 : h % 12;
  return '$display$suffix';
}
