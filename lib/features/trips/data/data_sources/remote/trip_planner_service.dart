import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../core/constants/app_api.dart';
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
    if (user == null) throw Exception('Not logged in');

    // 1. Insert vào planner_stops (Cột diary mặc định sẽ là null hoặc rỗng)
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
          'diary': '', // Khởi tạo nhật ký rỗng ngay tại đây
        })
        .select()
        .single();

    final stopEntity = PlannerStopEntity.fromMap(res);

    // 2. Tạo Vector Embedding ban đầu cho địa điểm này
    try {
      // Nội dung sơ khai để AI có dữ liệu về Trip
      final initialContent =
          "Location: ${stopEntity.name}. Index: ${stopEntity.stopIndex}. Stay for ${stopEntity.nights} nights.";

      // Gọi API Gemini để lấy embedding
      final embedding = await getGeminiEmbedding(initialContent);

      // Lưu vào bảng trip_embeddings
      await client.from('trip_embeddings').insert({
        'trip_id': tripId,
        'stop_id': stopEntity.id,
        'content': initialContent,
        'embedding': embedding,
      });
    } catch (e) {
      // Log lỗi nhưng không chặn luồng chính
      print("AI Vectorizing failed: $e");
    }

    return stopEntity;
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

  // stop diary======================================================================
  Future<void> updateStopDiary({
    required String tripId,
    required String stopId,
    required String stopName,
    required String diaryText,
  }) async {
    try {
      // BƯỚC 1: Phải update planner_stops trước và đợi nó xong
      await client
          .from('planner_stops')
          .update({'diary': diaryText})
          .eq('id', stopId);

      // BƯỚC 2: Tạo content và embedding
      final fullContent = "Location: $stopName. Diary: $diaryText.";
      final vector = await getGeminiEmbedding(fullContent);

      // BƯỚC 3: Mới thực hiện lưu vào trip_embeddings
      await client.from('trip_embeddings').upsert({
        'trip_id': tripId,
        'stop_id':
            stopId, // Chắc chắn ID này vừa được update thành công ở Bước 1
        'content': fullContent,
        'embedding': vector,
      }, onConflict: 'stop_id');
    } catch (e) {
      // Log lỗi chi tiết
      rethrow;
    }
  }

  Future<List<double>> getGeminiEmbedding(String text) async {
    final apiKey = AppApi.geminiApiKey;
    final url = Uri.parse(
      "https://generativelanguage.googleapis.com/v1beta/models/text-embedding-004:embedContent?key=$apiKey",
    );

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "model": "models/text-embedding-004",
        "content": {
          "parts": [
            {"text": text},
          ],
        },
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<double>.from(data['embedding']['values']);
    } else {
      throw Exception("Embedding failed: ${response.body}");
    }
  }

  Future<String?> getStopDiary(String stopId) async {
    try {
      final response = await Supabase.instance.client
          .from('planner_stops')
          .select('diary')
          .eq('id', stopId)
          .maybeSingle();

      if (response != null && response['diary'] != null) {
        return response['diary'] as String;
      }
      return null;
    } catch (e) {
      print('Error fetching diary: $e');
      return null;
    }
  }

  //journal images ======================================================================
  Future<List<String>> getStopImages(String stopId) async {
    try {
      final response = await Supabase.instance.client
          .from('stop_images')
          .select('image_url')
          .eq('stop_id', stopId);

      // Chuyển đổi dữ liệu trả về thành List các chuỗi URL
      final List<String> imageUrls = (response as List)
          .map((item) => item['image_url'] as String)
          .toList();

      return imageUrls;
    } catch (e) {
      print('Error fetching stop images: $e');
      return [];
    }
  }

  Future<List<String>> uploadStopImages({
    required String stopId,
    required List<File> imageFiles,
  }) async {
    final supabase = Supabase.instance.client;
    List<String> uploadedUrls = [];

    try {
      for (var file in imageFiles) {
        // 1. Tạo tên file duy nhất để tránh trùng lặp
        final fileName =
            "${DateTime.now().millisecondsSinceEpoch}_${p.basename(file.path)}";
        final path = 'stops/$stopId/$fileName';

        // 2. Upload file lên Bucket 'trip_journals'
        await supabase.storage
            .from('trip_journals')
            .upload(
              path,
              file,
              fileOptions: const FileOptions(
                cacheControl: '3600',
                upsert: false,
              ),
            );

        // 3. Lấy Public URL
        final String publicUrl = supabase.storage
            .from('trip_journals')
            .getPublicUrl(path);
        uploadedUrls.add(publicUrl);

        // 4. Lưu vào bảng phụ 'stop_images' để quản lý list ảnh của 1 stop
        await supabase.from('stop_images').insert({
          'stop_id': stopId,
          'image_url': publicUrl,
        });
      }

      return uploadedUrls;
    } catch (e) {
      print("Upload error: $e");
      rethrow;
    }
  }
}
