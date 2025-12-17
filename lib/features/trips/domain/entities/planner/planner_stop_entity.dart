class PlannerStopEntity {
  final String id;
  final int index;
  final String name;
  final double lat; // vĩ độ
  final double lng; // kinh độ
  final int nights;
  final DateTime startDate; // thời gian tạo

  const PlannerStopEntity({
    required this.id,
    required this.index,
    required this.name,
    required this.lat,
    required this.lng,
    required this.nights,
    required this.startDate,
  });

  /// Tạo entity từ JSON (API / local storage)
  factory PlannerStopEntity.fromJson(Map<String, dynamic> json) {
    return PlannerStopEntity(
      id: json['id'] as String,
      index: json['index'] as int,
      name: json['name'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      nights: json['nights'] as int,
      startDate: DateTime.parse(json['startDate'] as String),
    );
  }

  /// Convert entity sang JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'index': index,
      'name': name,
      'lat': lat,
      'lng': lng,
      'nights': nights,
      'startDate': startDate.toIso8601String(),
    };
  }

  /// Copy entity với một số giá trị mới
  PlannerStopEntity copyWith({
    String? id,
    int? index,
    String? name,
    double? lat,
    double? lng,
    int? nights,
    DateTime? startDate,
  }) {
    return PlannerStopEntity(
      id: id ?? this.id,
      index: index ?? this.index,
      name: name ?? this.name,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      nights: nights ?? this.nights,
      startDate: startDate ?? this.startDate,
    );
  }
}
