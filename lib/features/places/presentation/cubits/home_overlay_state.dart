import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../domain/entities/place_entity.dart';

class HomeOverlayState {
  final List<PlaceEntity> places;
  final MapboxMap? mapbox;

  HomeOverlayState({required this.places, this.mapbox});

  HomeOverlayState copyWith({List<PlaceEntity>? places, MapboxMap? mapbox}) {
    return HomeOverlayState(
      places: places ?? this.places,
      mapbox: mapbox ?? this.mapbox,
    );
  }
}
