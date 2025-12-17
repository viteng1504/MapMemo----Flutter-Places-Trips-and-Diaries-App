class TripAiRequest {
  final String tripName;
  final String tripSummary;
  final String startDate;
  final String endDate;
  final String startDestination;
  final String endDestination;
  final String travelStyle;

  TripAiRequest({
    required this.tripName,
    required this.tripSummary,
    required this.startDate,
    required this.endDate,
    required this.startDestination,
    required this.endDestination,
    required this.travelStyle,
  });

  TripAiRequest copyWith({
    String? tripName,
    String? tripSummary,
    String? startDate,
    String? endDate,
    String? startDestination,
    String? endDestination,
    String? travelStyle,
  }) {
    return TripAiRequest(
      tripName: tripName ?? this.tripName,
      tripSummary: tripSummary ?? this.tripSummary,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      startDestination: startDestination ?? this.startDestination,
      endDestination: endDestination ?? this.endDestination,
      travelStyle: travelStyle ?? this.travelStyle,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "tripName": tripName,
      "tripSummary": tripSummary,
      "startDate": startDate,
      "endDate": endDate,
      "startDestination": startDestination,
      "endDestination": endDestination,
      "travelStyle": travelStyle,
    };
  }
}
