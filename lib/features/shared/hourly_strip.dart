import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/weather_data.dart';
import '../../core/models/weather_theme.dart';
import '../../core/models/wmo_code.dart';
import '../../core/providers/temperature_unit_provider.dart';
import '../../core/utils/time_formatter.dart';

/// Horizontally scrollable strip of [HourlyTile] widgets.
/// Used on both the home screen and the forecast screen.
class HourlyStrip extends StatelessWidget {
  const HourlyStrip({super.key, required this.hourly, required this.theme});

  final List<HourlyForecast> hourly;
  final WeatherTheme theme;

  @override
  Widget build(BuildContext context) {
    if (hourly.isEmpty) {
      return Container(
        height: 96,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            'No hourly data',
            style: TextStyle(color: theme.textPrimary.withOpacity(0.5)),
          ),
        ),
      );
    }
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: hourly.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => HourlyTile(
          forecast: hourly[i],
          theme: theme,
          isFirst: i == 0,
        ),
      ),
    );
  }
}

/// Single tile inside [HourlyStrip] showing time, weather icon, and temperature.
class HourlyTile extends ConsumerWidget {
  const HourlyTile({
    super.key,
    required this.forecast,
    required this.theme,
    required this.isFirst,
  });

  final HourlyForecast forecast;
  final WeatherTheme theme;
  final bool isFirst;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unit = ref.watch(temperatureUnitProvider);
    final label = isFirst ? 'Now' : formatHour(forecast.time);
    return Container(
      width: 60,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: isFirst
            ? theme.textPrimary.withOpacity(0.25)
            : theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            label,
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: 11,
              fontWeight: isFirst ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
          Text(WmoCode.icon(forecast.wmoCode),
              style: const TextStyle(fontSize: 20)),
          Text(
            unit.format(forecast.temperatureC),
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
