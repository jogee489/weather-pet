import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../core/models/pet_character.dart';
import '../../core/models/pet_state.dart';
import 'pet_widget.dart';

/// Variant-aware animated pet. Resolves the Lottie asset via [PetCharacter]
/// and falls back to [PetWidget] (which itself falls back to an animated emoji)
/// when the file is missing.
class PetAnimationWidget extends StatelessWidget {
  const PetAnimationWidget({
    super.key,
    required this.petId,
    required this.weatherState,
    this.variant = 'default',
    this.size = 200,
  });

  final String petId;
  final PetState weatherState;
  final String variant;
  final double size;

  @override
  Widget build(BuildContext context) {
    final character = PetCharacter.findById(petId);
    final resolvedVariant = character.availableVariants.contains(variant)
        ? variant
        : character.availableVariants.first;

    return SizedBox(
      width: size,
      height: size,
      child: Lottie.asset(
        character.lottiePath(weatherState, variant: resolvedVariant),
        fit: BoxFit.contain,
        repeat: true,
        errorBuilder: (_, __, ___) => PetWidget(
          character: character,
          petState: weatherState,
          size: size,
        ),
      ),
    );
  }
}
