import 'package:flutter/material.dart';

import 'date_box.dart';
import 'error_text.dart';

class TripDatesSection extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final bool showError;

  final Function(BuildContext) onPickStart;
  final Function(BuildContext) onPickEnd;

  const TripDatesSection({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.showError,
    required this.onPickStart,
    required this.onPickEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.calendar_today_outlined, color: Colors.black54),
              SizedBox(width: 10),
              Text(
                "Trip dates",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DateBox(
                label: "Start date",
                value: _fmt(startDate),
                showError: showError,
                onTap: onPickStart,
              ),
              const Icon(Icons.arrow_forward, color: Colors.black54),
              DateBox(
                label: "End date",
                value: _fmt(endDate),
                showError: showError,
                onTap: onPickEnd,
              ),
            ],
          ),

          if (showError)
            const ErrorText(
              "You have a trip that overlaps with this one. Please change the dates.",
            ),
        ],
      ),
    );
  }

  static String _fmt(DateTime? d) {
    if (d == null) return "Optional";
    return "${d.day} Th${d.month}, ${d.year}";
  }
}
