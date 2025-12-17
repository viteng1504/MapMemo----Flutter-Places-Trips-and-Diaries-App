class PlannerStopEntity {
  final String id;
  final int index;
  final String name;
  final double lat;
  final double lng;
  final int nights;

  const PlannerStopEntity({
    required this.id,
    required this.index,
    required this.name,
    required this.lat,
    required this.lng,
    required this.nights,
  });

  PlannerStopEntity copyWith({
    String? id,
    int? index,
    String? name,
    double? lat,
    double? lng,
    int? nights,
  }) {
    return PlannerStopEntity(
      id: id ?? this.id,
      index: index ?? this.index,
      name: name ?? this.name,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      nights: nights ?? this.nights,
    );
  }
}
