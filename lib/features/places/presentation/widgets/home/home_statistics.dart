import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

class HomeStatistics extends StatelessWidget {
  const HomeStatistics({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.onSurfaceGray2.withOpacity(.2),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        border: Border.all(width: .3, color: AppColors.onSurfaceGray2),
      ),
      child: Column(
        spacing: 5,
        children: [
          Row(
            spacing: 10,
            children: [
              Text(
                "Your Statistics",
                style: theme.textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Icon(Icons.trending_up, color: AppColors.primary),
            ],
          ),
          Row(
            spacing: 10,
            children: [
              const CircleAvatar(
                backgroundColor: AppColors.background2,
                child: Icon(
                  Icons.location_on_outlined,
                  color: AppColors.primary,
                ),
              ),

              Text(
                "You have saved 23 locations",
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
