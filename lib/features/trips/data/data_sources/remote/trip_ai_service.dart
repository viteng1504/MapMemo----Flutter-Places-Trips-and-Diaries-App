import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../../core/constants/app_api.dart';
import '../../../domain/entities/ai_place.dart';
import '../../../domain/entities/trip_ai_request.dart';

class TripAiService {
  // Thay vì dùng AppApi.geminiApiKey làm URL
  static Future<List<AiPlace>> generateItinerary(TripAiRequest req) async {
    print("Travel style ${req.travelStyle}");
    // ĐÃ FIX: Dùng API version v1 + model mới
    const String baseUrl =
        "https://generativelanguage.googleapis.com/v1/models/gemini-2.5-flash:generateContent";
    final String apiKey = AppApi.geminiApiKey;

    final url = Uri.parse('$baseUrl?key=$apiKey');

    final String travelStyle = req.travelStyle ?? "bất kỳ";

    final prompt =
        """
Bạn là một travel planner chuyên nghiệp.

Hãy tạo hành trình du lịch khoảng 2 đến 4 nơi từ "${req.startDestination}" đến "${req.endDestination}".
Phong cách du lịch: $travelStyle.

 Chỉ trả về JSON đúng FORMAT dưới đây, không giải thích gì thêm, không thêm text ngoài JSON:

{
  "places": [
    {
      "name": "Tên địa điểm",
      "nights": 1,
      "date": "yyyy-MM-dd",
      "distance": "khoảng cách từ điểm trước (ví dụ: 35km hoặc null)",
      "duration": "thời gian di chuyển (ví dụ: 45 phút hoặc null)"
    }
  ]
}

 QUY TẮC:
- Tất cả các field phải có đúng kiểu.
- "image" phải là URL (không được để trống).
- "nights" luôn là số nguyên >= 0.
- "date" phải đúng dạng yyyy-MM-dd.
- "distance" và "duration" có thể null.
- Không được thêm mô tả, markdown hoặc code block.
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
      // "generationConfig": {
      //   "temperature": 0.7,
      //   "topP": 0.8,
      //   "topK": 40,
      //   "maxOutputTokens": 100,
      // },
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

    print(response.body);

    print("====================================");

    if (response.statusCode == 200) {
      print("status 200");
      final data = jsonDecode(response.body);
      final text = data["candidates"][0]["content"]["parts"][0]["text"];

      // Xử lý code block
      String jsonText = text.trim();
      final regex = RegExp(r"```json\s*(.*?)\s*```", dotAll: true);
      final match = regex.firstMatch(jsonText);
      if (match != null) {
        jsonText = match.group(1)!;
      }

      final jsonMap = jsonDecode(jsonText);
      final List placesJson = jsonMap["places"];

      return placesJson.map((e) => AiPlace.fromJson(e)).toList();
    } else {
      print("Gemini Error: ${response.statusCode} - ${response.body}");
      throw Exception("AI lỗi: ${response.statusCode}\n${response.body}");
    }
  }
}
