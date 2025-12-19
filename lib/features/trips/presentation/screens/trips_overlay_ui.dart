import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/my_primary_button.dart';
import '../../../../my_local_storage.dart';
import '../../data/models/trip_model.dart';
import '../cubits/trip_overlay_cubit.dart';
import '../cubits/trip_overlay_state.dart';
import '../widgets/trip/drag_handle.dart';
import '../widgets/trip/trip_card.dart';
import '../widgets/trip/trip_type_bottom_sheet.dart';

class TripsOverlayUi extends StatefulWidget {
  const TripsOverlayUi({super.key});

  @override
  State<TripsOverlayUi> createState() => _TripsOverlayUiState();
}

class _TripsOverlayUiState extends State<TripsOverlayUi> {
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  @override
  void initState() {
    super.initState();
  }

  Future<void> showTripTypeBottomSheet(BuildContext context) async {
    final tripModel = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const TripTypeBottomSheet(),
    );

    if (!context.mounted || tripModel == null) return;

    Navigator.pushNamed(
      context,
      AppRoutes.tripPlanningAndTracking,
      arguments: tripModel,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final List<TripModel> tripModels = MyLocalStorage.trips;

    return BlocProvider(
      create: (context) => TripOverlayCubit()..zoomOutMap(),
      child: BlocConsumer<TripOverlayCubit, TripOverlayState>(
        listener: (context, state) {},
        builder: (context, state) {
          return Stack(
            children: [
              // ===== DRAGGABLE SHEET =====
              DraggableScrollableSheet(
                controller: _sheetController,
                initialChildSize: 0.2,
                minChildSize: 0.2,
                maxChildSize: 0.75,
                snap: true,
                snapSizes: const [0.2, 0.5, 0.75],
                snapAnimationDuration: const Duration(milliseconds: 150),
                builder: (context, controller) {
                  return Container(
                    decoration: const BoxDecoration(
                      color: AppColors.background2,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      // boxShadow: [
                      //   BoxShadow(color: AppColors.shadow, blurRadius: 1),
                      // ],
                    ),
                    child: ListView(
                      controller: controller,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 24,
                      ),
                      children: [
                        // drag handle
                        const DragHandle(),

                        const SizedBox(height: 10),
                        Text(
                          "My Trips",
                          style: theme.textTheme.titleLarge!.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 20),

                        MyPrimaryButton(
                          onPressed: () {
                            showTripTypeBottomSheet(context);
                          },
                          label: "+ Add a past, current or future trip",
                        ),

                        const SizedBox(height: 20),

                        Column(
                          spacing: 10,
                          children: List.generate(tripModels.length, (index) {
                            final trip = tripModels[index];

                            return TripCard(trip: trip);
                          }),
                        ),

                        const SizedBox(height: 80),

                      ],
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
