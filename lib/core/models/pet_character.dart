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
    this.expressiveEmojis = const {},
  });

  /// Unique identifier; must match the folder name under `assets/lottie/`.
  final String id;

  /// Name shown in the character picker UI.
  final String displayName;

  /// Default emoji — shown before Lottie assets load and for any state
  /// not listed in [expressiveEmojis].
  final String emoji;

  /// Per-state emoji overrides for expressive reactions.
  /// States absent from this map fall back to [emoji].
  final Map<PetState, String> expressiveEmojis;

  /// Returns the expressive emoji for [state], or [emoji] if no override exists.
  String emojiForState(PetState state) => expressiveEmojis[state] ?? emoji;

  /// Returns the asset path for the Lottie JSON that corresponds to [state].
  /// Example: 'assets/lottie/cat/sunny.json'
  String lottiePath(PetState state) =>
      'assets/lottie/$id/${state.name}.json';

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

  /// All available characters. To unlock a character, add it here
  /// and supply its Lottie assets under `assets/lottie/<id>/`.
  static const List<PetCharacter> all = [
    defaultCharacter,
    PetCharacter(id: 'dog',    displayName: 'Dog',    emoji: '🐶'),
    PetCharacter(id: 'dragon', displayName: 'Dragon', emoji: '🐲'),
    PetCharacter(id: 'frog',   displayName: 'Frog',   emoji: '🐸'),
  ];
}
