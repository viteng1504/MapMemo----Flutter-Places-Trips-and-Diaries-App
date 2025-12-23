import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../../core/constants/app_api.dart';

class TripChatDialog extends StatefulWidget {
  final String tripId;
  const TripChatDialog({super.key, required this.tripId});

  @override
  State<TripChatDialog> createState() => _TripChatDialogState();
}

class _TripChatDialogState extends State<TripChatDialog> {
  final TextEditingController _controller = TextEditingController();
  String _response = "";
  bool _isLoading = false;

  // Key API & Supabase Client
  final String apiKey = AppApi.geminiApiKey;
  final supabase = Supabase.instance.client;

  // 1. Hàm lấy Embedding cho câu hỏi của User
  Future<List<double>> getEmbedding(String text) async {
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
      final values = List<double>.from(data['embedding']['values']);
      return values;
    } else {
      throw Exception("Failed to embed text");
    }
  }

  // 2. Hàm hỏi Gemini (RAG Flow)
  Future<void> _askGemini() async {
    final query = _controller.text;
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _response = "";
    });

    try {
      // BƯỚC A: Lấy vector của câu hỏi
      final queryVector = await getEmbedding(query);

      // BƯỚC B: Tìm dữ liệu liên quan trong Supabase (Vector Search)
      // Gọi hàm RPC 'match_trip_info' đã tạo ở Phần 1
      final rpcRes = await supabase.rpc(
        'match_trip_info',
        params: {
          'query_embedding': queryVector,
          'match_threshold': 0.1, // Độ chính xác (0-1)
          'match_count': 10, // Lấy 5 đoạn thông tin liên quan nhất
          'filter_trip_id': widget.tripId,
        },
      );
      // Kiểm tra xem có dữ liệu không
      String contextData = "";
      if (rpcRes == null || (rpcRes as List).isEmpty) {
        // Nếu không tìm thấy vector, ta nên lấy thông tin cơ bản của Trip từ bảng Trips
        final tripData = await supabase
            .from('trips')
            .select()
            .eq('id', widget.tripId)
            .single();
        contextData =
            "Trip Name: ${tripData['name']}. No specific diary entries found for this query.=========================================";
      } else {
        for (var item in rpcRes) {
          contextData += "- ${item['content']}\n";
        }
      }

      print("Context Data found: $contextData"); // Debug xem có gì không
      // Ghép các đoạn thông tin tìm được thành chuỗi Context
      contextData = "";
      for (var item in rpcRes) {
        contextData += "- ${item['content']}\n";
      }

      // BƯỚC C: Gửi Prompt + Context cho Gemini
      // BƯỚC C: Gửi Prompt + Context cho Gemini
      final prompt =
          """
Bạn là một trợ lý du lịch thông minh. Dưới đây là dữ liệu nhật ký chuyến đi của người dùng.
Hãy trả lời câu hỏi dựa trên ngữ cảnh được cung cấp.

Yêu cầu trình bày:
- Sử dụng **Markdown** để định dạng câu trả lời.
- Sử dụng danh sách gạch đầu dòng cho các ý chính.
- Sử dụng **in đậm** cho các địa điểm hoặc thời gian quan trọng.
- Nếu thông tin có nhiều giai đoạn, hãy ngắt dòng rõ ràng hoặc dùng bảng.

TRIP CONTEXT:
$contextData

USER QUESTION:
$query
""";

      final url = Uri.parse(
        "https://generativelanguage.googleapis.com/v1/models/gemini-2.5-flash:generateContent?key=$apiKey",
      );

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": prompt},
              ],
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String aiText = data['candidates'][0]['content']['parts'][0]['text'];
        aiText = aiText.replaceAll(r'\n', '\n');
        setState(() {
          _response = aiText;
        });
      } else {
        setState(() {
          _response = "Error: ${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        _response = "Error: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Ask AI about this Trip"),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: "E.g., Summary this trip, Where did I eat?",
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 10),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_response.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(_response), // Hiển thị kết quả Markdown nếu cần
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Close"),
        ),
        ElevatedButton(
          onPressed: _askGemini,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
          child: const Text("Ask"),
        ),
      ],
    );
  }
}
