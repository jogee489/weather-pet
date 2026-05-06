/// Variant-aware pet configuration for the animation system.
///
/// Each pet can have multiple visual variants (e.g. 'default', 'ice').
/// All Lottie assets live at:
///   assets/lottie/{id}/{variant}/{state}.json
class PetConfig {
  const PetConfig({
    required this.id,
    required this.displayName,
    required this.emoji,
    required this.availableVariants,
  });

  final String id;
  final String displayName;
  final String emoji;

  /// Variants with Lottie assets present. First entry is the default.
  final List<String> availableVariants;

  /// Resolves the asset path for [state] and [variant].
  String lottiePath(String state, {String variant = 'default'}) =>
      'assets/lottie/$id/$variant/$state.json';
}

/// Central registry of all pets known to the app.
class PetRegistry {
  PetRegistry._();

  static const List<PetConfig> all = [
    PetConfig(
      id: 'cat',
      displayName: 'Cat',
      emoji: '🐱',
      availableVariants: ['default'],
    ),
    PetConfig(
      id: 'dog',
      displayName: 'Dog',
      emoji: '🐶',
      availableVariants: ['default'],
    ),
    PetConfig(
      id: 'dragon',
      displayName: 'Dragon',
      emoji: '🐲',
      availableVariants: ['default'],
    ),
    PetConfig(
      id: 'frog',
      displayName: 'Frog',
      emoji: '🐸',
      availableVariants: ['default'],
    ),
  ];

  static const PetConfig defaultPet = PetConfig(
    id: 'cat',
    displayName: 'Cat',
    emoji: '🐱',
    availableVariants: ['default'],
  );

  /// Returns the [PetConfig] for [id], or [defaultPet] if not found.
  static PetConfig findById(String id) =>
      all.firstWhere((p) => p.id == id, orElse: () => defaultPet);
}
