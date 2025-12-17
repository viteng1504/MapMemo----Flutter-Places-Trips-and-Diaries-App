import 'package:flutter/material.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/data_sources/remote/trip_ai_service.dart';
import '../../domain/entities/trip_ai_request.dart';

class TripPersonalizeScreen extends StatefulWidget {
  const TripPersonalizeScreen({super.key});

  @override
  State<TripPersonalizeScreen> createState() => _TripPersonalizeScreenState();
}

enum Destination { start, end }

class _TripPersonalizeScreenState extends State<TripPersonalizeScreen> {
  bool isRoundTrip = false;
  int selectedStyle = -1;
  String start = "";
  String end = "";
  final TextEditingController startController = TextEditingController();
  final TextEditingController endController = TextEditingController();

  final List<Map<String, dynamic>> travelStyles = [
    {"icon": Icons.pedal_bike, "label": "Cycling trip"},
    {"icon": Icons.directions_car, "label": "Road trip"},
    {"icon": Icons.hiking, "label": "Hiking trip"},
    {"icon": Icons.train, "label": "Rail trip"},
    {"icon": Icons.sailing, "label": "Boat trip"},
    {"icon": Icons.airport_shuttle, "label": "Van/RV trip"},
    {"icon": Icons.motorcycle, "label": "Motorcycle trip"},
    {"icon": Icons.directions_bus, "label": "Public Transport Trip"},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final aiRequest =
        ModalRoute.of(context)!.settings.arguments as TripAiRequest;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          "Get a personalized trip plan",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.black,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: false,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- ROUTE TYPE ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _routeInput("Start destination", Destination.start),
                  const SizedBox(height: 10),
                  _routeInput("End destination", Destination.end),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Round Trip",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Switch(
                        value: isRoundTrip,
                        onChanged: (v) {
                          setState(() => isRoundTrip = v);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --- TRAVEL STYLE ---
            const Text(
              "Travel style",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text("Choose one", style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 14),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: travelStyles.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (_, i) {
                final item = travelStyles[i];
                final isSelected = selectedStyle == i;

                return GestureDetector(
                  onTap: () {
                    setState(() => selectedStyle = i);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withOpacity(.1)
                          : Colors.white,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : Colors.grey.shade300,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          item["icon"],
                          color: isSelected
                              ? AppColors.primary
                              : Colors.black54,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item["label"],
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.black87,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SizedBox(
            height: 54,
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () async {
                final req = aiRequest.copyWith(
                  startDestination: start,
                  endDestination: end,
                  travelStyle: travelStyles[selectedStyle]["label"],
                );

                // call AI
                final aiPlaces = await TripAiService.generateItinerary(req);

                print("=================================================");
                print(aiPlaces.toString());

                // push itinerary + truyền dữ liệu
                // Navigator.pushNamed(
                //   context,
                //   AppRoutes.tripItinerary,
                //   arguments: {"request": req, "places": aiPlaces},
                // );
              },
              child: const Text(
                "Generate itinerary",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // INPUT FIELD UI
  Widget _routeInput(String label, Destination des) {
    final controller = des == Destination.start
        ? startController
        : endController;

    final icon = des == Destination.start
        ? Icons.trip_origin_outlined
        : Icons.flag_outlined;

    return Material(
      borderRadius: BorderRadius.circular(12),
      child: TextField(
        controller: controller,
        readOnly: true,
        onTap: () async {
          final result = await Navigator.pushNamed(
            context,
            AppRoutes.tripDestinationSearch,
          );

          if (result != null) {
            final map = result as Map<String, dynamic>;

            setState(() {
              if (des == Destination.start) {
                start = map["name"];
                startController.text = start;
              } else {
                end = map["name"];
                endController.text = end;
              }
            });
          }
        },

        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),

          prefixIcon: Icon(icon, color: Colors.black87),

          hintText: label,
          border: InputBorder.none,
        ),
      ),
    );
  }
}
