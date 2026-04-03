import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Resolves and caches the device's current (lat, lon).
/// Implemented in Phase 2.
class LocationNotifier
    extends AsyncNotifier<({double lat, double lon})> {
  @override
  Future<({double lat, double lon})> build() async {
    // TODO Phase 2: use LocationService + SharedPreferences fallback
    throw UnimplementedError('LocationNotifier — implemented in Phase 2');
  }
}

final locationProvider =
    AsyncNotifierProvider<LocationNotifier, ({double lat, double lon})>(
  LocationNotifier.new,
);
