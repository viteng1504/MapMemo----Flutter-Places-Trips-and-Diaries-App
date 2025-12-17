import 'dart:typed_data';

class TripEntity {
  final String id;
  final String name;
  final String summary;
  final DateTime startDate;
  final int days;
  final Uint8List? image;

  const TripEntity({
    required this.id,
    required this.name,
    required this.summary,
    required this.startDate,
    required this.days,
    this.image,
  });

  TripEntity copyWith({
    String? id,
    String? name,
    String? summary,
    DateTime? startDate,
    int? days,
    Uint8List? image,
  }) {
    return TripEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      summary: summary ?? this.summary,
      startDate: startDate ?? this.startDate,
      days: days ?? this.days,
      image: image ?? this.image,
    );
  }

  factory TripEntity.fromJson(Map<String, dynamic> json) {
    return TripEntity(
      id: json['id'] as String,
      name: json['name'] as String,
      summary: json['summary'] as String,
      startDate: json['startDate'] as DateTime,
      days: json['days'] as int,
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
      'startDate': startDate.toIso8601String(),
      'days': days,
    };
  }
}
