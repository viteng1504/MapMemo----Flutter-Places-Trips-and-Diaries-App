import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/planner/planner_place_entity.dart';
import '../../../../domain/entities/planner/planner_stop_entity.dart';

class PlannerPlaceOverlayUi extends StatefulWidget {
  final VoidCallback onClose;
  final PlannerPlaceEntity place;
  final bool isLoading;
  final Function(PlannerStopEntity) onAddToPlan;
  final int nextStopIndex;

  const PlannerPlaceOverlayUi({
    super.key,
    required this.onClose,
    required this.place,
    required this.isLoading,
    required this.onAddToPlan,
    required this.nextStopIndex,
  });

  @override
  _PlannerPlaceOverlayUiState createState() => _PlannerPlaceOverlayUiState();
}

class _PlannerPlaceOverlayUiState extends State<PlannerPlaceOverlayUi> {
  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.fromLTRB(16, 10, 16, 16 + bottomInset),
          decoration: const BoxDecoration(
            color: Color(0xFFE9EAEC),
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
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
              // Grab handle
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 14),
              widget.isLoading == true
                  ? const CircularProgressIndicator.adaptive()
                  : Column(
                      children: [
                        Row(
                          spacing: 4,
                          children: [
                            Image.network(
                              widget.place.countryIconUrl,
                              fit: BoxFit.cover,
                              width: 28,
                              height: 28,
                            ),
                            Text(
                              widget.place.country,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),
                        Text(
                          widget.place.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),

              const SizedBox(height: 14),

              // Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final id = const Uuid().v4();
                    final name = widget.place.name;
                    final lat = widget.place.lat;
                    final lng = widget.place.lng;
                    final stopIndex = widget.nextStopIndex;
                    const nights = 0;

                    final PlannerStopEntity plannerStopEntity =
                        PlannerStopEntity(
                          id: id,
                          lat: lat,
                          lng: lng,
                          name: name,
                          nights: nights,
                          stopIndex: stopIndex,
                        );
                    widget.onAddToPlan(plannerStopEntity);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text(
                    'Add to plan',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary, // đỏ như hình
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
