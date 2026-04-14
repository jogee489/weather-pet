import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:weather_pet/features/search/search_screen.dart';

Widget _wrap(Widget child) {
  // GoRouter is required because SearchScreen calls context.go('/home')
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, __) => child),
      GoRoute(
          path: '/home', builder: (_, __) => const Scaffold(body: Text('Home'))),
    ],
  );
  return ProviderScope(child: MaterialApp.router(routerConfig: router));
}

void main() {
  group('SearchScreen', () {
    testWidgets('shows Search heading', (tester) async {
      await tester.pumpWidget(_wrap(const SearchScreen()));
      await tester.pump();
      expect(find.text('Search'), findsOneWidget);
    });

    testWidgets('shows search text field', (tester) async {
      await tester.pumpWidget(_wrap(const SearchScreen()));
      await tester.pump();
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('shows prompt text when no query entered', (tester) async {
      await tester.pumpWidget(_wrap(const SearchScreen()));
      await tester.pump();
      expect(find.text('Type a city name to search'), findsOneWidget);
    });

    testWidgets('shows hint text in the text field', (tester) async {
      await tester.pumpWidget(_wrap(const SearchScreen()));
      await tester.pump();
      expect(find.text('Search for a city…'), findsOneWidget);
    });
  });
}
