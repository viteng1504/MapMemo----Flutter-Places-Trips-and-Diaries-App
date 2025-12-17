import 'package:flutter/material.dart';

import '../../../../../core/constants/app_images.dart';
import '../../../../../core/constants/app_routes.dart';

class TripCard extends StatelessWidget {
  const TripCard({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.tripPlanningAndTracking);
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: const DecorationImage(
            image: AssetImage(AppImages.danang), // ảnh background của bạn
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.15),
                Colors.black.withOpacity(0.5),
              ],
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                "Pasttest",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 20),

              // Bottom row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Tháng + năm
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "tháng 11",
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      Text(
                        "2025",
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),

                  // Days
                  Column(
                    children: [
                      Text(
                        "1",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      Text(
                        "DAYS",
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),

                  // Kilometers
                  Column(
                    children: [
                      Text(
                        "0",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      Text(
                        "KILOMETERS",
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),

                  // People Icon
                  Icon(Icons.group, color: Colors.white, size: 24),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
