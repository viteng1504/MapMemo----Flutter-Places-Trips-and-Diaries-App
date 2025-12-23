import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_colors.dart';

class JournalTitleSection extends StatelessWidget {
  final String title;
  const JournalTitleSection({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF1A1C1E),
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        const Row(
          children: [
            Icon(Icons.location_on, size: 14, color: AppColors.primary),
            SizedBox(width: 4),
            Text(
              "Destination Stop",
              style: TextStyle(
                color: Colors.black45,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
