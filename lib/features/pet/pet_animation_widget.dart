import 'package:flutter/material.dart';

import '../../core/models/pet_character.dart';
import '../../core/models/pet_state.dart';
import 'pet_widget.dart';

/// Animated pet widget. Currently renders PNG images via [PetWidget].
///
/// Variant is accepted for API compatibility but not yet used — all
/// characters share a single image set per state.
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
    return PetWidget(
      character: character,
      petState: weatherState,
      size: size,
    );
  }
}
