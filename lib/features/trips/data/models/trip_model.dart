class TripModel {
  final String id;
  final String name;
  final String summary;
  final DateTime startDate;
  final int days;
  final String? imageUrl;

  const TripModel({
    required this.id,
    required this.name,
    required this.summary,
    required this.startDate,
    required this.days,
    this.imageUrl,
  });

  /// from API / DB
  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
      id: json['id'] as String,
      name: json['name'] as String,
      summary: json['summary'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      days: json['days'] as int,
      imageUrl: json['image_url'] as String?,
    );
  }

  /// to API / DB
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'summary': summary,
      'start_date': startDate.toIso8601String(),
      'days': days,
      'image_url': imageUrl,
    };
  }
}
