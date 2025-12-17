import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/planner/planner_stop_entity.dart';
import 'start_plan_trip.dart';

class TripPlannerOverlayUi extends StatefulWidget {
  final VoidCallback onAddDestinationTap;
  final VoidCallback onPlaceTap;

  const TripPlannerOverlayUi({
    super.key,
    required this.onAddDestinationTap,
    required this.onPlaceTap,
  });

  @override
  _TripPlannerOverlayUiState createState() => _TripPlannerOverlayUiState();
}

class _TripPlannerOverlayUiState extends State<TripPlannerOverlayUi> {
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  bool hasPlaces = false;

  //sort date
  DateTime normalizeDate(DateTime d) => DateTime(d.year, d.month, d.day);

  DateTime startDateOfStop({
    required DateTime tripStartDate,
    required List<PlannerStopEntity> stops, // sorted by index
    required int i,
  }) {
    final start = normalizeDate(tripStartDate);

    int offsetDays = 0;
    for (int k = 0; k < i; k++) {
      offsetDays += stops[k].nights;
    }

    return start.add(Duration(days: offsetDays));
  }

  DateTime endDateOfStop({
    required DateTime tripStartDate,
    required List<PlannerStopEntity> stops,
    required int i,
  }) {
    final s = startDateOfStop(tripStartDate: tripStartDate, stops: stops, i: i);
    return s.add(Duration(days: stops[i].nights));
  }

  //No places in list fuction
  Future<void> _onGetPersonalize() async {
    return;
  }

  Future<void> _onManualBuildItinery() async {
    setState(() {
      hasPlaces = true;
    });
  }

  //Has places fuction

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: 0.55, // mở mặc định
      minChildSize: 0.11, // kéo xuống thấp nhất
      maxChildSize: 0.7, // kéo lên cao nhất
      snap: true,
      snapSizes: const [0.11, 0.55, 0.7], // các mốc snap
      builder: (context, scrollController) {
        return ClipRRect(
          clipBehavior: .hardEdge,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF5F6F8),
              boxShadow: [
                BoxShadow(
                  blurRadius: 12,
                  color: Colors.black26,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                SingleChildScrollView(
                  child: Column(
                    mainAxisSize: .max,
                    children: [
                      const SizedBox(height: 10),
                      // thanh kéo (grab handle)
                      Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // header giống kiểu "Trip started" / "Day trip"
                      Row(
                        children: [
                          _pill(icon: Icons.home_rounded, text: "Trip started"),
                          const Spacer(),
                          _pill(icon: Icons.calendar_month, text: "Day trip"),
                        ],
                      ),

                      hasPlaces == false
                          ? StartPlanTrip(
                              onGetPersonalize: _onGetPersonalize,
                              onManualBuildItinery: _onManualBuildItinery,
                            )
                          : Column(
                              children: [
                                Align(
                                  alignment: .topLeft,
                                  child: _addSeparator(0),
                                ),
                                Column(
                                  children: List.generate(12, (index) {
                                    return _stopCard(index: index + 1);
                                  }).toList(),
                                ),
                                Align(
                                  alignment: .topLeft,
                                  child: _pill(
                                    icon: Icons.flag,
                                    text: "Trip Finished",
                                  ),
                                ),

                                const SizedBox(height: 20),
                              ],
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _pill({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppColors.onSurface),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _stopCard({required int index}) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Slidable(
          endActionPane: ActionPane(
            motion: const DrawerMotion(),
            extentRatio: 0.4, // độ rộng vùng action
            children: [
              SlidableAction(
                onPressed: (_) {},
                backgroundColor: const Color(0xFF3F4656),
                foregroundColor: Colors.white,
                icon: Icons.check_circle,
                label: 'Visited',
                borderRadius: BorderRadius.circular(18),
              ),
              SlidableAction(
                onPressed: (_) {},
                backgroundColor: const Color(0xFFD94B3D),
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: 'Delete',
                borderRadius: BorderRadius.circular(18),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                // avatar + số thứ tự
                Stack(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: Container(
                        width: 22,
                        height: 22,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Text(
                          "$index",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),

                // title + date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Stop $index",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "T.2 1 TH12 - T.3 2 TH12",
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // +/- nights
                Row(
                  children: [
                    _roundIcon(Icons.remove),
                    const SizedBox(width: 10),
                    const Column(
                      children: [
                        Text(
                          "1",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text("nights", style: TextStyle(fontSize: 11)),
                      ],
                    ),
                    const SizedBox(width: 10),
                    _roundIcon(Icons.add),
                  ],
                ),
              ],
            ),
          ),
        ),

        //add stop
        _addSeparator(index),
      ],
    );
  }

  Widget _addSeparator(int index) {
    return InkWell(
      onTap: widget.onAddDestinationTap,
      child: Padding(
        padding: const EdgeInsetsGeometry.directional(start: 20),
        child: Column(
          children: [
            const SizedBox(
              height: 7,
              child: VerticalDivider(
                thickness: 2,
                width: 10,
                color: AppColors.onSurfaceGray2,
              ),
            ),

            _roundIcon(Icons.add),

            const SizedBox(
              height: 7,
              child: VerticalDivider(
                thickness: 2,
                width: 10,
                color: AppColors.onSurfaceGray2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _roundIcon(IconData icon) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F2F4),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.onSurfaceGray2),
      ),
      child: Icon(icon, size: 18, color: AppColors.onSurface),
    );
  }
}
