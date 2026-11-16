import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';
import 'package:weather_pet/core/models/pet_character.dart';
import 'package:weather_pet/core/models/pet_state.dart';
import 'package:weather_pet/features/pet/pet_widget.dart';

/// Progress (0–1) of the Lottie currently on screen.
double _progress(WidgetTester tester) =>
    tester.widget<Lottie>(find.byType(Lottie)).controller!.value;

Future<LottieComposition> _load(WidgetTester tester) async {
  late LottieComposition composition;
  await tester.runAsync(() async {
    composition = await LottieComposition.fromBytes(
        File(PetCharacter.defaultCharacter.lottieAsset).readAsBytesSync());
    // Let the widget's own asset load finish too.
    await Future<void>.delayed(const Duration(milliseconds: 200));
  });
  await tester.pump();
  return composition;
}

Widget _pet(PetState state, {bool reduceMotion = false}) => MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: reduceMotion),
        child: Center(
          child: PetWidget(
            character: PetCharacter.defaultCharacter,
            petState: state,
          ),
        ),
      ),
    );

bool _within(double value, Marker marker) =>
    value >= marker.start - 1e-6 && value <= marker.end + 1e-6;

void main() {
  testWidgets('plays enter, then stays inside the loop', (tester) async {
    await tester.pumpWidget(_pet(PetState.sunny));
    final c = await _load(tester);
    expect(find.byType(Lottie), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 100));
    expect(_within(_progress(tester), c.getMarker('sunny.enter')!), isTrue);

    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 250));
    }
    expect(_within(_progress(tester), c.getMarker('sunny.loop')!), isTrue);
  });

  testWidgets('a weather change plays exit, enter, then the new loop',
      (tester) async {
    await tester.pumpWidget(_pet(PetState.sunny));
    final c = await _load(tester);
    await tester.pump(const Duration(seconds: 2));

    await tester.pumpWidget(_pet(PetState.rainy));
    final seen = <String>{};
    for (var i = 0; i < 120; i++) {
      await tester.pump(const Duration(milliseconds: 50));
      final p = _progress(tester);
      for (final name in const ['sunny.exit', 'rainy.enter', 'rainy.loop']) {
        final m = c.getMarker(name)!;
        if (p > m.start && p < m.end) seen.add(name);
      }
    }
    expect(seen, containsAll(['sunny.exit', 'rainy.enter', 'rainy.loop']));
    expect(_within(_progress(tester), c.getMarker('rainy.loop')!), isTrue);
  });

  testWidgets('reduce motion holds one still pose', (tester) async {
    await tester.pumpWidget(_pet(PetState.windy, reduceMotion: true));
    final c = await _load(tester);
    final start = c.getMarker('windy.loop')!.start;
    expect(_progress(tester), closeTo(start, 1e-6));
    await tester.pump(const Duration(seconds: 3));
    expect(_progress(tester), closeTo(start, 1e-6));
  });

  testWidgets('describes itself to screen readers', (tester) async {
    await tester.pumpWidget(_pet(PetState.snowy));
    expect(find.bySemanticsLabel('Cat, snowy'), findsOneWidget);
  });
}
