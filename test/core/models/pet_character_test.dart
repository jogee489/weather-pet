import 'package:flutter_test/flutter_test.dart';
import 'package:weather_pet/core/models/pet_character.dart';
import 'package:weather_pet/core/models/pet_state.dart';

void main() {
  group('PetCharacter', () {
    test('all list has 4 characters', () {
      expect(PetCharacter.all.length, 4);
    });

    test('all list contains cat, dog, dragon, frog', () {
      final ids = PetCharacter.all.map((c) => c.id).toList();
      expect(ids, containsAll(['cat', 'dog', 'dragon', 'frog']));
    });

    test('defaultCharacter id is cat', () {
      expect(PetCharacter.defaultCharacter.id, 'cat');
    });

    test('defaultCharacter exists in all list', () {
      final ids = PetCharacter.all.map((c) => c.id);
      expect(ids, contains(PetCharacter.defaultCharacter.id));
    });

    test('all characters have non-empty id, displayName, and emoji', () {
      for (final character in PetCharacter.all) {
        expect(character.id, isNotEmpty);
        expect(character.displayName, isNotEmpty);
        expect(character.emoji, isNotEmpty);
      }
    });

    group('emojiForState', () {
      test('cat returns expressive emoji for sunny', () {
        expect(
          PetCharacter.defaultCharacter.emojiForState(PetState.sunny),
          '😸',
        );
      });

      test('cat returns expressive emoji for stormy', () {
        expect(
          PetCharacter.defaultCharacter.emojiForState(PetState.stormy),
          '🙀',
        );
      });

      test('cat falls back to base emoji for cloudy (no override)', () {
        expect(
          PetCharacter.defaultCharacter.emojiForState(PetState.cloudy),
          '🐱',
        );
      });

      test('dog returns base emoji for all states (no expressiveEmojis)', () {
        const dog = PetCharacter(id: 'dog', displayName: 'Dog', emoji: '🐶');
        for (final state in PetState.values) {
          expect(dog.emojiForState(state), '🐶');
        }
      });
    });

    group('lottiePath', () {
      const cat = PetCharacter.defaultCharacter;

      test('uses the character id as folder name', () {
        expect(cat.lottiePath(PetState.sunny), contains('cat'));
      });

      test('uses the state name as file name', () {
        expect(cat.lottiePath(PetState.sunny), endsWith('sunny.json'));
      });

      test('produces correct full path for sunny', () {
        expect(cat.lottiePath(PetState.sunny), 'assets/lottie/cat/default/sunny.json');
      });

      test('produces correct full path for stormy', () {
        expect(cat.lottiePath(PetState.stormy), 'assets/lottie/cat/default/stormy.json');
      });

      test('every PetState produces a non-empty path', () {
        for (final state in PetState.values) {
          expect(cat.lottiePath(state), isNotEmpty);
        }
      });

      test('non-default variant is reflected in path', () {
        expect(
          cat.lottiePath(PetState.sunny, variant: 'ice'),
          'assets/lottie/cat/ice/sunny.json',
        );
      });

      test('dog lottie path uses dog folder', () {
        const dog = PetCharacter(id: 'dog', displayName: 'Dog', emoji: '🐶');
        expect(dog.lottiePath(PetState.sunny), 'assets/lottie/dog/default/sunny.json');
      });
    });
  });
}
