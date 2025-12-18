class PlannerPlaceEntity {
  final String country;
  final String countryIconUrl;
  final String name;
  final double lat;
  final double lng;

  const PlannerPlaceEntity({
    required this.country,
    required this.countryIconUrl,
    required this.name,
    required this.lat,
    required this.lng,
  });

  PlannerPlaceEntity copyWith({
    String? country,
    String? countryIconUrl,
    String? name,
    double? lat,
    double? lng,
  }) {
    return PlannerPlaceEntity(
      country: country ?? this.country,
      countryIconUrl: countryIconUrl ?? this.countryIconUrl,
      name: name ?? this.name,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
    );
  }

  factory PlannerPlaceEntity.fromJson(Map<String, dynamic> json) {
    return PlannerPlaceEntity(
      country: json['country'] as String,
      countryIconUrl: json['countryIconUrl'] as String,
      name: json['name'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'country': country,
      'countryIconUrl': countryIconUrl,
      'name': name,
      'lat': lat,
      'lng': lng,
    };
  }

  @override
  String toString() {
    return 'PlannerPlaceEntity('
        'name: $name, '
        'country: $country, '
        'lat: $lat, '
        'lng: $lng, '
        'countryIconUrl: $countryIconUrl'
        ')';
  }

  
}
