import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/services/map/trip_plan_map_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/data_sources/remote/trip_planner_service.dart';
import '../../data/models/trip_model.dart';
import '../../domain/entities/planner/planner_place_entity.dart';
import '../../domain/entities/planner/planner_stop_entity.dart';
import '../widgets/trip_planning_and_tracking/planner/planner_add_destination_overlay_ui.dart';
import '../widgets/trip_planning_and_tracking/planner/planner_place_overlay_ui.dart';
import '../widgets/trip_planning_and_tracking/planner/trip_planner_overlay_ui.dart';
import '../widgets/trip_planning_and_tracking/trip_journal_overlay_ui.dart';

class TripPlanningAndTrackingScreen extends StatefulWidget {
  const TripPlanningAndTrackingScreen({super.key});

  @override
  _TripPlanningAndTrackingScreenState createState() =>
      _TripPlanningAndTrackingScreenState();
}

enum BaseTab { planner, journal }

enum OverlayType { plannerAddDestination, plannerPlace }

class _TripPlanningAndTrackingScreenState
    extends State<TripPlanningAndTrackingScreen> {
  final SupabaseClient client = Supabase.instance.client;

  final TripPlanMapService _mapService = TripPlanMapService();
  late final TripPlannerService _plannerService = TripPlannerService(client);

  PlannerPlaceEntity? _plannerPlaceEntity = const PlannerPlaceEntity(
    country: 'Vietnam',
    countryIconUrl: 'https://picsum.photos/400/300?random=1',
    name: 'Da Nang',
    lat: 16.0544,
    lng: 108.2022,
  );

  TripModel? _tripModel;

  // List<P

  int _nextStopIndex = 1;
  bool plannerPlaceLoading = false;
  List<PlannerStopEntity>? plannerStops;
  bool get _isGettingPlannerStop => plannerStops == null;

  BaseTab _currentTab = BaseTab.planner;
  final List<OverlayType> _overlayStack = [];

  bool get _hasOverlay => _overlayStack.isNotEmpty;
  OverlayType? get _topOverlay => _hasOverlay ? _overlayStack.last : null;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _mapService.dispose();
    super.dispose();
  }

  void _showOverlay(OverlayType type) {
    setState(() => _overlayStack.add(type));
  }

  void _popOverlay() {
    if (_overlayStack.isEmpty) return;
    setState(() => _overlayStack.removeLast());
  }

  //get stop on initialize ============================================================
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;

    _tripModel = ModalRoute.of(context)!.settings.arguments as TripModel;
    _getPlannerStops();

    _initialized = true;
  }

  // planner select on map============================================================
  Future<void> _onSelectOnMap(MapContentGestureContext mapContext) async {
    print("planner tap on map=============");
    if (_topOverlay != OverlayType.plannerPlace) {
      _showOverlay(OverlayType.plannerPlace);
    }

    setState(() {
      plannerPlaceLoading = true;
    });

    print(
      "tap on map ===============================================$_nextStopIndex",
    );
    final place = await _mapService.onSelectPlaceOnMap(
      mapContext,
      _nextStopIndex,
    );

    if (!mounted) return;
    setState(() {
      _plannerPlaceEntity = place;
      plannerPlaceLoading = false;
    });
  }

  // planner search bar tap============================================================
  Future<void> _onSearchLocationTap() async {
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.tripDestinationSearch,
    );

    if (result != null) {
      final map = result as Map<String, dynamic>;

      final lat = map['lat'] as double;
      final lng = map['lng'] as double;
      final name = map['full'] as String;
      final resultPlace = PlannerPlaceEntity(
        country: map['country'],
        countryIconUrl: map['icon'],
        name: map['full'],
        lat: lat,
        lng: lng,
      );
      setState(() {
        _plannerPlaceEntity = resultPlace;
        _mapService.plannerShowPointOnMap(
          index: 0,
          displayName: name,
          lng: lng,
          lat: lat,
        );
        _mapService.flyToPosition(lng, lat);
      });
      _showOverlay(OverlayType.plannerPlace);
    }
  }

  // get planner stops============================================================
  Future<void> _getPlannerStops() async {
    final stops = await _plannerService.getStopsByTrip(_tripModel!.id);

    await _mapService.buildStopsFeatureCollection(stops);
    await _mapService.updatePlacesSource();

    if (!mounted) return;

    setState(() {
      plannerStops = stops;
      _nextStopIndex = stops.length + 1;
    });
  }

  // add to plan============================================================
  Future<void> _onAddToPlan(PlannerStopEntity stopEntity) async {
    if (_tripModel == null) return;
    final tripId = _tripModel!.id;
    await _plannerService.addStop(tripId: tripId, stop: stopEntity);

    plannerStops!.add(stopEntity);
    await _mapService.addStopToPlan();
    setState(() {
      _overlayStack.clear();
      _nextStopIndex = plannerStops!.length + 1;
    });
    print("===================================add to plan");
  }

  Future<void> _onAddAiStopToPlan(PlannerStopEntity stopEntity) async {
    if (_tripModel == null) return;
    final tripId = _tripModel!.id;
    await _plannerService.addStop(tripId: tripId, stop: stopEntity);

    plannerStops!.add(stopEntity);
    await _mapService.addAiStopToPlan(stopEntity);
    setState(() {
      _overlayStack.clear();
      _nextStopIndex = plannerStops!.length + 1;
    });
    print("===================================add to plan");
  }

  // destination tap============================================================
  void onAddDestinationTap(int nextStopIndex) {
    setState(() {
      _nextStopIndex = nextStopIndex;
      print("nextstop =======================================$_nextStopIndex");
    });
    _showOverlay(OverlayType.plannerAddDestination);
    _mapService.flyToUser();
  }

  // +- nights============================================================
  int get totalStopDays {
    final stops = plannerStops;
    if (stops == null) return 0;
    return stops.fold<int>(0, (sum, s) => sum + s.nights);
  }

  void increaseNights(int index) {
    final stops = plannerStops;
    if (stops == null) return;
    if (index < 0 || index >= stops.length) return;

    if (totalStopDays >= _tripModel!.days) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'The total number of days that have reached the maximum number of trip days',
          ),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    final int newNights = stops[index].nights + 1;

    setState(() {
      plannerStops![index] = plannerStops![index].copyWith(nights: newNights);
    });

    _plannerService.scheduleUpdateStopNights(
      stopId: plannerStops![index].id,
      nights: newNights,
    );
  }

  void decreaseNights(int index) {
    if (plannerStops == null) return;

    final currentNights = plannerStops![index].nights;
    if (currentNights <= 0) return;

    final int newNights = currentNights - 1;

    setState(() {
      plannerStops![index] = plannerStops![index].copyWith(nights: newNights);
    });

    _plannerService.scheduleUpdateStopNights(
      stopId: plannerStops![index].id,
      nights: newNights,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        bottomNavigationBar: _hasOverlay ? null : _bottomNavigationBar(),
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
            onPressed: () async {
              // nếu đang có overlay thì pop overlay
              if (_hasOverlay) {
                _popOverlay();

                if (_overlayStack.isEmpty && plannerStops != null) {
                  _nextStopIndex = plannerStops!.length + 1;
                }
                print(
                  "${_mapService.tempFeature != null}  ============================================================",
                );
                if (_mapService.tempFeature != null) {
                  print(
                    "reset feature ============================================================",
                  );
                  _mapService.resetTempFeature();
                  await _mapService.updatePlacesSource();
                }
                //
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
                onTapListener: (mapContext) {
                  _onSelectOnMap(mapContext);
                },
                onCameraChangeListener: (_) async {
                  if (!_mapService.styleReady) {
                    await _mapService.onStyleReady();

                    // khi style + source đã sẵn → update map
                    if (plannerStops != null) {
                      await _mapService.buildStopsFeatureCollection(
                        plannerStops!,
                      );
                      await _mapService.updatePlacesSource();
                      await _mapService.updateRouteLineFromFeatures();
                    }
                  }
                },
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
                      zoom: 4,
                    ),
                  );
                },
              ),
            ),

            Positioned.fill(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
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
        case OverlayType.plannerAddDestination:
          return "Add next destination";
        case OverlayType.plannerPlace:
          return "Place";
      }
    }
    // title base tab
    return _currentTab == BaseTab.planner ? "Planner" : "Journal";
  }

  //base tab
  Widget _buildBaseTabUI(BaseTab tab) {
    switch (tab) {
      case BaseTab.planner:
        return TripPlannerOverlayUi(
          key: const ValueKey("planner"),
          onAddDestinationTap: onAddDestinationTap,
          plannerStops: plannerStops ?? [],
          onShowPlaceTap: () => _showOverlay(OverlayType.plannerPlace),
          isGettingPlannerStop: _isGettingPlannerStop,
          onFlyToUser: _mapService.flyToUser,
          tripStartDate: _tripModel!.startDate,
          tripDays: _tripModel!.days,
          decreaseNights: decreaseNights,
          increaseNights: increaseNights,
          tripModel: _tripModel,
          onAddToPlan: _onAddAiStopToPlan,
        );
      case BaseTab.journal:
        return TripJournalOverlayUi(
          key: const ValueKey("journal"),
          plannerStops: plannerStops ?? [],
          tripModel: _tripModel,
          // onPlaceTap: () => _showOverlay(OverlayType.plannerPlace),
        );
    }
  }

  // Overlay UI
  Widget _buildOverlayUI(OverlayType overlay) {
    switch (overlay) {
      case OverlayType.plannerAddDestination:
        return PlannerSearchDestinationOverlayUi(
          key: const ValueKey("add_destination"),
          onGetSuggestions: () {},
          onSearchTap: () async {
            _onSearchLocationTap();
          },
        );
      case OverlayType.plannerPlace:
        return PlannerPlaceOverlayUi(
          key: const ValueKey("place"),
          onClose: _popOverlay,
          place:
              _plannerPlaceEntity ??
              const PlannerPlaceEntity(
                country: 'Unknown',
                countryIconUrl: 'https://picsum.photos/400/300?random=1',
                name: 'Unknown',
                lat: 16.0544,
                lng: 108.2022,
              ),
          isLoading: plannerPlaceLoading,
          onAddToPlan: _onAddToPlan,
          nextStopIndex: _nextStopIndex,
        );
    }
  }

  Widget _bottomNavigationBar() {
    return Material(
      elevation: 1,
      child: NavigationBar(
        selectedIndex: _currentTab == BaseTab.planner ? 0 : 1,
        onDestinationSelected: (index) {
          setState(() {
            _currentTab = index == 0 ? BaseTab.planner : BaseTab.journal;
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
            icon: Icon(Icons.collections_bookmark),
            selectedIcon: Icon(Icons.collections_bookmark),
            label: "Journal",
          ),
        ],
      ),
    );
  }
}
