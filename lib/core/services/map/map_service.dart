import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../../my_local_storage.dart';
import '../../constants/app_icons.dart';

class MapService {
  static final MapService instance = MapService._();
  MapService._();

  MapboxMap? map;

  PointAnnotationManager? _pointManager;
  final List<PointAnnotation> _placeMarkers = [];
  PointAnnotation? _currentMarker;
  final mapReady = Completer<void>();

  void setMap(MapboxMap m) async {
    map = m;
    map!.gestures.updateSettings(GesturesSettings(pitchEnabled: false, rotateEnabled: false));
    map!.scaleBar.updateSettings(
      ScaleBarSettings(
        enabled: false, // ✅ tắt scale bar
      ),
    );
    // onmap
    _pointManager = await map!.annotations.createPointAnnotationManager();
  }

  //==================================================
  Future<geo.Position> getUserPosition() async {
    final pos = await geo.Geolocator.getCurrentPosition(
      desiredAccuracy: geo.LocationAccuracy.high,
    );

    return pos;
  }

  //==================================================
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

  Future<void> flyToPlace(num lng, num lat) async {
    if (map == null) return;

    final userLatLng = Point(coordinates: Position(lng, lat));

    map!.flyTo(
      CameraOptions(center: userLatLng, zoom: 10),
      MapAnimationOptions(duration: 500),
    );
  }

  //==================================================
  Future<void> onSelectCurrentPlace() async {
    final pos = await geo.Geolocator.getCurrentPosition(
      desiredAccuracy: geo.LocationAccuracy.high,
    );
  }

  //==================================================
  void onSelectPlaceOnMap(MapContentGestureContext context) async {
    if (map == null) return;

    // context.point là Point (GeoJSON)
    final Position pos = context.point.coordinates;

    debugPrint("Select pos: long${pos.lng} ----- lat${pos.lat}");

    addOrMoveMarker(pos);
  }

  //==================================================
  Future<void> addOrMoveMarker(Position pos) async {
    if (_pointManager == null) return;

    if (_currentMarker != null) {
      await _pointManager!.delete(_currentMarker!);
      _currentMarker = null;
    }

    final ByteData bytes = await rootBundle.load(AppIcons.location);
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
        iconSize: 1,
      ),
    );

    // Lưu lại để có thể xóa sau
    _currentMarker = marker;
  }

  //==================================================
  // Zoom out
  Future<void> zoomOut() async {
    if (map == null) return;

    final camera = await map!.getCameraState();
    final currentZoom = camera.zoom;

    map!.flyTo(
      CameraOptions(zoom: currentZoom - 9.2),
      MapAnimationOptions(duration: 300),
    );
  }

  //==================================================
  // Add from place annotation to map
  Future<void> addPlaceAnnotations() async {
    if (map == null) return;

    // Nếu chưa có manager thì tạo một cái riêng cho places
    _pointManager ??= await map!.annotations.createPointAnnotationManager();

    // Xoá toàn bộ marker cũ của danh sách place
    for (var marker in _placeMarkers) {
      await _pointManager!.delete(marker);
    }
    _placeMarkers.clear();

    // Load ảnh marker
    final ByteData bytes = await rootBundle.load(AppIcons.location);
    final Uint8List imageData = bytes.buffer.asUint8List();

    // Tạo marker cho từng place
    for (var place in MyLocalStorage.places) {
      final marker = await _pointManager!.create(
        PointAnnotationOptions(
          geometry: Point(coordinates: Position(place.lng, place.lat)),
          image: imageData,
          iconSize: 1,
        ),
      );

      _placeMarkers.add(marker);
    }
  }
}
