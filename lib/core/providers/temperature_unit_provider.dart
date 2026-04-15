import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/temperature_unit.dart';

const _kKey = 'temperature_unit';

class TemperatureUnitNotifier extends Notifier<TemperatureUnit> {
  @override
  TemperatureUnit build() => TemperatureUnit.celsius;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_kKey);
    if (stored == TemperatureUnit.fahrenheit.name) {
      state = TemperatureUnit.fahrenheit;
    }
  }

  Future<void> toggle() async {
    final next = state == TemperatureUnit.celsius
        ? TemperatureUnit.fahrenheit
        : TemperatureUnit.celsius;
    state = next;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kKey, next.name);
  }
}

final temperatureUnitProvider =
    NotifierProvider<TemperatureUnitNotifier, TemperatureUnit>(
  TemperatureUnitNotifier.new,
);
