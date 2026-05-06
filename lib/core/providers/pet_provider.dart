import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pet_config.dart';
import 'selected_character_provider.dart';

/// Derives a [PetConfig] from the currently selected character.
final selectedPetProvider = Provider<PetConfig>((ref) {
  final character = ref.watch(selectedCharacterProvider);
  return PetRegistry.findById(character.id);
});

/// The active Lottie variant (e.g. 'default', 'ice').
/// Defaults to 'default'; update when the user picks a skin.
final selectedVariantProvider = StateProvider<String>((_) => 'default');
