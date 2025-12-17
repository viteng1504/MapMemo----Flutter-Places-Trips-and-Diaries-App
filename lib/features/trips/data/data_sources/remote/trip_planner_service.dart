import 'package:supabase_flutter/supabase_flutter.dart';

class TripPlannerService {
  final SupabaseClient client;

  TripPlannerService(this.client);

  //get planner stops===========================================
  Future<List<Map<String, dynamic>>> getStopsByTrip(String tripId) async {
    final user = client.auth.currentUser;
    if (user == null) {
      throw Exception('Not logged in');
    }

    final res = await client
        .from('planner_stops')
        .select()
        .eq('trip_id', tripId)
        .eq('user_id', user.id) // 🔒 double safety
        .order('stop_index');

    return List<Map<String, dynamic>>.from(res);
  }

  //delete planner stop===========================================
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
}
