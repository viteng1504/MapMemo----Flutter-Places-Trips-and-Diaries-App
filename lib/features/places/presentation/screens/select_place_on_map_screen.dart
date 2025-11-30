import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../../../core/services/map/add_place_map_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/home_search_bar.dart';

class SelectPlaceOnMapScreen extends StatefulWidget {
  const SelectPlaceOnMapScreen({super.key});

  @override
  _SelectPlaceOnMapScreenState createState() => _SelectPlaceOnMapScreenState();
}

class _SelectPlaceOnMapScreenState extends State<SelectPlaceOnMapScreen> {
  final AddPlaceMapService _mapService = AddPlaceMapService();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Scaffold(
        // backgroundColor: Colors.transparent, // nền trong suốt
        body: Stack(
          children: [
            Positioned.fill(
              child: MapWidget(
                key: const ValueKey("map"),

                onMapCreated: (map) async {
                  setState(() {
                    _mapService.setMap(map);
                  });

                  final pos = await _mapService.getUserPosition();

                  final userLatLng = Point(
                    coordinates: Position(pos.longitude, pos.latitude),
                  );

                  map.flyTo(
                    CameraOptions(center: userLatLng, zoom: 10),
                    MapAnimationOptions(duration: 1000),
                  );

                  _mapService.map?.location.updateSettings(
                    LocationComponentSettings(
                      enabled: true,
                      pulsingEnabled: true,
                      pulsingColor: AppColors.primary.value,
                      showAccuracyRing: true,
                    ),
                  );

                  _mapService.addOrMoveMarker(Position(108.2022, 16.0544));
                },
                onTapListener: _mapService.onSelectPlaceOnMap,
              ),
            ),
            const Positioned(
              top: 20,
              left: 16,
              right: 16,
              child: IgnorePointer(
                ignoring: false,
                child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 300),
                  child: HomeSearchBar(hintText: 'Search locations'),
                ),
              ),
            ),

            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.background2,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                padding: const EdgeInsets.all(8),
                height: 120,
                child: Column(
                  children: [
                    Center(
                      child: Text(
                        "Tap on the map to select place",
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: .spaceAround,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.onSurfaceGray2,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            "Cancel",
                            style: theme.textTheme.bodyMedium!.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),

                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                          ),
                          onPressed: () {},
                          child: Text(
                            "Select this place",
                            style: theme.textTheme.bodyMedium!.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.onPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
