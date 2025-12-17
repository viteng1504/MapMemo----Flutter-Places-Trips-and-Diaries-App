import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../domain/entities/trip_entity.dart';

class TripService {
  final SupabaseClient client;

  TripService(this.client);

  Future<void> addTrip(TripEntity trip) async {
    print("=========================add trip");
    final user = client.auth.currentUser;
    if (user == null) {
      throw Exception('Not logged in');
    }

    // (Nếu có upload ảnh thì upload trước và lấy imageUrl)
    String? imageUrl;
    if (trip.image != null) {
      final path = 'trips/${user.id}/${trip.id}.jpg';

      print("=========================add trip1");

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
      print("=========================add trip2");

      imageUrl = client.storage.from('trip_images').getPublicUrl(path);
    }
    print("=========================add trip3");

    await client.from('trips').insert({
      'id': trip.id,
      'user_id': user.id, // ✅ gắn theo user
      'name': trip.name,
      'summary': trip.summary,
      'start_date': trip.startDate.toIso8601String(),
      'days': trip.days,
      'image_url': imageUrl,
    });
  }

  // get trips ==========================================================
  Future<List<Map<String, dynamic>>> getMyTrips() async {
    final user = client.auth.currentUser;
    if (user == null) throw Exception('Not logged in');

    return await client
        .from('trips')
        .select()
        .eq('user_id', user.id) // ✅ chỉ lấy của user này
        .order('created_at', ascending: false);
  }

  // update trip ==========================================================
  Future<void> updateTripWithImage({
    required String tripId,
    String? name,
    String? summary,
    DateTime? startDate,
    int? days,
    Uint8List? newImageBytes, // ảnh mới (nếu có)
  }) async {
    final user = client.auth.currentUser;
    if (user == null) throw Exception('Not logged in');

    final updateData = <String, dynamic>{};

    if (name != null) updateData['name'] = name;
    if (summary != null) updateData['summary'] = summary;
    if (startDate != null) updateData['start_date'] = startDate;
    if (days != null) updateData['days'] = days;

    // Nếu có ảnh mới -> upload đè + update image_url
    if (newImageBytes != null) {
      final imagePath = 'trips/${user.id}/$tripId.jpg';

      await client.storage
          .from('trip_images')
          .uploadBinary(
            imagePath,
            newImageBytes,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true, // ✅ ghi đè ảnh cũ
            ),
          );

      final imageUrl = client.storage
          .from('trip_images')
          .getPublicUrl(imagePath);

      updateData['image_url'] = imageUrl;
    }

    if (updateData.isEmpty) return;

    await client
        .from('trips')
        .update(updateData)
        .eq('id', tripId)
        .eq('user_id', user.id); // double-safety
  }

  // delete trip ==========================================================
  Future<void> deleteTripWithImage(String tripId) async {
    final user = client.auth.currentUser;
    if (user == null) throw Exception('Not logged in');

    final imagePath = 'trips/${user.id}/$tripId.jpg';

    // 1) Xóa row trong DB (RLS sẽ chặn nếu không phải trip của user)
    await client.from('trips').delete().eq('id', tripId).eq('user_id', user.id);

    // 2) Xóa ảnh trong Storage (nếu không có ảnh thì cũng không sao)
    try {
      await client.storage.from('trip_images').remove([imagePath]);
    } catch (_) {
      // ignore (file có thể không tồn tại)
    }
  }
}
