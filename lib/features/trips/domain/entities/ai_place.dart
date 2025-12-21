class AiPlace {
  final String name;
  final double lat;
  final double lng;

  AiPlace({required this.name, required this.lat, required this.lng});

  factory AiPlace.fromJson(Map<String, dynamic> json) => AiPlace(
    name: json['name'] as String,
    lat: (json['lat'] as num).toDouble(),
    lng: (json['lng'] as num).toDouble(),
  );

  Map<String, dynamic> toJson() => {"name": name, "lat": lat, "lng": lng};
}
