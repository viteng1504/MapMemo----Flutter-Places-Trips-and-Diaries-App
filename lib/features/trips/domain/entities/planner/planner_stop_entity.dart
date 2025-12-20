class PlannerStopEntity {
  final String id;
  final int stopIndex;
  final String name;
  final double lat;
  final double lng;
  final int nights;

  const PlannerStopEntity({
    required this.id,
    required this.stopIndex,
    required this.name,
    required this.lat,
    required this.lng,
    required this.nights,
  });

  factory PlannerStopEntity.fromMap(Map<String, dynamic> map) {
    return PlannerStopEntity(
      id: map['id'] as String,
      stopIndex: map['stop_index'] as int,
      name: map['name'] as String,
      lat: (map['lat'] as num).toDouble(),
      lng: (map['lng'] as num).toDouble(),
      nights: map['nights'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'stop_index': stopIndex,
      'name': name,
      'lat': lat,
      'lng': lng,
      'nights': nights,
    };
  }

  PlannerStopEntity copyWith({int? nights}) {
    return PlannerStopEntity(
      id: id,
      stopIndex: stopIndex,
      name: name,
      lat: lat,
      lng: lng,
      nights: nights ?? this.nights,
    );
  }
}
