import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class SquareTile extends StatelessWidget {
  final String imagePath;
  const SquareTile({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.border,
      ),
      child: Image.asset(imagePath, width: 36),
    );
  }
}
