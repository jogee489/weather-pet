import 'dart:convert';
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

      // Group names under [node], by walking the raw shape tree.
      Set<String> names(Map<String, dynamic> node) => {
            if (node['nm'] != null) node['nm'] as String,
            for (final child in (node['it'] as List? ?? const []))
              if (child is Map<String, dynamic> && child['ty'] == 'gr')
                ...names(child),
          };

      Map<String, dynamic>? group(Map<String, dynamic> node, String name) {
        if (node['nm'] == name) return node;
        for (final child in (node['it'] as List? ?? const [])) {
          if (child is Map<String, dynamic> && child['ty'] == 'gr') {
            final hit = group(child, name);
            if (hit != null) return hit;
          }
        }
        return null;
      }

      test('the live blink squashes open eyes only, never brows', () {
        final doc = jsonDecode(File(character.lottieAsset).readAsStringSync())
            as Map<String, dynamic>;
        final root = (doc['layers'] as List).first['shapes'][0]
            as Map<String, dynamic>;
        for (final side in const ['L', 'R']) {
          final live = group(root, 'eye${side}Blink');
          expect(live, isNotNull, reason: 'eye${side}Blink is missing');
          final inside = names(live!);
          for (final shut in const ['sleep', 'happy', 'squint']) {
            expect(inside, isNot(contains('eye${side}_$shut')));
          }
          expect(names(group(root, 'eye$side')!),
              isNot(contains('brow$side')));
          expect(group(root, 'brow$side'), isNotNull);
        }
      });

      test('stays within the 200 KB size budget', () {
        expect(File(character.lottieAsset).lengthSync(), lessThan(200 * 1024));
      });
    });
  }
}
