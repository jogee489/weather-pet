import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/location_service.dart';

typedef LatLon = ({double lat, double lon});

/// Resolves and caches the device's current position.
/// Re-fetching is triggered by calling [LocationNotifier.refresh].
class LocationNotifier extends AsyncNotifier<LatLon> {
  @override
  Future<LatLon> build() async {
    return const LocationService().getCurrentLocation();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }

  /// Override with a manually selected city (from SearchScreen).
  Future<void> setManual(LatLon location) async {
    await const LocationService().saveLocation(location);
    state = AsyncData(location);
  }
}

final locationProvider =
    AsyncNotifierProvider<LocationNotifier, LatLon>(LocationNotifier.new);
