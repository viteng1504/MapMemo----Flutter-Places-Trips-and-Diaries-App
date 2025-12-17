import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../../core/constants/app_routes.dart';
import '../../../../../core/theme/app_colors.dart';

class TripTypeBottomSheet extends StatefulWidget {
  const TripTypeBottomSheet({super.key});

  @override
  State<TripTypeBottomSheet> createState() => _TripTypeBottomSheetState();
}

class _TripTypeBottomSheetState extends State<TripTypeBottomSheet> {
  int? selected;

  Future<void> onContinue(BuildContext context) async {
    print("=========================continue");

    final trip = await Navigator.pushNamed(context, AppRoutes.addTrip);
    if (!context.mounted) return;
    Navigator.pop(context, trip);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.92),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 45,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 25),

              // Title
              const Text(
                "What kind of trip do you want to add?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1B2A3A),
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle
              const Text(
                "Don’t worry, you can change this later.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 25),

              // Options
              optionTile(
                index: 0,
                icon: Icons.calendar_month_outlined,
                title: "I want to plan a future trip",
              ),
              optionTile(
                index: 1,
                icon: Icons.directions_run_outlined,
                title: "I'm currently traveling",
              ),
              optionTile(
                index: 2,
                icon: Icons.history_outlined,
                title: "I want to add a past trip",
              ),
              const SizedBox(height: 20),

              // Continue button
              GestureDetector(
                onTap: selected == null
                    ? null
                    : () {
                        onContinue(context);
                      },
                child: Container(
                  width: double.infinity,
                  height: 55,
                  decoration: BoxDecoration(
                    color: selected == null
                        ? Colors.grey.shade300
                        : AppColors.primary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "Continue",
                    style: TextStyle(
                      fontSize: 16,
                      color: selected == null ? Colors.grey : Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Cancel
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: double.infinity,
                  height: 55,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black12, width: 2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget optionTile({
    required int index,
    required IconData icon,
    required String title,
  }) {
    final isSelected = index == selected;

    return GestureDetector(
      onTap: () => setState(() => selected = index),
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFF475E78) : Colors.black12,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 28, color: Colors.black87),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? const Color(0xFF475E78) : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
