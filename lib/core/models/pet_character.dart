import 'pet_state.dart';

/// Describes a pet character available in the app.
///
/// Each character needs a set of PNG images at
/// `assets/images/<id>/<state-name>.png` (one per [PetState]).
class PetCharacter {
  const PetCharacter({
    required this.id,
    required this.displayName,
    required this.emoji,
    this.expressiveEmojis = const {},
    this.availableVariants = const ['default'],
  });

  /// Unique identifier; must match the folder name under `assets/images/`.
  final String id;

  /// Name shown in the character picker UI.
  final String displayName;

  /// Default emoji — shown when no PNG is found for a state.
  final String emoji;

  /// Per-state emoji overrides for expressive reactions.
  /// States absent from this map fall back to [emoji].
  final Map<PetState, String> expressiveEmojis;

  /// Variants available for this character. First entry is the default.
  final List<String> availableVariants;

  /// Returns the expressive emoji for [state], or [emoji] if no override exists.
  String emojiForState(PetState state) => expressiveEmojis[state] ?? emoji;

  /// Returns the [PetCharacter] for [id], or [defaultCharacter] if not found.
  static PetCharacter findById(String id) =>
      all.firstWhere((c) => c.id == id, orElse: () => defaultCharacter);

  /// The default character used on first launch.
  static const defaultCharacter = PetCharacter(
    id: 'cat',
    displayName: 'Cat',
    emoji: '🐱',
    expressiveEmojis: {
      PetState.sunny: '😸',
      PetState.hot: '😹',
      PetState.windy: '😼',
      PetState.rainy: '🙀',
      PetState.stormy: '🙀',
      PetState.snowy: '😿',
      PetState.cold: '😿',
      PetState.night: '😴',
    },
  );

  /// All available characters.
  static const List<PetCharacter> all = [
    defaultCharacter,
    PetCharacter(id: 'dog',    displayName: 'Dog',    emoji: '🐶'),
    PetCharacter(id: 'dragon', displayName: 'Dragon', emoji: '🐲'),
    PetCharacter(id: 'frog',   displayName: 'Frog',   emoji: '🐸'),
  ];
}
