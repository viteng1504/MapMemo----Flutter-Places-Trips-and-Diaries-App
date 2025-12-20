import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/utils/utils.dart';
import '../../../../domain/entities/planner/planner_stop_entity.dart';
import 'start_plan_trip.dart';

class TripPlannerOverlayUi extends StatefulWidget {
  final Function(int) onAddDestinationTap;
  final VoidCallback onShowPlaceTap;
  final bool isGettingPlannerStop;
  final List<PlannerStopEntity> plannerStops;
  final VoidCallback onFlyToUser;
  final DateTime tripStartDate;
  final int tripDays;
  final Function(int) increaseNights;
  final Function(int) decreaseNights;

  const TripPlannerOverlayUi({
    super.key,
    required this.onAddDestinationTap,
    required this.plannerStops,
    required this.onShowPlaceTap,
    required this.isGettingPlannerStop,
    required this.onFlyToUser,
    required this.tripStartDate,
    required this.tripDays,
    required this.increaseNights,
    required this.decreaseNights,
  });

  @override
  _TripPlannerOverlayUiState createState() => _TripPlannerOverlayUiState();
}

class _TripPlannerOverlayUiState extends State<TripPlannerOverlayUi> {
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  bool hasPlaces = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.onFlyToUser();
  }

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
      // hasPlaces = true;
    });
    widget.onAddDestinationTap(0);
  }

  //Has places fuction

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: 0.13, // mở mặc định
      minChildSize: 0.13, // kéo xuống thấp nhất
      maxChildSize: 0.7, // kéo lên cao nhất
      snap: true,
      snapSizes: const [0.13, 0.55, 0.7], // các mốc snap
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
                          _pill(
                            icon: Icons.home_rounded,
                            text: "Trip started",
                            date: widget.tripStartDate,
                          ),
                          const Spacer(),
                          _pill(icon: Icons.calendar_month, text: "Day trip"),
                        ],
                      ),

                      //getting stop
                      if (widget.isGettingPlannerStop)
                        const Column(
                          children: [
                            SizedBox(height: 70),

                            Align(
                              alignment: AlignmentGeometry.center,
                              child: CircularProgressIndicator.adaptive(),
                            ),
                          ],
                        )
                      else
                        widget.plannerStops.isEmpty
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
                                    children: (() {
                                      DateTime currentCheckInDate =
                                          widget.tripStartDate;

                                      return List.generate(
                                        widget.plannerStops.length,
                                        (index) {
                                          final stop =
                                              widget.plannerStops[index];

                                          final DateTime stopCheckInDate =
                                              currentCheckInDate;
                                          final DateTime stopCheckOutDate =
                                              currentCheckInDate.add(
                                                Duration(days: stop.nights),
                                              );

                                          // cập nhật cho stop tiếp theo
                                          currentCheckInDate = stopCheckOutDate;

                                          return _stopCard(
                                            index: index + 1,
                                            stopName: stop.name,
                                            night: stop.nights,
                                            fromDate: Utils.fmt(
                                              stopCheckInDate,
                                            ),
                                            toDate: Utils.fmt(stopCheckOutDate),
                                          );
                                        },
                                      );
                                    })(),
                                  ),
                                  Align(
                                    alignment: .topLeft,
                                    child: _pill(
                                      icon: Icons.flag,
                                      text: "Trip Finished",
                                      date: widget.tripStartDate.add(
                                        Duration(days: widget.tripDays),
                                      ),
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

  static Widget _pill({
    required IconData icon,
    required String text,
    DateTime? date,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        spacing: 5,
        mainAxisSize: .min,
        children: [
          Icon(icon, size: 18, color: AppColors.onSurface),

          Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    text,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              if (date != null)
                Text(
                  Utils.fmt(date),
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stopCard({
    required int index,
    required String stopName,
    required int night,
    required String fromDate,
    required String toDate,
  }) {
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
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
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
                        stopName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "$fromDate - $toDate",
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
                    _roundIcon(
                      icon: Icons.remove,
                      onChangeNights: () {
                        widget.decreaseNights(index - 1);
                      },
                    ),
                    const SizedBox(width: 10),
                    Column(
                      children: [
                        Text(
                          night.toString(),
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Text("nights", style: TextStyle(fontSize: 11)),
                      ],
                    ),
                    const SizedBox(width: 10),
                    _roundIcon(
                      icon: Icons.add,
                      onChangeNights: () {
                        widget.increaseNights(index - 1);
                      },
                    ),
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
      onTap: () {
        print("=-========================================$index");
        widget.onAddDestinationTap(index + 1);
      },
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

            _roundIcon(icon: Icons.add),

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

  static Widget _roundIcon({
    required IconData icon,
    VoidCallback? onChangeNights,
  }) {
    return InkWell(
      onTap: onChangeNights,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F2F4),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.onSurfaceGray2),
        ),
        child: Icon(icon, size: 18, color: AppColors.onSurface),
      ),
    );
  }
}
