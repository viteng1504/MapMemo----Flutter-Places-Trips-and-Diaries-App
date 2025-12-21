import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:http/http.dart' as http;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../../features/places/domain/entities/place_position.dart';
import '../../../features/trips/domain/entities/planner/planner_place_entity.dart';
import '../../../features/trips/domain/entities/planner/planner_stop_entity.dart';
import '../../constants/app_api.dart';
import '../../utils/utils.dart';

class TripPlanMapService {
  TripPlanMapService();

  MapboxMap? map;

  PointAnnotationManager? _pointManager;
  PointAnnotation? _currentMarker;

  bool get isSelectOnMap => _currentMarker != null;

  final String _sourceId = "places-source";
  final String _circleLayerId = "place-circle-layer";
  final String _indexLayerId = "place-index-layer";
  final String _nameLayerId = "place-name-layer";
  final String _routeSourceId = "route-source";
  final String _routeLayerId = "route-line-layer";

  List<Map<String, dynamic>> features = [
    // {
    //   "type": "Feature",
    //   "properties": {"index": 1, "name": "Nana Pickleball"},
    //   "geometry": {
    //     "type": "Point",
    //     "coordinates": [108.2068, 16.0471],
    //   },
    // },
    // {
    //   "type": "Feature",
    //   "properties": {"index": 2, "name": "Dragon Bridge"},
    //   "geometry": {
    //     "type": "Point",
    //     "coordinates": [108.2272, 16.0614],
    //   },
    // },
    // {
    //   "type": "Feature",
    //   "properties": {"index": 3, "name": "My Khe Beach"},
    //   "geometry": {
    //     "type": "Point",
    //     "coordinates": [108.2471, 16.0545],
    //   },
    // },
  ];
  Map<String, dynamic>? tempFeature;
  bool styleReady = false;

  Future<void> dispose() async {
    if (map == null) return;

    try {
      final style = map!.style;

      if (await style.styleLayerExists(_circleLayerId)) {
        await style.removeStyleLayer(_circleLayerId);
      }
      if (await style.styleLayerExists(_indexLayerId)) {
        await style.removeStyleLayer(_indexLayerId);
      }
      if (await style.styleSourceExists(_sourceId)) {
        await style.removeStyleSource(_sourceId);
      }
    } catch (_) {}

    map = null;
    styleReady = false;
  }

  Future<void> onStyleReady() async {
    if (map == null || styleReady) return;

    // ⏳ đợi style thật sự sẵn
    await _waitForStyleReady();

    // 🔧 add source + layer
    await ensurePlaceLayers();
    await ensureRouteLayers();

    styleReady = true;
  }

  void setMap(MapboxMap m) async {
    map = m;
    map!.gestures.updateSettings(
      GesturesSettings(
        pitchEnabled: false,
        pinchToZoomEnabled: true,
        rotateEnabled: false,
      ),
    );
    map!.scaleBar.updateSettings(
      ScaleBarSettings(
        enabled: false, // tắt scale bar
      ),
    );
    // onmap
    _pointManager = await map!.annotations.createPointAnnotationManager();

    //create map layers
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
      CameraOptions(center: userLatLng, zoom: 8),
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

  // get feature collection========================================================================================
  Future<void> buildStopsFeatureCollection(
    List<PlannerStopEntity> stops,
  ) async {
    features = stops.map(Utils.convertStopToFeature).toList();
  }

  // Select on map========================================================================================

  void resetTempFeature() {
    tempFeature = null;
  }

  Future<void> updatePlacesSource() async {
    if (map == null) return;

    final List<Map<String, dynamic>> newFeatures = [
      ...features,
      if (tempFeature != null) tempFeature!,
    ];

    final fc = <String, dynamic>{
      "type": "FeatureCollection",
      "features": newFeatures,
    };

    try {
      await map!.style.setStyleSourceProperty(_sourceId, "data", fc);

      await updateRouteLineFromFeatures(newFeatures: newFeatures);
    } catch (e) {
      // debug nhanh
      // ignore: avoid_print
      print("updatePlacesSource error: $e");
    } finally {}
  }

  Future<void> ensurePlaceLayers() async {
    if (map == null) return;
    final style = map!.style;

    // ADD SOURCE (defensive)
    try {
      await style.addSource(
        GeoJsonSource(
          id: _sourceId,
          data: jsonEncode({"type": "FeatureCollection", "features": []}),
        ),
      );
    } catch (e) {
      if (!e.toString().contains('already exists')) {
        rethrow;
      }
    }

    // ADD CIRCLE LAYER
    try {
      await style.addLayer(
        CircleLayer(
          id: _circleLayerId,
          sourceId: _sourceId,
          circleRadius: 9,
          circleColor: Colors.blue.value,
          circleStrokeColor: Colors.white.value,
          circleStrokeWidth: 2,
        ),
      );
    } catch (e) {
      if (!e.toString().contains('already exists')) {
        rethrow;
      }
    }

    // ADD INDEX LAYER
    try {
      await style.addLayer(
        SymbolLayer(
          id: _indexLayerId,
          sourceId: _sourceId,
          textFieldExpression: [
            "to-string",
            ["get", "index"],
          ],
          minZoom: 6,
          textSize: 14,
          textColor: Colors.white.value,
          textHaloColor: Colors.black.value,
          textHaloWidth: 1.5,
          textAnchor: TextAnchor.CENTER,
        ),
      );
    } catch (e) {
      if (!e.toString().contains('already exists')) {
        rethrow;
      }
    }
  }

  Future<PlannerPlaceEntity?> onSelectPlaceOnMap(
    MapContentGestureContext ctx,
    int nextStopIndex,
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
    final displayName = place?.name ?? "Unknown";

    // Tăng số thứ tự

    // Add feature mới
    // _features.add({
    //   "type": "Feature",
    //   "properties": {"index": _counter, "name": displayName},
    //   "geometry": {
    //     "type": "Point",
    //     "coordinates": [lng, lat], // ✅ GeoJSON: [lng, lat]
    //   },
    // });
    tempFeature = {
      "type": "Feature",
      "properties": {"index": nextStopIndex, "name": displayName},
      "geometry": {
        "type": "Point",
        "coordinates": [lng, lat], // ✅ GeoJSON: [lng, lat]
      },
    };

    // Update source để map render marker + text
    await updatePlacesSource();

    final latLng = Point(coordinates: Position(lng, lat));
    map!.flyTo(
      CameraOptions(center: latLng, zoom: 12),
      MapAnimationOptions(duration: 1000),
    );

    return place;
  }

  // uodate map when add stop to plan========================================================================================
  Future<void> addStopToPlan() async {
    if (tempFeature == null) return;

    features.add(tempFeature!);
    await updatePlacesSource();
  }

  // show point on map========================================================================================
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
    tempFeature = {
      "type": "Feature",
      "properties": {"index": index, "name": displayName},
      "geometry": {
        "type": "Point",
        "coordinates": [lng, lat], // ✅ GeoJSON: [lng, lat]
      },
    };

    // Update source để map render marker + text
    await updatePlacesSource();

    final latLng = Point(coordinates: Position(lng, lat));
    map!.flyTo(
      CameraOptions(center: latLng, zoom: 12),
      MapAnimationOptions(duration: 1000),
    );
  }

