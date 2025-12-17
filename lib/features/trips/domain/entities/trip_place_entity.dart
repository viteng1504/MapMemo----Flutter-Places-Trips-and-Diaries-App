import 'dart:typed_data';

class TripEntity {
  final String id;
  final String name;
  final String summary;
  final String startDate;
  final int days;
  final double kilometers;
  final Uint8List? image;

  const TripEntity({
    required this.id,
    required this.name,
    required this.summary,
    required this.startDate,
    required this.days,
    required this.kilometers,
    this.image,
  });

  TripEntity copyWith({
    String? id,
    String? name,
    String? summary,
    String? startDate,
    int? days,
    double? kilometers,
    Uint8List? image,
  }) {
    return TripEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      summary: summary ?? this.summary,
      startDate: startDate ?? this.startDate,
      days: days ?? this.days,
      kilometers: kilometers ?? this.kilometers,
      image: image ?? this.image,
    );
  }

  factory TripEntity.fromJson(Map<String, dynamic> json) {
    return TripEntity(
      id: json['id'] as String,
      name: json['name'] as String,
      summary: json['summary'] as String,
      startDate: json['startDate'] as String,
      days: json['days'] as int,
      kilometers: (json['kilometers'] as num).toDouble(),
      image: json['image'] != null
          ? Uint8List.fromList(List<int>.from(json['image']))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'summary': summary,
      'startDate': startDate,
      'days': days,
      'kilometers': kilometers,
      'image': image,
    };
  }
}
