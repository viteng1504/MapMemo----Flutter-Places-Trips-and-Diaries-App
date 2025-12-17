import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../../core/constants/app_api.dart';

class TripDestinationSearchScreen extends StatefulWidget {
  const TripDestinationSearchScreen({super.key});

  @override
  State<TripDestinationSearchScreen> createState() =>
      _TripDestinationSearchScreenState();
}

class _TripDestinationSearchScreenState
    extends State<TripDestinationSearchScreen> {
  final String mapboxToken = AppApi.mapboxAccessToken;

  List<Map<String, dynamic>> results = [];
  bool isLoading = false;

  Future<void> searchPlaces(String query) async {
    // Nếu chưa nhập đủ 3 ký tự → xoá results & return
    if (query.trim().length < 3) {
      setState(() {
        results = [];
        isLoading = false;
      });
      return;
    }

    setState(() => isLoading = true);

    try {
      final url =
          "https://api.mapbox.com/geocoding/v5/mapbox.places/$query.json"
          "?autocomplete=true&limit=10&language=en&access_token=$mapboxToken";

      final res = await http.get(Uri.parse(url));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        final List features = data["features"] ?? [];

        setState(() {
          results = features.map((item) {
            final ctx = item["context"] ?? [];

            // lấy đúng country context
            final countryContext = ctx.firstWhere(
              (c) => c["id"].toString().startsWith("country"),
              orElse: () => null,
            );

            final isoCode = countryContext?["short_code"]; // ví dụ: "vn", "hr"

            return {
              "name": item["text"] ?? "",
              "full": item["place_name"] ?? "",
              "country": countryContext?["text"] ?? "",
              "icon": isoCode != null
                  ? "https://flagsapi.com/${isoCode.toUpperCase()}/flat/32.png"
                  : null,
            };
          }).toList();
        });
      }
    } catch (e) {
      debugPrint("Search error: $e");
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        title: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "Search places",
            border: InputBorder.none,
          ),
          onChanged: searchPlaces,
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.close),
          ),
        ],
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : results.isEmpty
          ? const Center(
              child: Text(
                "No results",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: results.length,
              itemBuilder: (_, i) {
                final item = results[i];

                return ListTile(
                  leading: item["icon"] != null
                      ? Image.network(item["icon"])
                      : const Icon(Icons.place),
                  title: Text(
                    item["name"],
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    item["full"],
                    style: const TextStyle(color: Colors.grey),
                  ),
                  onTap: () {
                    print("information: $item");
                    Navigator.pop(context, item);
                  },
                );
              },
            ),
    );
  }
}
