import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationHelper {
  static Future<Map<String, dynamic>> getCurrentLocation() async {
    try {
      final permission = await Permission.location.request();
      if (!permission.isGranted) {
        return {
          'latitude': 0.0,
          'longitude': 0.0,
          'address': 'Location permission not granted',
        };
      }

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return {
          'latitude': 0.0,
          'longitude': 0.0,
          'address': 'Location services are disabled',
        };
      }

      LocationPermission permission2 = await Geolocator.checkPermission();
      if (permission2 == LocationPermission.denied) {
        permission2 = await Geolocator.requestPermission();
        if (permission2 == LocationPermission.denied) {
          return {
            'latitude': 0.0,
            'longitude': 0.0,
            'address': 'Location permissions are denied',
          };
        }
      }

      if (permission2 == LocationPermission.deniedForever) {
        return {
          'latitude': 0.0,
          'longitude': 0.0,
          'address': 'Location permissions are permanently denied',
        };
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'address': '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}',
      };
    } catch (e) {
      return {
        'latitude': 0.0,
        'longitude': 0.0,
        'address': 'Error getting location: $e',
      };
    }
  }

  static Future<double> calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) async {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }
}