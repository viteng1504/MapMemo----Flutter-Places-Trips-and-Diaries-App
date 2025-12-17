import 'package:supabase_flutter/supabase_flutter.dart';

import '../entities/trip_entity.dart';

class TripRepository {
  final SupabaseClient client;

  TripRepository(this.client);

  Future<void> addTrip(TripEntity trip) async {
    final user = client.auth.currentUser;
    if (user == null) {
      throw Exception('Not logged in');
    }

    // (Nếu có upload ảnh thì upload trước và lấy imageUrl)
    String? imageUrl;
    if (trip.image != null) {
      final path = 'trips/${user.id}/${trip.id}.jpg';

      await client.storage
          .from('trip_images')
          .uploadBinary(
            path,
            trip.image!,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ),
          );

      imageUrl = client.storage.from('trip_images').getPublicUrl(path);
    }

    await client.from('trips').insert({
      'id': trip.id,
      'user_id': user.id, // ✅ gắn theo user
      'name': trip.name,
      'summary': trip.summary,
      'start_date': trip.startDate,
      'days': trip.days,
      'image_url': imageUrl,
    });
  }

  Future<List<Map<String, dynamic>>> getMyTrips() async {
    final user = client.auth.currentUser;
    if (user == null) throw Exception('Not logged in');

    return await client
        .from('trips')
        .select()
        .eq('user_id', user.id) // ✅ chỉ lấy của user này
        .order('created_at', ascending: false);
  }
}
