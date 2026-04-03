/// GPS location detection and permission handling.
/// Implemented in Phase 2.
class LocationService {
  const LocationService();

  /// Requests location permission and returns the current (lat, lon).
  /// Falls back to the last-saved location if GPS is unavailable.
  Future<({double lat, double lon})> getCurrentLocation() {
    // TODO Phase 2: implement with geolocator package
    throw UnimplementedError(
        'LocationService.getCurrentLocation — implemented in Phase 2');
  }
}
