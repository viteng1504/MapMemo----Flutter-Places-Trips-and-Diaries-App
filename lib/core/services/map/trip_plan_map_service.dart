import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../../features/places/domain/entities/place_position.dart';
import '../../constants/app_icons.dart';

class TripPlanMapService {
  TripPlanMapService();

  MapboxMap? map;

  PointAnnotationManager? _pointManager;
  PointAnnotation? _currentMarker;

  bool get isSelectOnMap => _currentMarker != null;

  void setMap(MapboxMap m) async {
    map = m;
    map!.gestures.updateSettings(
      GesturesSettings(pitchEnabled: false, pinchToZoomEnabled: true),
    );
    map!.scaleBar.updateSettings(
      ScaleBarSettings(
        enabled: false, // tắt scale bar
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

  Future<PlacePosition> onGetSelectPlacePosition() async {
    // if (_currentMarker == null) {
    //   throw Exception("Marker chưa được chọn!");
    // }

    final pos = _currentMarker!.geometry.coordinates;

    return PlacePosition(lat: pos.lat.toDouble(), lng: pos.lng.toDouble());
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

    final ByteData bytes = await rootBundle.load(AppIcons.location);
    final Uint8List imageData = bytes.buffer.asUint8List();

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
}
