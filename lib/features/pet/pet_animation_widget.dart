import 'package:flutter/material.dart';

import '../../core/models/pet_character.dart';
import '../../core/models/pet_state.dart';
import 'pet_widget.dart';

/// Animated pet widget. Looks up the character and renders [PetWidget].
///
/// Variant is accepted for API compatibility but not yet used — each
/// character has a single animation file.
class PetAnimationWidget extends StatelessWidget {
  const PetAnimationWidget({
    super.key,
    required this.petId,
    required this.weatherState,
    this.variant = 'default',
    this.size = 200,
    this.intensity = 0.5,
  });

  final String petId;
  final PetState weatherState;
  final String variant;
  final double size;

  /// How strong the current weather is, 0–1. See [PetState.intensityFor].
  final double intensity;

  @override
  Widget build(BuildContext context) {
    final character = PetCharacter.findById(petId);
    return PetWidget(
      character: character,
      petState: weatherState,
      size: size,
      intensity: intensity,
    );
  }
}
