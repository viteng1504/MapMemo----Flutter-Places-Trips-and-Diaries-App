import '../../../domain/entities/planner/planner_stop_entity.dart';

List<PlannerStopEntity> parseStopsIsolate(List<dynamic> raw) {
  return raw
      .cast<Map<String, dynamic>>()
      .map(PlannerStopEntity.fromMap)
      .toList();
}
