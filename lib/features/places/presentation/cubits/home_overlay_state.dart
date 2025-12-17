import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../domain/entities/place_entity.dart';

class HomeOverlayState {
  final List<PlaceEntity> places;
  final MapboxMap? mapbox;
  final String? username;

  const HomeOverlayState({required this.places, this.mapbox, this.username});

  HomeOverlayState copyWith({
    List<PlaceEntity>? places,
    MapboxMap? mapbox,
    String? username,
  }) {
    return HomeOverlayState(
      places: places ?? this.places,
      mapbox: mapbox ?? this.mapbox,
      username: username ?? this.username,
    );
  }
}
