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

    test('findById returns correct character', () {
      expect(PetCharacter.findById('dog').id, 'dog');
      expect(PetCharacter.findById('frog').displayName, 'Frog');
    });

    test('findById returns defaultCharacter for unknown id', () {
      expect(PetCharacter.findById('unicorn').id, PetCharacter.defaultCharacter.id);
    });

    test('availableVariants defaults to [default]', () {
      expect(PetCharacter.defaultCharacter.availableVariants, ['default']);
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

    group('rivePath', () {
      const cat = PetCharacter.defaultCharacter;

      test('default variant produces correct path', () {
        expect(cat.rivePath(), 'assets/rive/cat/default.riv');
      });

      test('non-default variant is reflected in path', () {
        expect(cat.rivePath(variant: 'classic'), 'assets/rive/cat/classic.riv');
      });

      test('uses character id as folder', () {
        expect(cat.rivePath(), contains('cat'));
      });

      test('path ends with .riv', () {
        expect(cat.rivePath(), endsWith('.riv'));
      });

      test('dog produces correct path', () {
        const dog = PetCharacter(id: 'dog', displayName: 'Dog', emoji: '🐶');
        expect(dog.rivePath(), 'assets/rive/dog/default.riv');
      });

      test('all characters produce non-empty paths', () {
        for (final character in PetCharacter.all) {
          expect(character.rivePath(), isNotEmpty);
        }
      });
    });
  });
}
