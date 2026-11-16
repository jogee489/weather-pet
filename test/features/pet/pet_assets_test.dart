import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';
import 'package:weather_pet/core/models/pet_character.dart';
import 'package:weather_pet/core/models/pet_state.dart';

/// Every character must ship an animation with enter / loop / exit segments
/// for every weather state, or the pet freezes when that weather arrives.
void main() {
  for (final character in PetCharacter.all) {
    group('${character.id} animation', () {
      late LottieComposition composition;

      setUpAll(() async {
        final file = File(character.lottieAsset);
        expect(file.existsSync(), isTrue,
            reason: '${character.lottieAsset} is missing');
        composition = await LottieComposition.fromBytes(file.readAsBytesSync());
      });

      for (final state in PetState.values) {
        test('has enter, loop and exit for ${state.name}', () {
          for (final part in const ['enter', 'loop', 'exit']) {
            final marker = composition.getMarker('${state.name}.$part');
            expect(marker, isNotNull,
                reason: 'missing marker ${state.name}.$part');
            expect(marker!.durationFrames, greaterThan(0));
            expect(marker.end, lessThanOrEqualTo(1.0));
          }
        });
      }

      test('enter flows straight into loop, loop into exit', () {
        for (final state in PetState.values) {
          final enter = composition.getMarker('${state.name}.enter')!;
          final loop = composition.getMarker('${state.name}.loop')!;
          final exit = composition.getMarker('${state.name}.exit')!;
          expect(enter.startFrame + enter.durationFrames, loop.startFrame);
          expect(loop.startFrame + loop.durationFrames, exit.startFrame);
        }
      });

      test('stays within the 200 KB size budget', () {
        expect(File(character.lottieAsset).lengthSync(), lessThan(200 * 1024));
      });
    });
  }
}
