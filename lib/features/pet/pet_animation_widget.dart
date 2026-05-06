import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../core/models/pet_character.dart';
import '../../core/models/pet_config.dart';
import '../../core/models/pet_state.dart';
import 'pet_widget.dart';

/// Variant-aware animated pet. Resolves the Lottie asset via [PetRegistry]
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
    final config = PetRegistry.findById(petId);
    final resolvedVariant = config.availableVariants.contains(variant)
        ? variant
        : config.availableVariants.first;
    final path = config.lottiePath(weatherState.name, variant: resolvedVariant);

    return SizedBox(
      width: size,
      height: size,
      child: Lottie.asset(
        path,
        fit: BoxFit.contain,
        repeat: true,
        errorBuilder: (_, __, ___) {
          final character = PetCharacter.all.firstWhere(
            (c) => c.id == petId,
            orElse: () => PetCharacter.defaultCharacter,
          );
          return PetWidget(
            character: character,
            petState: weatherState,
            size: size,
          );
        },
      ),
    );
  }
}
