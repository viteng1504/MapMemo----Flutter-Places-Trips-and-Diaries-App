class AiPlace {
  final String name;
  final String? image;
  final int nights;
  final String date;
  final String? distance;
  final String? duration;

  AiPlace({
    required this.name,
    required this.image,
    required this.nights,
    required this.date,
    this.distance,
    this.duration,
  });

  factory AiPlace.fromJson(Map<String, dynamic> json) => AiPlace(
    name: json["name"],
    image: json["image"],
    nights: json["nights"],
    date: json["date"],
    distance: json["distance"],
    duration: json["duration"],
  );

  @override
  String toString() {
    return """
Tên: $name
Số đêm: $nights
Ngày: $date
Khoảng cách: ${distance ?? "Không có"}
Thời gian di chuyển: ${duration ?? "Không có"}
""";
  }
}