  //get place info on mapbox ========================================================================================
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
        'types': 'poi,place,locality,district,region,country',
      },
    );

    final res = await http.get(url);

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

  // show path========================================================================================
  Future<void> _waitForStyleReady() async {
    while (true) {
      try {
        // trick: gọi API nhẹ, nếu chưa ready sẽ throw
        await map!.style.styleLayerExists('background');
        return;
      } catch (_) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }
  }

  Future<void> ensureRouteLayers() async {
    if (map == null) return;
    final style = map!.style;

    // ADD SOURCE (defensive)
    try {
      await style.addSource(
        GeoJsonSource(
          id: _routeSourceId,
          data: jsonEncode({
            "type": "Feature",
            "properties": {},
            "geometry": {"type": "LineString", "coordinates": []},
          }),
        ),
      );
    } catch (e) {
      if (!e.toString().contains('already exists')) {
        rethrow;
      }
    }

    // ADD LINE LAYER
    try {
      await style.addLayer(
        LineLayer(
          id: _routeLayerId,
          sourceId: _routeSourceId,
          lineJoin: LineJoin.ROUND,
          lineCap: LineCap.ROUND,

          lineWidth: 2.0, // 👈 nhỏ lại
          lineDasharray: [2.0, 2.0], // 👈 DASH LINE
          lineColor: Colors.blue.value,
          lineOpacity: 0.8,
        ),
      );
    } catch (e) {
      if (!e.toString().contains('already exists')) {
        rethrow;
      }
    }
  }

  String _buildRouteFromFeatures(List<Map<String, dynamic>> features) {
    if (features.length < 2) {
      return jsonEncode({
        "type": "Feature",
        "properties": {},
        "geometry": {"type": "LineString", "coordinates": []},
      });
    }

    // sort theo properties.index
    final sorted = [...features]
      ..sort((a, b) {
        final ai = (a['properties']?['index'] as num?)?.toInt() ?? 0;
        final bi = (b['properties']?['index'] as num?)?.toInt() ?? 0;
        return ai.compareTo(bi);
      });

    final coords = sorted
        .map((f) => f['geometry']?['coordinates'])
        .where((c) => c is List && c.length >= 2)
        .map((c) => [(c[0] as num), (c[1] as num)])
        .toList();

    return jsonEncode({
      "type": "Feature",
      "properties": {},
      "geometry": {"type": "LineString", "coordinates": coords},
    });
  }

  Future<void> updateRouteLineFromFeatures({
    List<Map<String, dynamic>>? newFeatures,
  }) async {
    if (map == null) return;
    final style = map!.style;

    final exists = await style.styleSourceExists(_routeSourceId);
    if (!exists) return;

    String geoJson = "";
    if (newFeatures == null) {
      geoJson = _buildRouteFromFeatures(features);
    } else {
      geoJson = _buildRouteFromFeatures(newFeatures);
    }

    await style.setStyleSourceProperty(_routeSourceId, "data", geoJson);
  }
}
