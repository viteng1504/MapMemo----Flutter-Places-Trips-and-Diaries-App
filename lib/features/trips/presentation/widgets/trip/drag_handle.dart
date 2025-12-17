import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

class DragHandle extends StatelessWidget {
  const DragHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 5,
        decoration: BoxDecoration(
          color: AppColors.onSurfaceGray2,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
