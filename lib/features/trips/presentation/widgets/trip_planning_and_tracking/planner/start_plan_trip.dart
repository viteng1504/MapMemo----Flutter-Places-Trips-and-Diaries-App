import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_colors.dart';

class StartPlanTrip extends StatelessWidget {
  final VoidCallback onGetPersonalize;
  final VoidCallback onManualBuildItinery;

  const StartPlanTrip({
    super.key,
    required this.onGetPersonalize,
    required this.onManualBuildItinery,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 10,
      crossAxisAlignment: .center,
      children: [
        const SizedBox(height: 20),
        const Text("Start Planning Your Trip", style: TextStyle(fontSize: 24)),
        //ai suggest button
        SizedBox(
          width: 250,
          child: ElevatedButton.icon(
            onPressed: onGetPersonalize,
            icon: const Icon(Icons.auto_awesome),
            label: const Text(
              'Get a personalize itinery',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.onPrimary,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary, // đỏ như hình
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
            ),
          ),
        ),

        const Row(
          mainAxisAlignment: .center,
          children: [
            SizedBox(
              width: 40,
              child: Divider(color: AppColors.onSurfaceGray2),
            ),
            Text(" or "),
            SizedBox(
              width: 40,
              child: Divider(color: AppColors.onSurfaceGray2),
            ),
          ],
        ),

        //manual add place button
        SizedBox(
          width: 250,
          child: ElevatedButton.icon(
            onPressed: onManualBuildItinery,
            icon: const Icon(Icons.add, color: AppColors.onSurfaceGray1),
            label: const Text(
              'Build your itinerary yourself',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurfaceGray1,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.onPrimary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
            ),
          ),
        ),
      ],
    );
  }
}
