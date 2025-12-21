class TripAiRequest {
  final String tripName;
  final String tripSummary;
  final String startDate;
  final int days;
  final String startDestination;
  final String endDestination;

  const TripAiRequest({
    required this.tripName,
    required this.tripSummary,
    required this.startDate,
    required this.days,
    required this.startDestination,
    required this.endDestination,
  });

  factory TripAiRequest.fromJson(Map<String, dynamic> json) {
    return TripAiRequest(
      tripName: json['tripName'] as String,
      tripSummary: json['tripSummary'] as String,
      startDate: json['startDate'] as String,
      days: json['days'] as int,
      startDestination: json['startDestination'] as String,
      endDestination: json['endDestination'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tripName': tripName,
      'tripSummary': tripSummary,
      'startDate': startDate,
      'days': days,
      'startDestination': startDestination,
      'endDestination': endDestination,
    };
  }

  TripAiRequest copyWith({
    String? tripName,
    String? tripSummary,
    String? startDate,
    int? days,
    String? startDestination,
    String? endDestination,
  }) {
    return TripAiRequest(
      tripName: tripName ?? this.tripName,
      tripSummary: tripSummary ?? this.tripSummary,
      startDate: startDate ?? this.startDate,
      days: days ?? this.days,
      startDestination: startDestination ?? this.startDestination,
      endDestination: endDestination ?? this.endDestination,
    );
  }
}
