import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/pet_character.dart';
import '../../core/models/pet_state.dart';
import '../../core/models/weather_data.dart';
import '../../core/models/weather_theme.dart';
import '../../core/providers/pet_state_provider.dart';
import '../../core/providers/selected_character_provider.dart';
import '../../core/providers/weather_provider.dart';
import '../pet/pet_widget.dart';

/// Primary screen — cat mascot + current weather conditions.
/// Cat animations (Lottie) and particle effects added in Phase 3.
/// UI polish and hourly strip added in Phase 4.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petState = ref.watch(petStateProvider);
    final character = ref.watch(selectedCharacterProvider);
    final theme = WeatherTheme.forState(petState);
    final weatherAsync = ref.watch(weatherProvider);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      decoration: BoxDecoration(gradient: theme.gradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: weatherAsync.when(
            loading: () => _LoadingBody(theme: theme, character: character),
            error: (e, _) => _ErrorBody(
              theme: theme,
              character: character,
              onRetry: () => ref.read(weatherProvider.notifier).refresh(),
            ),
            data: (weather) => _WeatherBody(
              weather: weather,
              petState: petState,
              character: character,
              theme: theme,
              onRefresh: () => ref.read(weatherProvider.notifier).refresh(),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Loading ────────────────────────────────────────────────────────────────

class _LoadingBody extends StatelessWidget {
  const _LoadingBody({required this.theme, required this.character});
  final WeatherTheme theme;
  final PetCharacter character;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PetWidget(
            character: character,
            petState: PetState.loading,
            size: 180,
          ),
          const SizedBox(height: 24),
          const CircularProgressIndicator(color: Colors.white54, strokeWidth: 2),
          const SizedBox(height: 16),
          Text(
            'Fetching weather…',
            style: TextStyle(color: theme.textPrimary.withOpacity(0.7)),
          ),
        ],
      ),
    );
  }
}

// ─── Error ───────────────────────────────────────────────────────────────────

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({
    required this.theme,
    required this.character,
    required this.onRetry,
  });
  final WeatherTheme theme;
  final PetCharacter character;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PetWidget(
              character: character,
              petState: PetState.loading,
              size: 160,
            ),
            const SizedBox(height: 16),
            Text(
              'Could not fetch weather.',
              style: TextStyle(
                color: theme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Check your connection and try again.',
              style: TextStyle(color: theme.textPrimary.withOpacity(0.7)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Main content ────────────────────────────────────────────────────────────

class _WeatherBody extends StatelessWidget {
  const _WeatherBody({
    required this.weather,
    required this.petState,
    required this.character,
    required this.theme,
    required this.onRefresh,
  });

  final WeatherData weather;
  final PetState petState;
  final PetCharacter character;
  final WeatherTheme theme;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _TopBar(weather: weather, theme: theme),
                  const Spacer(),
                  // Animated pet — crossfades when PetState changes
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: PetWidget(
                      key: ValueKey(petState),
                      character: character,
                      petState: petState,
                      size: 220,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _TemperatureDisplay(weather: weather, theme: theme),
                  const SizedBox(height: 24),
                  _ConditionPills(weather: weather, theme: theme),
                  const Spacer(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.weather, required this.theme});
  final WeatherData weather;
  final WeatherTheme theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              weather.cityName,
              style: TextStyle(
                color: theme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              weather.isDay ? 'Good day!' : 'Good evening!',
              style: TextStyle(
                color: theme.textPrimary.withOpacity(0.7),
                fontSize: 13,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () => context.go('/search'),
          child: Icon(Icons.search, color: theme.textPrimary, size: 26),
        ),
      ],
    );
  }
}

class _TemperatureDisplay extends StatelessWidget {
  const _TemperatureDisplay({required this.weather, required this.theme});
  final WeatherData weather;
  final WeatherTheme theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '${weather.temperatureC.round()}°C',
          style: TextStyle(
            color: theme.textPrimary,
            fontSize: 72,
            fontWeight: FontWeight.w200,
            height: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _wmoDescription(weather.wmoCode),
          style: TextStyle(
            color: theme.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Feels like ${weather.apparentTemperatureC.round()}°C',
          style: TextStyle(
            color: theme.textPrimary.withOpacity(0.7),
            fontSize: 15,
          ),
        ),
      ],
    );
  }

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
}

class _ConditionPills extends StatelessWidget {
  const _ConditionPills({required this.weather, required this.theme});
  final WeatherData weather;
  final WeatherTheme theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _Pill(
          icon: Icons.water_drop_outlined,
          label: '${weather.humidity}%',
          theme: theme,
        ),
        const SizedBox(width: 12),
        _Pill(
          icon: Icons.air,
          label: '${weather.windSpeedKmh.round()} km/h',
          theme: theme,
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.icon,
    required this.label,
    required this.theme,
  });

  final IconData icon;
  final String label;
  final WeatherTheme theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: theme.textPrimary, size: 18),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: theme.textPrimary)),
        ],
      ),
    );
  }
}
