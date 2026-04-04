import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/pet_state.dart';
import '../../core/providers/weather_override_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final override = ref.watch(weatherOverrideProvider);
    final previewActive = override != null;

    return Scaffold(
      backgroundColor: const Color(0xFF4A90D9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),

              // ─── App settings ───────────────────────────────────────────
              _SettingsCard(
                child: Column(
                  children: [
                    _SettingRow(
                      label: 'Temperature Unit',
                      value: '°C',
                      onTap: () {},
                    ),
                    const Divider(color: Colors.white24, height: 1),
                    _SettingRow(
                      label: 'Pet Character',
                      value: 'Cat',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ─── Preview Mode ────────────────────────────────────────────
              _SettingsCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Toggle row
                    SwitchListTile(
                      value: previewActive,
                      onChanged: (on) {
                        ref.read(weatherOverrideProvider.notifier).state =
                            on ? PetState.sunny : null;
                      },
                      title: const Text(
                        'Preview Mode',
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        previewActive
                            ? 'Showing: ${override.displayName}'
                            : 'Simulate any weather state',
                        style: const TextStyle(color: Colors.white60),
                      ),
                      activeColor: Colors.white,
                      activeTrackColor: Colors.white30,
                      inactiveThumbColor: Colors.white54,
                      inactiveTrackColor: Colors.white12,
                    ),

                    // State picker — only shown when preview is active
                    if (previewActive) ...[
                      const Divider(color: Colors.white24, height: 1),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: PetState.values.map((state) {
                            final selected = override == state;
                            return GestureDetector(
                              onTap: () {
                                ref
                                    .read(weatherOverrideProvider.notifier)
                                    .state = state;
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: selected
                                        ? Colors.white
                                        : Colors.white38,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  '${_emoji(state)} ${state.displayName}',
                                  style: TextStyle(
                                    color: selected
                                        ? const Color(0xFF4A90D9)
                                        : Colors.white,
                                    fontWeight: selected
                                        ? FontWeight.w700
                                        : FontWeight.w400,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 32),
              Center(
                child: Text(
                  'Weather Pet v1.0.0',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.white38),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _emoji(PetState state) => switch (state) {
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

// ─── Shared UI components ─────────────────────────────────────────────────────

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Text(label, style: const TextStyle(color: Colors.white)),
      trailing: Text(value, style: const TextStyle(color: Colors.white70)),
    );
  }
}
