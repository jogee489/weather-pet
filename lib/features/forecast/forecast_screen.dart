import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/weather_data.dart';
import '../../core/models/weather_theme.dart';
import '../../core/providers/pet_state_provider.dart';
import '../../core/providers/temperature_unit_provider.dart';
import '../../core/providers/weather_provider.dart';

class ForecastScreen extends ConsumerWidget {
  const ForecastScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petState = ref.watch(petStateProvider);
    final theme = WeatherTheme.forState(petState);
    final weatherAsync = ref.watch(weatherProvider);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      decoration: BoxDecoration(gradient: theme.gradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: weatherAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(
                  color: Colors.white54, strokeWidth: 2),
            ),
            error: (_, __) => Center(
              child: Text(
                'Could not load forecast.',
                style: TextStyle(color: theme.textPrimary),
              ),
            ),
            data: (weather) => _ForecastBody(weather: weather, theme: theme),
          ),
        ),
      ),
    );
  }
}

// ─── Body ─────────────────────────────────────────────────────────────────────

class _ForecastBody extends StatelessWidget {
  const _ForecastBody({required this.weather, required this.theme});
  final WeatherData weather;
  final WeatherTheme theme;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          sliver: SliverToBoxAdapter(
            child: Text(
              'Forecast',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: theme.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ),

        // ── Hourly strip ──────────────────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          sliver: SliverToBoxAdapter(
            child: _SectionLabel(label: 'Next 24 hours', theme: theme),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
          sliver: SliverToBoxAdapter(
            child: _HourlyStrip(hourly: weather.hourly, theme: theme),
          ),
        ),

        // ── 7-day forecast ────────────────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
          sliver: SliverToBoxAdapter(
            child: _SectionLabel(label: '7-Day Forecast', theme: theme),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) => _DailyCard(
                forecast: weather.daily[i],
                theme: theme,
                isFirst: i == 0,
              ),
              childCount: weather.daily.length,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Section label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.theme});
  final String label;
  final WeatherTheme theme;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: theme.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

// ─── Hourly strip ─────────────────────────────────────────────────────────────

class _HourlyStrip extends StatelessWidget {
  const _HourlyStrip({required this.hourly, required this.theme});
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
        itemBuilder: (_, i) => _HourlyTile(
          forecast: hourly[i],
          theme: theme,
          isFirst: i == 0,
        ),
      ),
    );
  }
}

class _HourlyTile extends ConsumerWidget {
  const _HourlyTile({
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
    final label = isFirst ? 'Now' : _formatHour(forecast.time);
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
          Text(_wmoIcon(forecast.wmoCode),
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

  static String _formatHour(DateTime t) {
    final h = t.hour;
    final suffix = h < 12 ? 'am' : 'pm';
    final display = h % 12 == 0 ? 12 : h % 12;
    return '$display$suffix';
  }

  static String _wmoIcon(int code) => switch (code) {
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

// ─── Daily card ───────────────────────────────────────────────────────────────

class _DailyCard extends ConsumerWidget {
  const _DailyCard({
    required this.forecast,
    required this.theme,
    required this.isFirst,
  });
  final DailyForecast forecast;
  final WeatherTheme theme;
  final bool isFirst;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unit = ref.watch(temperatureUnitProvider);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isFirst
            ? theme.textPrimary.withOpacity(0.2)
            : theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Day label
          SizedBox(
            width: 48,
            child: Text(
              isFirst ? 'Today' : _dayLabel(forecast.date),
              style: TextStyle(
                color: theme.textPrimary,
                fontWeight: isFirst ? FontWeight.w700 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Weather icon
          Text(_wmoIcon(forecast.wmoCode),
              style: const TextStyle(fontSize: 22)),
          const Spacer(),
          // Low temp
          Text(
            unit.format(forecast.minTempC),
            style: TextStyle(
              color: theme.textPrimary.withOpacity(0.6),
              fontSize: 15,
            ),
          ),
          const SizedBox(width: 8),
          // Temp range bar
          _TempBar(
            minTemp: forecast.minTempC,
            maxTemp: forecast.maxTempC,
            theme: theme,
          ),
          const SizedBox(width: 8),
          // High temp
          SizedBox(
            width: 36,
            child: Text(
              unit.format(forecast.maxTempC),
              textAlign: TextAlign.end,
              style: TextStyle(
                color: theme.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _dayLabel(DateTime d) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[d.weekday - 1];
  }

  static String _wmoIcon(int code) => switch (code) {
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

// ─── Temp range bar ───────────────────────────────────────────────────────────

class _TempBar extends StatelessWidget {
  const _TempBar({
    required this.minTemp,
    required this.maxTemp,
    required this.theme,
  });
  final double minTemp;
  final double maxTemp;
  final WeatherTheme theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 6,
      decoration: BoxDecoration(
        color: theme.textPrimary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(3),
      ),
      child: FractionallySizedBox(
        widthFactor: _clamp((maxTemp - minTemp).abs() / 30),
        alignment: Alignment.centerLeft,
        child: Container(
          decoration: BoxDecoration(
            color: theme.accentColor.withOpacity(0.85),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }

  static double _clamp(double v) => v.clamp(0.1, 1.0);
}
