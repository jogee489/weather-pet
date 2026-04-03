import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/pet_character.dart';

const _kCharacterKey = 'selected_character_id';

/// Persists and exposes the user's chosen pet character.
/// Defaults to [PetCharacter.defaultCharacter] on first launch.
class SelectedCharacterNotifier extends Notifier<PetCharacter> {
  @override
  PetCharacter build() => PetCharacter.defaultCharacter;

  /// Load persisted selection from [SharedPreferences].
  /// Call this once during app startup (Phase 2: from SplashScreen).
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final savedId = prefs.getString(_kCharacterKey);
    if (savedId == null) return;

    final match = PetCharacter.all.where((c) => c.id == savedId).firstOrNull;
    if (match != null) state = match;
  }

  Future<void> select(PetCharacter character) async {
    state = character;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kCharacterKey, character.id);
  }
}

final selectedCharacterProvider =
    NotifierProvider<SelectedCharacterNotifier, PetCharacter>(
  SelectedCharacterNotifier.new,
);
