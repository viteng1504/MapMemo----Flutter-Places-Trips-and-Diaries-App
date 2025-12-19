import 'dart:convert';

import 'package:flutter/material.dart';
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

  Future<void> flyToPosition(num lng, num lat) async {
    if (map == null) return;

    final latLng = Point(coordinates: Position(lng, lat));

    // 1️⃣ Zoom out nhanh
    await map!.flyTo(
      CameraOptions(
        zoom: 6, // zoom out
      ),
      MapAnimationOptions(duration: 3000),
    );

    // 2️⃣ Zoom in + bay tới điểm
    await map!.flyTo(
      CameraOptions(center: latLng, zoom: 11),
      MapAnimationOptions(duration: 2400),
    );
  }

  Future<PlacePosition> onGetSelectPlacePosition() async {
    // if (_currentMarker == null) {
    //   throw Exception("Marker chưa được chọn!");
    // }

    final pos = _currentMarker!.geometry.coordinates;

    return PlacePosition(lat: pos.lat.toDouble(), lng: pos.lng.toDouble());
  }

  // Select on map========================================================================================
  final String _sourceId = "places-source";
  final String _circleLayerId = "place-circle-layer";
  final String _indexLayerId = "place-index-layer";
  final String _nameLayerId = "place-name-layer";

  final List<Map<String, dynamic>> features = [
    {
      "type": "Feature",
      "properties": {"index": 1, "name": "Nana Pickleball"},
      "geometry": {
        "type": "Point",
        "coordinates": [108.2068, 16.0471],
      },
    },
    {
      "type": "Feature",
      "properties": {"index": 2, "name": "Dragon Bridge"},
      "geometry": {
        "type": "Point",
        "coordinates": [108.2272, 16.0614],
      },
    },
    {
      "type": "Feature",
      "properties": {"index": 3, "name": "My Khe Beach"},
      "geometry": {
        "type": "Point",
        "coordinates": [108.2471, 16.0545],
      },
    },
  ];
  Map<String, dynamic>? _tempFeature;
  int _counter = 0;
  bool _styleReady = false;

  Future<void> _updatePlacesSource() async {
    if (map == null) return;

    final newFeature = [...features, _tempFeature];
    _tempFeature = null;

    final fc = {"type": "FeatureCollection", "features": newFeature};

    await map!.style.setStyleSourceProperty(_sourceId, "data", fc);
  }

  Future<void> ensurePlaceLayers() async {
    if (map == null) return;
    final style = map!.style;

    // Nếu đã tạo rồi thì thôi
    if (_styleReady) return;

    // Source
    final hasSource = await style.styleSourceExists(_sourceId);
    if (!hasSource) {
      await style.addSource(
        GeoJsonSource(
          id: _sourceId,
          data: jsonEncode({"type": "FeatureCollection", "features": []}),
        ),
      );
    }

    // Circle layer
    if (!await style.styleLayerExists(_circleLayerId)) {
      await style.addLayer(
        CircleLayer(
          id: _circleLayerId,
          sourceId: _sourceId,
          circleRadius: 12,
          circleColor: Colors.blue.value,
          circleStrokeColor: Colors.white.value,
          circleStrokeWidth: 2,
        ),
      );
    }

    // Index text (số)
    if (!await style.styleLayerExists(_indexLayerId)) {
      await style.addLayer(
        SymbolLayer(
          id: _indexLayerId,
          sourceId: _sourceId,
          // ✅ Khuyên dùng expression để chắc chắn là string
          textFieldExpression: [
            "to-string",
            ["get", "index"],
          ],
          textSize: 14,
          textColor: Colors.white.value,
          textHaloColor: Colors.black.value,
          textHaloWidth: 1.5,
          textAnchor: TextAnchor.CENTER,
          textAllowOverlap: true,
        ),
      );
    }

    // Name text (tên dưới)
    // if (!await style.styleLayerExists(_nameLayerId)) {
    //   await style.addLayer(
    //     SymbolLayer(
    //       id: _nameLayerId,
    //       sourceId: _sourceId,
    //       textField: "{name}",
    //       textSize: 12,
    //       textColor: Colors.white.value,
    //       textHaloColor: Colors.black.value,
    //       textHaloWidth: 1.2,
    //       textAnchor: TextAnchor.TOP,
    //       textOffset: [0, 1.4],
    //       textAllowOverlap: true,
    //     ),
    //   );
    // }

    _styleReady = true;
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
    final place = await reverseGeocode(lat: lat, lng: lng);

    print("place info============================================");
    print(place.toString());
    final displayName = place?.name ?? "Unknown";

    // Tăng số thứ tự
    _counter++;

    // Add feature mới
    // _features.add({
    //   "type": "Feature",
    //   "properties": {"index": _counter, "name": displayName},
    //   "geometry": {
    //     "type": "Point",
    //     "coordinates": [lng, lat], // ✅ GeoJSON: [lng, lat]
    //   },
    // });
    _tempFeature = {
      "type": "Feature",
      "properties": {"index": _counter, "name": displayName},
      "geometry": {
        "type": "Point",
        "coordinates": [lng, lat], // ✅ GeoJSON: [lng, lat]
      },
    };

    // Update source để map render marker + text
    await _updatePlacesSource();

    final latLng = Point(coordinates: Position(lng, lat));
    map!.flyTo(
      CameraOptions(center: latLng, zoom: 12),
      MapAnimationOptions(duration: 1000),
    );

    return place;
  }

  Future<void> plannerShowPointOnMap({
    required int index,
    required String displayName,
    required double lng,
    required double lat,
  }) async {
    // features.add({
    //   "type": "Feature",
    //   "properties": {"index": index, "name": displayName},
    //   "geometry": {
    //     "type": "Point",
    //     "coordinates": [lng, lat], // ✅ GeoJSON: [lng, lat]
    //   },
    // });
    _tempFeature = {
      "type": "Feature",
      "properties": {"index": index, "name": displayName},
      "geometry": {
        "type": "Point",
        "coordinates": [lng, lat], // ✅ GeoJSON: [lng, lat]
      },
    };

    // Update source để map render marker + text
    await _updatePlacesSource();

    final latLng = Point(coordinates: Position(lng, lat));
    map!.flyTo(
      CameraOptions(center: latLng, zoom: 12),
      MapAnimationOptions(duration: 1000),
    );
  }

  Future<void> setMarker({required num lat, required num lng}) async {
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

  final mapboxToken = AppApi.mapboxAccessToken;

  Future<PlannerPlaceEntity?> reverseGeocode({
    required double lng,
    required double lat,
  }) async {
    final url = Uri.https(
      'api.mapbox.com',
      '/geocoding/v5/mapbox.places/$lng,$lat.json',
      {
        'access_token': mapboxToken,
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

    final feature = pickBestFeature(features);
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

  Map<String, dynamic>? pickBestFeature(List features) {
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
