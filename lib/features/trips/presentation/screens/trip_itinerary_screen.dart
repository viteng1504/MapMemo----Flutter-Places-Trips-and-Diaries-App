import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../domain/entities/trip_ai_request.dart';

class TripItineraryScreen extends StatefulWidget {
  const TripItineraryScreen({super.key});

  @override
  State<TripItineraryScreen> createState() => _TripItineraryScreenState();
}

class _TripItineraryScreenState extends State<TripItineraryScreen> {
  List<Map<String, dynamic>> places = [
    {
      "id": 1,
      "name": "Da Nang",
      "image": "https://i.imgur.com/QLq9k1f.jpeg",
      "nights": 0,
      "date": "T.4 26 Th11",
      "distance": "30km",
      "duration": "28m",
    },
    {
      "id": 2,
      "name": "Hoi An",
      "image": "https://i.imgur.com/z9q5Z5c.jpeg",
      "nights": 1,
      "date": "T.4 26 Th11 - T.5 27 Th11",
      "distance": "48km",
      "duration": "38m",
    },
    {
      "id": 3,
      "name": "Tam Ky",
      "image": "https://i.imgur.com/F4eWQpO.jpeg",
      "nights": 0,
      "date": "T.5 27 Th11",
      "distance": null,
      "duration": null,
    },
  ];

  void markVisited(int index) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${places[index]['name']} marked visited")),
    );
  }

  void deletePlace(int index) {
    setState(() => places.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    final aiRequest =
        ModalRoute.of(context)!.settings.arguments as TripAiRequest;

    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListView(
            children: [
              const SizedBox(height: 10),

              // --- TRIP START ---
              _timelineHeader("Trip started", "T.4 26 Th11 2025"),

              const SizedBox(height: 10),

              // === LIST OF PLACES ===
              for (int i = 0; i < places.length; i++) _slidablePlaceCard(i),

              const SizedBox(height: 20),

              _timelineHeader("Trip finishes", "T.5 27 Th11 2025"),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),

      bottomNavigationBar: _bottomNav(),
    );
  }

  // =============================== UI COMPONENTS ===============================

  Widget _slidablePlaceCard(int index) {
    final item = places[index];

    return Slidable(
      key: ValueKey(item["id"]),
      closeOnScroll: true,
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => markVisited(index),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            icon: Icons.check_circle,
            label: 'Visited',
          ),
          SlidableAction(
            onPressed: (_) => deletePlace(index),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),

      child: _placeCard(index, item),
    );
  }

  // CARD UI
  Widget _placeCard(int index, Map item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          const BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // IMAGE
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    item["image"],
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),

                // INFO
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // NAME
                      Text(
                        item["name"],
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        item["date"],
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ),

                // NIGHTS
                Column(
                  children: [
                    Text(
                      "${item["nights"]} nights",
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Icon(Icons.remove_circle_outline, size: 22),
                        SizedBox(width: 4),
                        Icon(Icons.add_circle_outline, size: 22),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            if (item["distance"] != null) ...[
              const SizedBox(height: 12),

              Row(
                children: [
                  const Icon(Icons.directions_car, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    "${item["distance"]} • ${item["duration"]}",
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _timelineHeader(String title, String date) {
    return Row(
      children: [
        const Icon(Icons.flag_circle, size: 26, color: Colors.black87),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            Text(
              date,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _bottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.9),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navButton("Plan", Icons.map, true),
          _navButton("Track", Icons.location_pin, false),
        ],
      ),
    );
  }

  Widget _navButton(String label, IconData icon, bool active) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: active ? Colors.white : Colors.grey, size: 26),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : Colors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
