import 'package:flutter_test/flutter_test.dart';
import 'package:weather_pet/core/models/pet_character.dart';
import 'package:weather_pet/core/models/pet_state.dart';

void main() {
  group('PetCharacter', () {
    test('all list is non-empty', () {
      expect(PetCharacter.all, isNotEmpty);
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
        expect(character.id, isNotEmpty,
            reason: 'character id should not be empty');
        expect(character.displayName, isNotEmpty,
            reason: 'character displayName should not be empty');
        expect(character.emoji, isNotEmpty,
            reason: 'character emoji should not be empty');
      }
    });

    group('lottiePath', () {
      const cat = PetCharacter.defaultCharacter;

      test('uses the character id as folder name', () {
        final path = cat.lottiePath(PetState.sunny);
        expect(path, contains('cat'));
      });

      test('uses the state name as file name', () {
        final path = cat.lottiePath(PetState.sunny);
        expect(path, endsWith('sunny.json'));
      });

      test('produces correct full path for sunny', () {
        expect(cat.lottiePath(PetState.sunny), 'assets/lottie/cat/sunny.json');
      });

      test('produces correct full path for stormy', () {
        expect(
            cat.lottiePath(PetState.stormy), 'assets/lottie/cat/stormy.json');
      });

      test('every PetState produces a non-empty path', () {
        for (final state in PetState.values) {
          expect(cat.lottiePath(state), isNotEmpty,
              reason: 'lottiePath for $state should not be empty');
        }
      });
    });
  });
}
