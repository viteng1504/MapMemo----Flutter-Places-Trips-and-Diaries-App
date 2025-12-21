import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../../core/constants/app_api.dart';
import '../../../domain/entities/ai_place.dart';
import '../../../domain/entities/trip_ai_request.dart';

class TripAiService {
  // Thay vì dùng AppApi.geminiApiKey làm URL
  static Future<List<AiPlace>> generateItinerary(TripAiRequest req) async {
    const String baseUrl =
        "https://generativelanguage.googleapis.com/v1/models/gemini-2.5-flash:generateContent";
    final String apiKey = AppApi.geminiApiKey;

    final url = Uri.parse('$baseUrl?key=$apiKey');

    final prompt =
        """
Bạn là một travel planner chuyên nghiệp.

Nhiệm vụ:
- Tạo hành trình từ "${req.startDestination}" đến "${req.endDestination}"
- Chọn từ 2 đến 4 điểm dừng (stops) hợp lý trên đường hoặc gần đường đi.
- Mỗi stop bắt buộc có: name, lat, lng.

Chỉ trả về JSON đúng FORMAT dưới đây, KHÔNG giải thích, KHÔNG markdown, KHÔNG code block, KHÔNG thêm text ngoài JSON:

{
  "stops": [
    {
      "name": "Tên địa điểm",
      "lat": 10.762622,
      "lng": 106.660172
    }
  ]
}

QUY TẮC BẮT BUỘC:
- "stops" phải là mảng có độ dài 2..4.
- "name" là string, không rỗng.
- "lat" và "lng" là number (không được để trong dấu nháy) và phần thập phân phải có 6 chữ số.
- lat trong [-90, 90], lng trong [-180, 180].
- Không được trả về null cho lat/lng.
""";

    final body = jsonEncode({
      "contents": [
        {
          "role": "user",
          "parts": [
            {"text": prompt},
          ],
        },
      ],
      // Nếu bạn muốn output ổn định hơn thì bật:
      "generationConfig": {
        "temperature": 0.4,
        "topP": 0.9,
        "maxOutputTokens": 5000,
      },
      "safetySettings": [
        {
          "category": "HARM_CATEGORY_DANGEROUS_CONTENT",
          "threshold": "BLOCK_NONE",
        },
      ],
    });

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    // debug
    print(response.body);
    print("====================================");

    if (response.statusCode != 200) {
      throw Exception("Gemini Error: ${response.statusCode}\n${response.body}");
    }

    final data = jsonDecode(response.body);

    // Lấy text output
    final text = data["candidates"]?[0]?["content"]?["parts"]?[0]?["text"];
    if (text == null || text is! String) {
      throw Exception("AI response không hợp lệ: thiếu text");
    }

    // Làm sạch output (phòng khi AI vẫn bọc ```json ... ``` hoặc thêm text)
    String cleaned = text.trim();

    // Nếu có codeblock
    final codeBlock = RegExp(
      r"```(?:json)?\s*(.*?)\s*```",
      dotAll: true,
    ).firstMatch(cleaned);
    if (codeBlock != null) {
      cleaned = codeBlock.group(1)!.trim();
    }

    // Nếu AI lỡ thêm text ngoài JSON, cố gắng cắt từ { ... }
    final firstBrace = cleaned.indexOf('{');
    final lastBrace = cleaned.lastIndexOf('}');
    if (firstBrace != -1 && lastBrace != -1 && lastBrace > firstBrace) {
      cleaned = cleaned.substring(firstBrace, lastBrace + 1).trim();
    }

    final jsonMap = jsonDecode(cleaned);

    final stopsJson = jsonMap["stops"];
    if (stopsJson == null || stopsJson is! List) {
      throw Exception("JSON thiếu field 'stops' hoặc 'stops' không phải List");
    }

    // Option: validate kiểu dữ liệu ngay tại đây (đỡ crash về sau)
    final stops = stopsJson.map((e) {
      final name = e["name"];
      final lat = e["lat"];
      final lng = e["lng"];

      if (name is! String || name.trim().isEmpty) {
        throw Exception("Stop.name không hợp lệ: $e");
      }
      if (lat is! num || lng is! num) {
        throw Exception("Stop.lat/lng phải là number: $e");
      }
      if (lat < -90 || lat > 90 || lng < -180 || lng > 180) {
        throw Exception("Stop lat/lng out of range: $e");
      }

      // Nếu AiPlace.fromJson expect double, ép kiểu:
      return AiPlace.fromJson({
        "name": name,
        "lat": (lat).toDouble(),
        "lng": (lng).toDouble(),
      });
    }).toList();

    return stops;
  }
}
