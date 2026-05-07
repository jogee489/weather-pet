import 'pet_state.dart';

/// Describes a pet character available in the app.
///
/// Adding a new character requires:
///   1. Creating `assets/rive/<id>/` and dropping in `default.riv`
///      (plus any additional variant `.riv` files).
///   2. Declaring a new [PetCharacter] in [PetCharacter.all].
///
/// No other code changes are needed — [PetAnimationWidget] resolves the
/// correct asset path via [rivePath] automatically.
class PetCharacter {
  const PetCharacter({
    required this.id,
    required this.displayName,
    required this.emoji,
    this.expressiveEmojis = const {},
    this.availableVariants = const ['default'],
  });

  /// Unique identifier; must match the folder name under `assets/rive/`.
  final String id;

  /// Name shown in the character picker UI.
  final String displayName;

  /// Default emoji — shown before Rive assets load and as the fallback
  /// when no `.riv` file is present for this character.
  final String emoji;

  /// Per-state emoji overrides for expressive reactions.
  /// States absent from this map fall back to [emoji].
  final Map<PetState, String> expressiveEmojis;

  /// Variants with Rive assets present. First entry is the default.
  /// Each variant maps to one `.riv` file: `assets/rive/<id>/<variant>.riv`.
  final List<String> availableVariants;

  /// Returns the expressive emoji for [state], or [emoji] if no override exists.
  String emojiForState(PetState state) => expressiveEmojis[state] ?? emoji;

  /// Returns the Rive asset path for this character and [variant].
  ///
  /// Each `.riv` file contains a single state machine (`WeatherMachine`)
  /// driven by a numeric input (`weatherIndex`) that maps to [PetState.index].
  /// Example: 'assets/rive/cat/default.riv'
  String rivePath({String variant = 'default'}) =>
      'assets/rive/$id/$variant.riv';

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

  /// All available characters. To unlock a character, add it here
  /// and supply its Rive assets under `assets/rive/<id>/`.
  static const List<PetCharacter> all = [
    defaultCharacter,
    PetCharacter(id: 'dog',    displayName: 'Dog',    emoji: '🐶'),
    PetCharacter(id: 'dragon', displayName: 'Dragon', emoji: '🐲'),
    PetCharacter(id: 'frog',   displayName: 'Frog',   emoji: '🐸'),
  ];
}
