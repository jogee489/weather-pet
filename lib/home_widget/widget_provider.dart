import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

import '../core/providers/pet_state_provider.dart';
import '../core/providers/weather_provider.dart';

/// Android app widget ID — must match the class name in AndroidManifest.xml.
const _kAndroidWidgetName = 'WeatherPetWidget';

/// iOS widget kind — must match the `kind` in the WidgetKit extension.
const _kIosWidgetName = 'WeatherPetWidget';

/// Shared preferences key prefix used by home_widget.
const _kGroupId = 'group.com.example.weather_pet';

/// Watches [weatherProvider] + [petStateProvider] and pushes a minimal
/// data snapshot to the platform home screen widget whenever either changes.
///
/// Register this provider in your widget tree (e.g. in app.dart) with:
/// ```dart
/// ref.watch(widgetSyncProvider);
/// ```
final widgetSyncProvider = Provider<void>((ref) {
  // Initialise once
  HomeWidget.setAppGroupId(_kGroupId);

  final weatherAsync = ref.watch(weatherProvider);
  final petState = ref.watch(petStateProvider);

  weatherAsync.whenData((weather) async {
    // Write individual keys — home_widget stores them in SharedPreferences
    // (Android) / App Groups UserDefaults (iOS).
    await Future.wait([
      HomeWidget.saveWidgetData<String>('temperature', '${weather.temperatureC.round()}°C'),
      HomeWidget.saveWidgetData<String>('city', weather.cityName),
      HomeWidget.saveWidgetData<String>('condition', _wmoDescription(weather.wmoCode)),
      HomeWidget.saveWidgetData<String>('petState', petState.name),
      HomeWidget.saveWidgetData<String>('emoji', _petEmoji(petState)),
    ]);

    // Tell the OS to redraw the widget.
    await HomeWidget.updateWidget(
      androidName: _kAndroidWidgetName,
      iOSName: _kIosWidgetName,
    );
  });
});

// ─── Helpers ──────────────────────────────────────────────────────────────────

String _wmoDescription(int code) => switch (code) {
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

String _petEmoji(dynamic petState) => switch (petState.name) {
      'sunny' => '😸',
      'hot' => '😹',
      'windy' => '😼',
      'rainy' => '🙀',
      'stormy' => '🙀',
      'snowy' => '😿',
      'cold' => '😿',
      'night' => '😴',
      _ => '🐱',
    };
