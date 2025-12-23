import 'package:flutter/material.dart';

import '../../../../../../core/constants/app_images.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../data/models/trip_model.dart';
import '../../../../domain/entities/planner/planner_stop_entity.dart';
import 'stop_detail_bottom_sheet.dart';
import 'trip_chat_dialog.dart';

class TripStopsStrip extends StatelessWidget {
  final List<PlannerStopEntity> stops;
  final VoidCallback? onAddStop;
  final ValueChanged<int>? onStopTap;
  final double height;
  final TripModel? tripModel;

  const TripStopsStrip({
    super.key,
    required this.stops,
    this.onAddStop,
    this.onStopTap,
    this.height = 180,
    this.tripModel,
  });

  @override
  Widget build(BuildContext context) {
    Future<void> showStopBottomSheet(
      BuildContext context, {
      required PlannerStopEntity stop,
    }) {
      if (tripModel == null) {
        return Future.value();
      }

      return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black54,
        builder: (_) =>
            StopDetailBottomSheet(stop: stop, tripModel: tripModel!),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        // crossAxisAlignment: .stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            height: 212,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFF061821), // rất đậm (trái)
                  Color(0xFF0B2634), // trung gian
                  Color(0xFF13384A), // sáng hơn (phải)
                ],
              ),
              borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
            ),
            width: 200,
            child: Column(
              crossAxisAlignment: .start,
              mainAxisAlignment: .start,
              children: [
                const Text(
                  "Description",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF9FB3BF),
                  ),
                ),
                const Spacer(),

                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.secondaryText,
                    ),
                    children: [
                      const TextSpan(
                        text: '“ ',
                        style: TextStyle(fontSize: 24, color: AppColors.border),
                      ),
                      TextSpan(
                        text: tripModel != null ? tripModel!.summary : "",
                      ),
                      const TextSpan(
                        text: ' ”',
                        style: TextStyle(fontSize: 24, color: AppColors.border),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                const Align(
                  alignment: AlignmentGeometry.bottomLeft,
                  child: Row(
                    spacing: 5,
                    children: [
                      Text(
                        "Swipe to start",
                        style: TextStyle(
                          color: AppColors.border,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Icon(Icons.arrow_forward_sharp, color: AppColors.border),
                    ],
                  ),
                ),
              ],
            ),
          ),

          //stop list
          const SizedBox(width: 30),
          Container(
            height: 40,
            width: 40,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(99)),
              color: AppColors.primary,
            ),
            child: const Icon(Icons.home),
          ),

          const SizedBox(
            width: 30,
            child: Center(
              child: Divider(color: AppColors.primary, thickness: 3, height: 2),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: List.generate(stops.length * 2 - 1, (i) {
                // vị trí card
                if (i.isEven) {
                  final index = i ~/ 2;
                  final s = stops[index];
                  return SizedBox(
                    height: height,
                    child: _StopCard(
                      stop: s,
                      onTap: () {
                        // onStopTap?.call(index);
                        showStopBottomSheet(context, stop: s);
                      },
                    ),
                  );
                }

                // separator giữa các card
                return const SizedBox(
                  width: 30,
                  child: Center(
                    child: Divider(
                      color: AppColors.primary,
                      thickness: 3,
                      height: 2,
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(
            width: 30,
            child: Center(
              child: Divider(color: AppColors.primary, thickness: 3, height: 2),
            ),
          ),
          Container(
            height: 40,
            width: 40,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(99)),
              color: AppColors.primary,
            ),
            child: const Icon(Icons.flag),
          ),

          const SizedBox(width: 30),

          //sumary
          Container(
            height: 212,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFF13384A), // sáng hơn (phải)
                  Color(0xFF0B2634), // trung gian
                  Color(0xFF061821), // rất đậm (trái)
                ],
              ),
              borderRadius: BorderRadius.horizontal(left: Radius.circular(20)),
            ),
            width: 200,
            child: Column(
              mainAxisAlignment: .center,
              crossAxisAlignment: .center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (tripModel == null) return;

                    showDialog(
                      context: context,
                      builder: (context) =>
                          TripChatDialog(tripId: tripModel!.id),
                    );
                  },
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        color: AppColors.onPrimary,
                        size: 18,
                      ),
                      SizedBox(width: 6),
                      Text(
                        "Ask about this trip",
                        style: TextStyle(color: AppColors.onPrimary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Nút + nằm giữa các card (giống ảnh)

class _StopCard extends StatelessWidget {
  final PlannerStopEntity stop;
  final VoidCallback? onTap;

  const _StopCard({required this.stop, this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                // BACKGROUND IMAGE
                const Positioned.fill(
                  child: Image(
                    image: AssetImage(AppImages.danang),
                    fit: BoxFit.cover,
                  ),
                ),

                // GRADIENT OVERLAY (tối dưới, sáng trên)
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.15),
                          Colors.black.withOpacity(0.55),
                        ],
                      ),
                    ),
                  ),
                ),

                // CONTENT
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // title
                      const SizedBox(height: 70),
                      Text(
                        stop.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),

                      const Spacer(),

                      // bottom row icons
                      Row(
                        children: [
                          const _MiniStat(
                            icon: Icons.photo_camera_rounded,
                            value: 3,
                          ),

                          const Spacer(),

                          Icon(
                            Icons.place_outlined,
                            color: Colors.white.withOpacity(0.9),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.more_horiz,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final int value;

  const _MiniStat({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.onPrimary),
        const SizedBox(width: 4),
        Text(
          '$value',
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.onPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
