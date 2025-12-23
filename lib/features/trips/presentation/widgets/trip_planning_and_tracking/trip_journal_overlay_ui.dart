import 'package:flutter/material.dart';

import '../../../data/models/trip_model.dart';
import '../../../domain/entities/planner/planner_stop_entity.dart';
import 'journal/trip_stops_strip.dart';

class TripJournalOverlayUi extends StatefulWidget {
  final List<PlannerStopEntity> plannerStops;
  final TripModel? tripModel;
  const TripJournalOverlayUi({
    super.key,
    required this.plannerStops,
    this.tripModel,
  });

  @override
  _TripJournalOverlayUiState createState() => _TripJournalOverlayUiState();
}

class _TripJournalOverlayUiState extends State<TripJournalOverlayUi> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: double.infinity,
          // padding: EdgeInsets.fromLTRB(16, 10, 16, 16 + bottomInset),
          decoration: const BoxDecoration(
            color: Color(0xFFE9EAEC),
            boxShadow: [
              BoxShadow(
                blurRadius: 20,
                color: Colors.black26,
                offset: Offset(0, -6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TripStopsStrip(
                stops: widget.plannerStops,
                tripModel: widget.tripModel,
                onStopTap: (i) {
                  // handle tap stop
                },
                onAddStop: () {
                  // nếu bạn muốn bắt sự kiện add, mình sẽ gợi ý cách gắn vào nút +
                },
              ),

              // Divider + "or"
            ],
          ),
        ),
      ),
    );
  }
}
