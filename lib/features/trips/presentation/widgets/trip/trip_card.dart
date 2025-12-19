import 'package:flutter/material.dart';

import '../../../../../core/constants/app_images.dart';
import '../../../../../core/constants/app_routes.dart';
import '../../../../../core/utils/utils.dart';
import '../../../data/models/trip_model.dart';

class TripCard extends StatelessWidget {
  final TripModel trip;
  const TripCard({super.key, required this.trip});

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
          image: DecorationImage(
            image: trip.imageUrl != null
                ? NetworkImage(trip.imageUrl!)
                : const AssetImage(AppImages.danang), // ảnh background của bạn
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 70),

              // Title
              Text(
                trip.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              // const SizedBox(height: 10),

              // Bottom row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Tháng + năm
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Utils.fmt(trip.startDate),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),

                  // Days
                  Column(
                    children: [
                      Text(
                        trip.days.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const Text(
                        "DAYS",
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),

                  // Kilometers
                  // const Column(
                  //   children: [
                  //     Text(
                  //       "0",
                  //       style: TextStyle(color: Colors.white, fontSize: 16),
                  //     ),
                  //     Text(
                  //       "KILOMETERS",
                  //       style: TextStyle(color: Colors.white70, fontSize: 11),
                  //     ),
                  //   ],
                  // ),

                  // People Icon
                  // const Icon(Icons.group, color: Colors.white, size: 24),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
