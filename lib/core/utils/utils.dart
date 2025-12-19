import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:permission_handler/permission_handler.dart';

class Utils {
  static Future<bool> checkLocationPermission() async {
    final status = await Permission.location.request();

    if (status.isGranted) {
      try {
        final position = await geo.Geolocator.getCurrentPosition(
          desiredAccuracy: geo.LocationAccuracy.high,
        );
        debugPrint("Lat: ${position.latitude}, Lng: ${position.longitude}");
        return true;
      } catch (e) {
        debugPrint("Geolocator error: $e");
      }
    } else {
      debugPrint("Location permission not granted");
    }

    return false;
  }

  static String fmt(DateTime? d) {
    if (d == null) return "Optional";
    return "${d.day} Th${d.month}, ${d.year}";
  }
}
