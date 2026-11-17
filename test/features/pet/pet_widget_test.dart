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

/// Advances time in 16 ms frames. One big pump is a single tick, which would
/// leave every animation that starts during it stuck on its first frame.
Future<void> _advance(WidgetTester tester, int ms) async {
  for (var t = 0; t < ms; t += 16) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

/// Pumps in 16 ms steps and returns every visible cut: a frame jump that is
/// not a loop wrapping round and not a hop between two neutral poses (the
/// start of an enter, the end of an exit — the pet looks the same in both).
///
/// [since] is the progress seen before the change under test, so a cut made
/// in the very frame the widget is rebuilt is caught too.
Future<List<String>> _cuts(WidgetTester tester, LottieComposition c,
    Duration length,
    {required double since}) async {
  const slack = 3.5; // frames: one 16 ms step at the 4x hurry speed, and a bit
  final total = c.durationFrames;
  final neutral = <double>[
    for (final s in PetState.values) ...[
      c.getMarker('${s.name}.enter')!.start * total,
      c.getMarker('${s.name}.exit')!.end * total,
    ],
  ];
  bool nearNeutral(double f) => neutral.any((n) => (f - n).abs() <= slack);
  bool wrapped(double from, double to) => PetState.values.any((s) {
        final loop = c.getMarker('${s.name}.loop')!;
        return (from - loop.end * total).abs() <= slack &&
            (to - loop.start * total).abs() <= slack;
      });

  final cuts = <String>[];
  var last = since * total;
  for (var ms = 0; ms < length.inMilliseconds; ms += 16) {
    await tester.pump(const Duration(milliseconds: 16));
    final now = _progress(tester) * total;
    if ((now - last).abs() > slack &&
        !wrapped(last, now) &&
        !(nearNeutral(last) && nearNeutral(now))) {
      cuts.add('${last.toStringAsFixed(1)} -> ${now.toStringAsFixed(1)}');
    }
    last = now;
  }
  return cuts;
}

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

  testWidgets('flipping back while the old loop hurries out does not cut',
      (tester) async {
    await tester.pumpWidget(_pet(PetState.sunny));
    final c = await _load(tester);
    await _advance(tester, 2000); // well into sunny.loop

    await tester.pumpWidget(_pet(PetState.rainy));
    await _advance(tester, 48); // hurrying sunny.loop
    expect(_within(_progress(tester), c.getMarker('sunny.loop')!), isTrue);
    final before = _progress(tester);
    await tester.pumpWidget(_pet(PetState.sunny));

    expect(await _cuts(tester, c, const Duration(seconds: 3),
            since: before), isEmpty);
    expect(_within(_progress(tester), c.getMarker('sunny.loop')!), isTrue);
  });

  testWidgets('flipping back during the exit does not cut', (tester) async {
    await tester.pumpWidget(_pet(PetState.sunny));
    final c = await _load(tester);
    await _advance(tester, 2000);

    await tester.pumpWidget(_pet(PetState.rainy));
    final exit = c.getMarker('sunny.exit')!;
    for (var i = 0; i < 200 && !_within(_progress(tester), exit); i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    await _advance(tester, 100); // mid-exit
    expect(_within(_progress(tester), exit), isTrue);
    final before = _progress(tester);
    await tester.pumpWidget(_pet(PetState.sunny));

    expect(await _cuts(tester, c, const Duration(seconds: 3),
            since: before), isEmpty);
    expect(_within(_progress(tester), c.getMarker('sunny.loop')!), isTrue);
  });

  testWidgets('a third state arriving during an enter does not cut',
      (tester) async {
    await tester.pumpWidget(_pet(PetState.sunny));
    final c = await _load(tester);
    await _advance(tester, 250); // mid sunny.enter
    expect(_within(_progress(tester), c.getMarker('sunny.enter')!), isTrue);
    final before = _progress(tester);
    await tester.pumpWidget(_pet(PetState.rainy));

    expect(await _cuts(tester, c, const Duration(seconds: 3),
            since: before), isEmpty);
    expect(_within(_progress(tester), c.getMarker('rainy.loop')!), isTrue);
  });

  testWidgets('a third state arriving during an exit does not cut',
      (tester) async {
    await tester.pumpWidget(_pet(PetState.sunny));
    final c = await _load(tester);
    await _advance(tester, 2000);

    await tester.pumpWidget(_pet(PetState.rainy));
    final exit = c.getMarker('sunny.exit')!;
    for (var i = 0; i < 200 && !_within(_progress(tester), exit); i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    await _advance(tester, 200); // two thirds through the exit
    final before = _progress(tester);
    await tester.pumpWidget(_pet(PetState.snowy));

    expect(await _cuts(tester, c, const Duration(seconds: 3),
            since: before), isEmpty);
    expect(_within(_progress(tester), c.getMarker('snowy.loop')!), isTrue);
  });

  group('wind gust', () {
    test('fades in and out instead of switching', () {
      final gust = GustEnvelope();
      expect(gust.level(0), 0);
      gust.aim(1, 1000);
      expect(gust.level(1000), 0);
      expect(gust.level(1000 + GustEnvelope.rampMs / 2), closeTo(0.5, 0.01));
      expect(gust.level(1000 + GustEnvelope.rampMs), 1);
      gust.aim(0, 5000);
      expect(gust.level(5000), 1);
      expect(gust.level(5000 + GustEnvelope.rampMs + 1), 0);
    });

    test('turning round mid-fade starts from the current level', () {
      final gust = GustEnvelope()..aim(1, 0);
      final half = gust.level(GustEnvelope.rampMs / 2);
      gust.aim(0, GustEnvelope.rampMs / 2);
      expect(gust.level(GustEnvelope.rampMs / 2), closeTo(half, 1e-9));
    });

    test('intensity outside 0-1 is clamped', () {
      double peak(double intensity) => gustOffset(
          degrees: 9, intensity: intensity, level: 1, seconds: 0.05, phase: 0);
      expect(peak(5), closeTo(peak(1), 1e-9));
      expect(peak(-3), 0);
      expect(peak(1).abs(), lessThanOrEqualTo(9));
    });
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
