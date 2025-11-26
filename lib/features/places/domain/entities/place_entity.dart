class PlaceEntity {
  final String id; // UUID
  final String name; // tên địa điểm
  final String description; // mô tả
  final double lat; // vĩ độ
  final double lng; // kinh độ
  final String address; // địa chỉ
  final String city; // thành phố
  final String country; // quốc gia
  final DateTime createdAt; // thời gian tạo

  PlaceEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.lat,
    required this.lng,
    required this.address,
    required this.city,
    required this.country,
    required this.createdAt,
  });

  factory PlaceEntity.fromJson(Map<String, dynamic> json) {
    return PlaceEntity(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      country: json['country'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'lat': lat,
      'lng': lng,
      'address': address,
      'city': city,
      'country': country,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
