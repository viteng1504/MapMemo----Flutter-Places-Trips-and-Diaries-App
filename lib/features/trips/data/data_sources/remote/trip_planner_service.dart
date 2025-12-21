import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../domain/entities/planner/planner_stop_entity.dart';
import 'trip_planner_parsers.dart';

class TripPlannerService {
  final SupabaseClient client;

  TripPlannerService(this.client);

  //get planner stop======================================================================

  Future<List<PlannerStopEntity>> getStopsByTrip(String tripId) async {
    final user = client.auth.currentUser;
    if (user == null) throw Exception('Not logged in');

    final res = await client
        .from('planner_stops')
        .select('id, stop_index, name, lat, lng, nights')
        .eq('trip_id', tripId)
        .eq('user_id', user.id)
        .order('stop_index');

    return compute(parseStopsIsolate, res as List<dynamic>);
  }

  //add planner stop======================================================================
  Future<PlannerStopEntity> addStop({
    required String tripId,
    required PlannerStopEntity stop,
  }) async {
    final user = client.auth.currentUser;
    if (user == null) {
      throw Exception('Not logged in');
    }

    final res = await client
        .from('planner_stops')
        .insert({
          'trip_id': tripId,
          'user_id': user.id,
          'stop_index': stop.stopIndex,
          'name': stop.name,
          'lat': stop.lat,
          'lng': stop.lng,
          'nights': stop.nights,
        })
        .select('id, stop_index, name, lat, lng, nights')
        .single();

    return PlannerStopEntity.fromMap(res);
  }

  //delete planner stop======================================================================
  Future<void> deleteStop(String stopId) async {
    final user = client.auth.currentUser;
    if (user == null) {
      throw Exception('Not logged in');
    }

    await client
        .from('planner_stops')
        .delete()
        .eq('id', stopId)
        .eq('user_id', user.id); // 🔒 double safety
  }

  //update stop nights======================================================================
  Future<void> updateStopNights({
    required String stopId,
    required int newNights,
  }) async {
    final user = client.auth.currentUser;
    if (user == null) throw Exception('Not logged in');

    await client
        .from('planner_stops')
        .update({'nights': newNights < 0 ? 0 : newNights})
        .eq('id', stopId)
        .eq('user_id', user.id);
  }

  Timer? _saveTimer;
  final Map<String, int> _pendingNights = {}; // stopId -> nights

  // avoid change nights too fast
  void scheduleUpdateStopNights({required String stopId, required int nights}) {
    _pendingNights[stopId] = nights;

    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 400), () async {
      final toSave = Map<String, int>.from(_pendingNights);
      _pendingNights.clear();

      try {
        for (final e in toSave.entries) {
          await updateStopNights(stopId: e.key, newNights: e.value);
          print(
            "update night success=======================================================",
          );
        }
      } catch (e) {
        debugPrint('Update nights failed: $e');
      }
    });
  }
}
