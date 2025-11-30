import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class ExploreOverlayUI extends StatelessWidget {
  const ExploreOverlayUI({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      // controller: _sheetController,
      initialChildSize: 0.2,
      minChildSize: 0.2,
      maxChildSize: 0.75,
      snap: true,
      snapSizes: const [0.2, 0.5, 0.75],
      snapAnimationDuration: const Duration(milliseconds: 300),
      builder: (context, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.background2,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            // boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 10)],
          ),
          child: ListView(
            controller: controller,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            children: [
              // drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.onSurfaceGray2,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),

              const SizedBox(height: 10),
              Text("asdfasd")
            ],
          ),
        );
      },
    );
  }
}
