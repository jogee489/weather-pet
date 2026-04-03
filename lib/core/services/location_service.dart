import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kLatKey = 'last_lat';
const _kLonKey = 'last_lon';

typedef LatLon = ({double lat, double lon});

/// GPS location detection and permission handling.
/// Falls back to the last-saved location if GPS is unavailable.
class LocationService {
  const LocationService();

  /// Requests location permission and returns the current position.
  /// On web, geolocator uses the browser geolocation API.
  /// Falls back to last-cached position if permission is denied or GPS fails.
  /// Throws [LocationServiceException] if no location is available at all.
  Future<LatLon> getCurrentLocation() async {
    // Check if location services are enabled
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return _loadCachedOrThrow('Location services are disabled.');
    }

    // Request permission
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return _loadCachedOrThrow('Location permission denied.');
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low, // city-level is enough for weather
          timeLimit: Duration(seconds: 10),
        ),
      );
      final result = (lat: position.latitude, lon: position.longitude);
      await _cache(result);
      return result;
    } catch (_) {
      return _loadCachedOrThrow('Could not determine current position.');
    }
  }

  /// Cache a known location (e.g. after a manual city search).
  Future<void> saveLocation(LatLon location) => _cache(location);

  Future<void> _cache(LatLon location) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kLatKey, location.lat);
    await prefs.setDouble(_kLonKey, location.lon);
  }

  Future<LatLon> _loadCachedOrThrow(String reason) async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble(_kLatKey);
    final lon = prefs.getDouble(_kLonKey);
    if (lat != null && lon != null) return (lat: lat, lon: lon);
    throw LocationServiceException('$reason No cached location available.');
  }
}

class LocationServiceException implements Exception {
  const LocationServiceException(this.message);
  final String message;

  @override
  String toString() => 'LocationServiceException: $message';
}
