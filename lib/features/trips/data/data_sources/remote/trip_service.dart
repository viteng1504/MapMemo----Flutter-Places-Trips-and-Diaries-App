import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../domain/entities/trip_entity.dart';
import '../../models/trip_model.dart';

class TripService {
  final SupabaseClient client;

  TripService(this.client);

  Future<TripModel> addTrip(TripEntity trip) async {
    final user = client.auth.currentUser;
    if (user == null) {
      throw Exception('Not logged in');
    }

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

    final response = await client
        .from('trips')
        .insert({
          'id': trip.id,
          'user_id': user.id,
          'name': trip.name,
          'summary': trip.summary,
          'start_date': trip.startDate.toIso8601String(),
          'days': trip.days,
          'image_url': imageUrl,
        })
        .select()
        .single();

    return TripModel.fromJson(response);
  }

  // get trips ==========================================================
  Future<List<TripModel>> getMyTrips() async {
    final user = client.auth.currentUser;
    if (user == null) {
      throw Exception('Not logged in');
    }

    final response = await client
        .from('trips')
        .select()
        .eq('user_id', user.id)
        .order('start_date', ascending: false);

    return (response as List).map((json) => TripModel.fromJson(json)).toList();
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
