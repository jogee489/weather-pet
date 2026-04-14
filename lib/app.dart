import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'features/forecast/forecast_screen.dart';
import 'features/home/home_screen.dart';
import 'features/search/search_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/splash/splash_screen.dart';
import 'home_widget/widget_provider.dart';

class WeatherPetApp extends ConsumerWidget {
  const WeatherPetApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Keep the home screen widget in sync with live weather data.
    ref.watch(widgetSyncProvider);

    return MaterialApp.router(
      title: 'Weather Pet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4A90D9),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'SF Pro Display',
      ),
      routerConfig: _router,
    );
  }
}

/// Fade transition used for splash → shell and between all shell tabs.
Page<void> _fadePage(BuildContext context, GoRouterState state, Widget child) =>
    CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 350),
      reverseTransitionDuration: const Duration(milliseconds: 250),
      transitionsBuilder: (_, animation, __, child) => FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
        child: child,
      ),
    );

final _router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      pageBuilder: (context, state) =>
          _fadePage(context, state, const SplashScreen()),
    ),
    ShellRoute(
      builder: (context, state, child) => _NavShell(child: child),
      routes: [
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) =>
              _fadePage(context, state, const HomeScreen()),
        ),
        GoRoute(
          path: '/forecast',
          pageBuilder: (context, state) =>
              _fadePage(context, state, const ForecastScreen()),
        ),
        GoRoute(
          path: '/search',
          pageBuilder: (context, state) =>
              _fadePage(context, state, const SearchScreen()),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) =>
              _fadePage(context, state, const SettingsScreen()),
        ),
      ],
    ),
  ],
);

class _NavShell extends StatelessWidget {
  const _NavShell({required this.child});

  final Widget child;

  static const _tabs = [
    (icon: Icons.cloud_outlined, label: 'Weather', path: '/home'),
    (icon: Icons.calendar_today_outlined, label: 'Forecast', path: '/forecast'),
    (icon: Icons.search, label: 'Search', path: '/search'),
    (icon: Icons.settings_outlined, label: 'Settings', path: '/settings'),
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final idx = _tabs.indexWhere((t) => location.startsWith(t.path));
    return idx < 0 ? 0 : idx;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex(context),
        onDestinationSelected: (i) => context.go(_tabs[i].path),
        destinations: _tabs
            .map(
              (t) => NavigationDestination(
                icon: Icon(t.icon),
                label: t.label,
              ),
            )
            .toList(),
      ),
    );
  }
}
