import 'pet_state.dart';

/// Describes a pet character available in the app.
///
/// Adding a new character requires:
///   1. Creating `assets/lottie/<id>/` with 11 Lottie JSON files (one per [PetState]).
///   2. Declaring a new [PetCharacter] in [PetCharacter.all].
///
/// No other code changes are needed — [PetWidget] resolves the correct asset
/// path via [lottiePath] automatically.
class PetCharacter {
  const PetCharacter({
    required this.id,
    required this.displayName,
    required this.emoji,
  });

  /// Unique identifier; must match the folder name under `assets/lottie/`.
  final String id;

  /// Name shown in the character picker UI.
  final String displayName;

  /// Fallback emoji shown before Lottie assets load.
  final String emoji;

  /// Returns the asset path for the Lottie JSON that corresponds to [state].
  /// Example: 'assets/lottie/cat/sunny.json'
  String lottiePath(PetState state) =>
      'assets/lottie/$id/${state.name}.json';

  /// All available characters. To unlock a character, add it here
  /// and supply its Lottie assets.
  static const List<PetCharacter> all = [
    PetCharacter(
      id: 'cat',
      displayName: 'Cat',
      emoji: '🐱',
    ),
    // Future characters (assets not yet available — keep commented until ready):
    // PetCharacter(id: 'dog',    displayName: 'Dog',    emoji: '🐶'),
    // PetCharacter(id: 'dragon', displayName: 'Dragon', emoji: '🐲'),
    // PetCharacter(id: 'frog',   displayName: 'Frog',   emoji: '🐸'),
  ];

  /// The default character used on first launch.
  static const PetCharacter defaultCharacter = PetCharacter(
    id: 'cat',
    displayName: 'Cat',
    emoji: '🐱',
  );
}
