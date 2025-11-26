import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../constants/app_icons.dart';

class AddPlaceMapService {
  AddPlaceMapService();

  MapboxMap? map;

  PointAnnotationManager? _pointManager;
  PointAnnotation? _currentMarker;

  void setMap(MapboxMap m) async {
    map = m;
    map!.gestures.updateSettings(GesturesSettings(pitchEnabled: false));
    map!.scaleBar.updateSettings(
      ScaleBarSettings(
        enabled: false, // ✅ tắt scale bar
      ),
    );
    // onmap
    _pointManager = await map!.annotations.createPointAnnotationManager();
  }

  Future<geo.Position> getUserPosition() async {
    final pos = await geo.Geolocator.getCurrentPosition(
      desiredAccuracy: geo.LocationAccuracy.high,
    );

    return pos;
  }

  Future<void> flyToUser(geo.Position pos) async {
    if (map == null) return;

    final userLatLng = Point(
      coordinates: Position(pos.longitude, pos.latitude),
    );

    map!.flyTo(
      CameraOptions(center: userLatLng, zoom: 10),
      MapAnimationOptions(duration: 1000),
    );
  }

  Future<void> onSelectCurrentPlace() async {
    final pos = await geo.Geolocator.getCurrentPosition(
      desiredAccuracy: geo.LocationAccuracy.high,
    );
  }

  void onSelectPlaceOnMap(MapContentGestureContext context) async {
    if (map == null) return;

    // context.point là Point (GeoJSON)
    final Position pos = context.point.coordinates;

    debugPrint("Select pos: long${pos.lng} ----- lat${pos.lat}");

    addOrMoveMarker(pos);
  }

  Future<void> addOrMoveMarker(Position pos) async {
    if (_pointManager == null) return;

    if (_currentMarker != null) {
      await _pointManager!.delete(_currentMarker!);
      _currentMarker = null;
    }

    final ByteData bytes = await rootBundle.load(AppIcons.facebook);
    final Uint8List imageData = bytes.buffer.asUint8List();

    // Create a PointAnnotationOptions
    // PointAnnotationOptions pointAnnotationOptions = PointAnnotationOptions(
    //   geometry: Point(
    //     coordinates: Position(pos.lng, pos.lat),
    //   ), // Example coordinates
    //   image: imageData,
    //   iconSize: 0.5,
    // );

    // // Get current pos
    // _currentMarker = await _pointManager!.create(pointAnnotationOptions);
    // // Add the annotation to the map
    // _pointManager?.create(pointAnnotationOptions);

    // Tạo marker mới
    final marker = await _pointManager!.create(
      PointAnnotationOptions(
        geometry: Point(coordinates: Position(pos.lng, pos.lat)),
        image: imageData,
        iconSize: 0.5,
      ),
    );

    // Lưu lại để có thể xóa sau
    _currentMarker = marker;
  }
}
