import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/pet_character.dart';
import '../../core/models/pet_state.dart';
import '../../core/providers/selected_character_provider.dart';
import '../../core/providers/temperature_unit_provider.dart';
import '../../core/providers/weather_override_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final override = ref.watch(weatherOverrideProvider);
    final previewActive = override != null;
    final unit = ref.watch(temperatureUnitProvider);
    final character = ref.watch(selectedCharacterProvider);

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
                      value: unit.label,
                      onTap: () => ref
                          .read(temperatureUnitProvider.notifier)
                          .toggle(),
                    ),
                    const Divider(color: Colors.white24, height: 1),
                    _SettingRow(
                      label: 'Pet Character',
                      value: '${character.emoji} ${character.displayName}',
                      onTap: () => _showCharacterPicker(context, ref),
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
                                  '${_stateEmoji(state)} ${state.displayName}',
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

  void _showCharacterPicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _CharacterPickerSheet(ref: ref),
    );
  }

  static String _stateEmoji(PetState state) => switch (state) {
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

// ─── Character picker bottom sheet ───────────────────────────────────────────

class _CharacterPickerSheet extends ConsumerWidget {
  const _CharacterPickerSheet({required this.ref});
  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef sheetRef) {
    final current = sheetRef.watch(selectedCharacterProvider);

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A4A8A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Choose Your Pet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: PetCharacter.all.map((character) {
              final selected = current.id == character.id;
              return GestureDetector(
                onTap: () {
                  sheetRef
                      .read(selectedCharacterProvider.notifier)
                      .select(character);
                  Navigator.of(context).pop();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: selected
                        ? Colors.white
                        : Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selected ? Colors.white : Colors.white24,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        character.emoji,
                        style: const TextStyle(fontSize: 32),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        character.displayName,
                        style: TextStyle(
                          color: selected
                              ? const Color(0xFF1A4A8A)
                              : Colors.white,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
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
