import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/services/map/trip_plan_map_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/planner/planner_stop_entity.dart';
import '../widgets/trip_planning_and_tracking/planner/planner_add_destination_overlay_ui.dart';
import '../widgets/trip_planning_and_tracking/planner/planner_place_overlay_ui.dart';
import '../widgets/trip_planning_and_tracking/planner/trip_planner_overlay_ui.dart';
import '../widgets/trip_planning_and_tracking/trip_tracking_overlay_ui.dart';

class TripPlanningAndTrackingScreen extends StatefulWidget {
  const TripPlanningAndTrackingScreen({super.key});

  @override
  _TripPlanningAndTrackingScreenState createState() =>
      _TripPlanningAndTrackingScreenState();
}

enum BaseTab { planner, track }

enum OverlayType { addDestination, place }

class _TripPlanningAndTrackingScreenState
    extends State<TripPlanningAndTrackingScreen> {
  final TripPlanMapService _mapService = TripPlanMapService();

  BaseTab _currentTab = BaseTab.planner;
  final List<OverlayType> _overlayStack = [OverlayType.addDestination];

  bool get _hasOverlay => _overlayStack.isNotEmpty;
  OverlayType? get _topOverlay => _hasOverlay ? _overlayStack.last : null;

  void _showOverlay(OverlayType type) {
    setState(() => _overlayStack.add(type));
  }

  void _popOverlay() {
    if (_overlayStack.isEmpty) return;
    setState(() => _overlayStack.removeLast());
  }

  

  final placesGeoJson = {
    "type": "FeatureCollection",
    "features": [
      {
        "type": "Feature",
        "geometry": {
          "type": "Point",
          "coordinates": [108.2022, 16.0544],
        },
        "properties": {"index": "1", "name": "Ngũ Hành Sơn"},
      },
      {
        "type": "Feature",
        "geometry": {
          "type": "Point",
          "coordinates": [108.2100, 16.0600],
        },
        "properties": {"index": "2", "name": "Hội An"},
      },
      {
        "type": "Feature",
        "geometry": {
          "type": "Point",
          "coordinates": [108.1500, 16.0200],
        },
        "properties": {"index": "3", "name": "Hòa Vang"},
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        bottomNavigationBar: _hasOverlay ? null : _bottomNavigationBar(),
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
            onPressed: () {
              // nếu đang có overlay thì pop overlay
              if (_hasOverlay) {
                _popOverlay();
              } else {
                Navigator.pop(context);
              }
            },
            style: IconButton.styleFrom(
              padding: const EdgeInsets.all(5),
              backgroundColor: AppColors.onSurfaceGray2.withOpacity(.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          backgroundColor: AppColors.onSurfaceGray2.withOpacity(.3),
          title: Text(
            _titleText(),
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: AppColors.onPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: MapWidget(
                key: const ValueKey("map"),
                onMapCreated: (map) async {
                  setState(() {
                    _mapService.setMap(map);
                  });

                  // Bật location component + puck
                  _mapService.map?.location.updateSettings(
                    LocationComponentSettings(
                      enabled: true,
                      pulsingEnabled: true,
                      pulsingColor: Colors.blue.value,
                      showAccuracyRing: true,
                      locationPuck: LocationPuck(
                        locationPuck2D: DefaultLocationPuck2D(),
                      ),
                    ),
                  );

                  // (tuỳ chọn) move camera tới vị trí hiện tại để bạn thấy ngay
                  final pos = await _mapService.getUserPosition();
                  _mapService.map?.setCamera(
                    CameraOptions(
                      center: Point(
                        coordinates: Position(pos.longitude, pos.latitude),
                      ),
                      zoom: 14,
                    ),
                  );

                  _mapService.addOrMoveMarker(Position(108.2022, 16.0544));

                  await _mapService.map?.style.addSource(
                    GeoJsonSource(
                      id: "places-source",
                      data: jsonEncode(placesGeoJson),
                    ),
                  );
                  await _mapService.map?.style.addLayer(
                    CircleLayer(
                      id: "place-circle-layer",
                      sourceId: "places-source",
                      circleRadius: 12,
                      circleColor: Colors.blue.value,
                      circleStrokeColor: Colors.white.value,
                      circleStrokeWidth: 2,
                    ),
                  );

                  // số
                  await _mapService.map?.style.addLayer(
                    SymbolLayer(
                      id: "place-index-layer",
                      sourceId: "places-source",
                      textField: "{index}",
                      textSize: 14,
                      textColor: Colors.white.value,
                      textHaloColor: Colors.black.value,
                      textHaloWidth: 1.5,
                      textAnchor: TextAnchor.CENTER,
                      textAllowOverlap: true,
                    ),
                  );

                  // tên
                  await _mapService.map?.style.addLayer(
                    SymbolLayer(
                      id: "place-name-layer",
                      sourceId: "places-source",
                      textField: "{name}",
                      textSize: 12,
                      textColor: Colors.white.value,
                      textHaloColor: Colors.black.value,
                      textHaloWidth: 1.2,
                      textAnchor: TextAnchor.TOP,
                      textOffset: [0, 1.4],
                      textAllowOverlap: true,
                    ),
                  );
                },
              ),
            ),

            Positioned.fill(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                transitionBuilder: (child, anim) {
                  final offsetTween = Tween<Offset>(
                    begin: const Offset(0, 0.08),
                    end: Offset.zero,
                  );
                  return SlideTransition(
                    position: offsetTween.animate(anim),
                    child: FadeTransition(opacity: anim, child: child),
                  );
                },
                child: _hasOverlay
                    ? _buildOverlayUI(_topOverlay!)
                    : _buildBaseTabUI(_currentTab),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _titleText() {
    // title ưu tiên overlay
    if (_hasOverlay) {
      switch (_topOverlay!) {
        case OverlayType.addDestination:
          return "Add next destination";
        case OverlayType.place:
          return "Place";
      }
    }
    // title base tab
    return _currentTab == BaseTab.planner ? "Planner" : "Track";
  }

  Widget _buildBaseTabUI(BaseTab tab) {
    switch (tab) {
      case BaseTab.planner:
        // ví dụ: trong TripPlannerOverlayUi bạn bắn callback để mở overlay
        return TripPlannerOverlayUi(
          key: const ValueKey("planner"),
          onAddDestinationTap: () => _showOverlay(OverlayType.addDestination),
          onPlaceTap: () => _showOverlay(OverlayType.place),
        );
      case BaseTab.track:
        return TripTrackingOverlayUi(
          key: const ValueKey("track"),

          onPlaceTap: () => _showOverlay(OverlayType.place),
        );
    }
  }

  Widget _buildOverlayUI(OverlayType overlay) {
    switch (overlay) {
      case OverlayType.addDestination:
        return PlannerAddDestinationOverlayUi(
          key: const ValueKey("add_destination"),
          onGetSuggestions: () {},
          onSearchTap: () async {
            final result = await Navigator.pushNamed(
              context,
              AppRoutes.tripDestinationSearch,
            );

            if (result != null) {
              final map = result as Map<String, dynamic>;
              print(map["name"]);
              setState(() {
                // if (des == Destination.start) {
                //   start = map["name"];
                //   startController.text = start;
                // } else {
                //   end = map["name"];
                //   endController.text = end;
                // }
              });
            }
          },
        );
      case OverlayType.place:
        return PlannerPlaceOverlayUi(
          key: const ValueKey("place"),
          onClose: _popOverlay,
        );
    }
  }

  Widget _bottomNavigationBar() {
    return Material(
      elevation: 5,
      shadowColor: const Color.fromARGB(255, 0, 0, 0),
      child: NavigationBar(
        selectedIndex: _currentTab == BaseTab.planner ? 0 : 1,
        onDestinationSelected: (index) {
          setState(() {
            _currentTab = index == 0 ? BaseTab.planner : BaseTab.track;
          });
        },
        backgroundColor: AppColors.onPrimary.withOpacity(.85),
        // elevation trong NavigationBar đôi khi không “ăn” rõ
        elevation: 0,
        indicatorColor: AppColors.primary.withOpacity(0.25),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.event_note_outlined),
            selectedIcon: Icon(Icons.event_note_outlined),
            label: "Planner",
          ),
          NavigationDestination(
            icon: Icon(Icons.my_location_outlined),
            selectedIcon: Icon(Icons.my_location_outlined),
            label: "Track",
          ),
        ],
      ),
    );
  }
}
