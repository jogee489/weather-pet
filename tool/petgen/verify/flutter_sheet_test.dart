// Renders three frames of every loop with Flutter's own Lottie player, so the
// result can be laid next to lottie-web's rendering of the same frames.
//
//   PET=cat OUT=/abs/path/cat_flutter.png \
//     flutter test tool/petgen/verify/flutter_sheet_test.dart --update-goldens
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';

void main() {
  final pet = Platform.environment['PET'];
  final out = Platform.environment['OUT'];

  testWidgets('contact sheet', (tester) async {
    if (pet == null || out == null) return; // only runs when asked for
    late LottieComposition c;
    await tester.runAsync(() async {
      c = await LottieComposition.fromBytes(
          File('assets/lottie/$pet/$pet.json').readAsBytesSync());
    });
    final loops = c.markers.where((m) => m.name.endsWith('.loop')).toList();
    const cell = 150.0, cols = 3;
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = Size(cols * cell, loops.length * cell);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: RepaintBoundary(
          child: ColoredBox(
        color: const Color(0xFFBFDDF2),
        child: Column(children: [
          for (final m in loops)
            Row(children: [
              for (var i = 0; i < cols; i++)
                Lottie(
                  composition: c,
                  width: cell,
                  height: cell,
                  // Whole frames only, so both players sample the same instant.
                  controller: AlwaysStoppedAnimation((m.startFrame +
                          (m.durationFrames * i / cols).floorToDouble()) /
                      c.durationFrames),
                ),
            ]),
        ]),
      )),
    ));
    await expectLater(
        find.byType(RepaintBoundary).first, matchesGoldenFile(out));
  });
}
