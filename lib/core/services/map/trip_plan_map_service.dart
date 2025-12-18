import 'dart:convert';

import 'package:geolocator/geolocator.dart' as geo;
import 'package:http/http.dart' as http;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../../features/places/domain/entities/place_position.dart';
import '../../../features/trips/domain/entities/planner/planner_place_entity.dart';
import '../../constants/app_api.dart';

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

  Future<void> flyToUser() async {
    if (map == null) return;

    final pos = await getUserPosition();
    final userLatLng = Point(
      coordinates: Position(pos.longitude, pos.latitude),
    );

    map!.flyTo(
      CameraOptions(center: userLatLng, zoom: 6),
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

  Future<PlannerPlaceEntity?> onSelectPlaceOnMap(
    MapContentGestureContext ctx,
  ) async {
    if (map == null) return null;

    // 1) Lấy lat/lng tại điểm tap
    // MapContentGestureContext thường có sẵn coordinate:

    final coord = ctx.point.coordinates; // Point(lat,lng)
    final double lng = coord.lng.toDouble();
    final double lat = coord.lat.toDouble();

    // 2) Set marker tại vị trí tap
    // await _setMarker(lat: lat, lng: lng);

    // 3) Call Mapbox reverse geocoding
    final place = await _reverseGeocode(lat: lat, lng: lng);

    print("place info============================================");
    print(place.toString());

    final latLng = Point(coordinates: Position(lng, lat));
    map!.flyTo(
      CameraOptions(center: latLng, zoom: 12),
      MapAnimationOptions(duration: 1000),
    );

    return place;
  }

  Future<void> _setMarker({required num lat, required num lng}) async {
    final pm = _pointManager;
    if (pm == null) return;

    // Nếu đã có marker thì xoá marker cũ
    if (_currentMarker != null) {
      await pm.delete(_currentMarker!);
      _currentMarker = null;
    }

    _currentMarker = await pm.create(
      PointAnnotationOptions(
        geometry: Point(coordinates: Position(lng, lat)),
        // nếu bạn có icon riêng thì set image ở đây
      ),
    );
  }

  final _mapboxToken = AppApi.mapboxAccessToken;

  Future<PlannerPlaceEntity?> _reverseGeocode({
    required double lng,
    required double lat,
  }) async {
    final url = Uri.https(
      'api.mapbox.com',
      '/geocoding/v5/mapbox.places/$lng,$lat.json',
      {
        'access_token': _mapboxToken,
        'limit': '1',
        // 'language': 'vi', // nếu bạn muốn ưu tiên tiếng Việt
      },
    );

    final res = await http.get(url);

    print(res.body);

    if (res.statusCode != 200) {
      // TODO: log(res.body);
      return null;
    }

    final data = jsonDecode(res.body);
    if (data is! Map<String, dynamic>) return null;

    final features = data['features'] as List;
    if (features.isEmpty) return null;

    final feature = _pickBestFeature(features);
    if (feature == null) return null;

    // name hiển thị: ưu tiên 'text', fallback 'place_name'
    final name = feature['place_name'] ?? 'Unknown place';

    // country + iso
    String country = '';
    String? isoCode;

    final context = feature['context'];
    if (context is List) {
      for (final c in context) {
        if (c is Map<String, dynamic>) {
          final id = (c['id'] as String?) ?? '';
          if (id.startsWith('country')) {
            country = (c['text'] as String?) ?? '';
            isoCode = (c['short_code'] as String?)?.toUpperCase();
            break;
          }
        }
      }
    }

    // Fallback: đôi khi Mapbox trả short_code ở properties
    if (isoCode == null) {
      final props = feature['properties'];
      if (props is Map<String, dynamic>) {
        isoCode = (props['short_code'] as String?)?.toUpperCase();
      }
    }

    final flagUrl = (isoCode != null && isoCode.isNotEmpty)
        ? 'https://flagsapi.com/$isoCode/flat/32.png'
        : '';

    return PlannerPlaceEntity(
      country: country,
      countryIconUrl: flagUrl, // nếu class bạn dùng imageUrl làm icon/flag
      name: name,
      lat: lat,
      lng: lng,
    );
  }

  Map<String, dynamic>? _pickBestFeature(List features) {
    const preferredTypes = ['poi', 'place', 'locality', 'neighborhood'];

    for (final type in preferredTypes) {
      for (final f in features) {
        if (f is Map<String, dynamic>) {
          final types = f['place_type'];
          if (types is List && types.contains(type)) {
            return f;
          }
        }
      }
    }

    // fallback cuối cùng
    return features.firstWhere(
      (f) => f is Map<String, dynamic>,
      orElse: () => null,
    );
  }
}
