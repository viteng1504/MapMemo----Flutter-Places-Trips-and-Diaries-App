import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:http/http.dart' as http;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/constants/app_api.dart';
import 'core/services/map/map_service.dart';
import 'core/theme/app_colors.dart';
import 'core/utils/utils.dart';
import 'core/widgets/my_bottom_app_bar.dart';
import 'features/auth/data/data_sources/remote/auth_api.dart';
import 'features/places/presentation/cubits/home_overlay_cubit.dart';
import 'features/places/presentation/screens/home_overlay_ui.dart';
import 'features/trips/data/data_sources/remote/trip_service.dart';
import 'features/trips/data/models/trip_model.dart';
import 'features/trips/presentation/screens/trips_overlay_ui.dart';
import 'my_local_storage.dart';

enum CurrentScreen { home, trips, diaries }

class MapShell extends StatefulWidget {
  const MapShell({super.key});

  @override
  State<MapShell> createState() => _MapShellState();
}

class _MapShellState extends State<MapShell> {
  final client = Supabase.instance.client;
  late TripService tripService;
  // MapboxMap? mapbox;
  Map<dynamic, String> tabsName = {0: "Home", 1: "Trips"};
  int currentTab = 0;

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    Future.delayed(Duration.zero, () {
      Utils.checkLocationPermission();
    });

    getTrips();
  }

  Future<void> getTrips() async {
    tripService = TripService(client);
    final List<TripModel> tripModels = await tripService.getMyTrips();

    MyLocalStorage.trips = tripModels;

    print('========== TRIPS ==========');
    for (final trip in MyLocalStorage.trips) {
      print(
        'id: ${trip.id} | '
        'name: ${trip.name} | '
        'start: ${trip.startDate} | '
        'days: ${trip.days} | '
        'image: ${trip.imageUrl}',
      );
    }
    print('===========================');
  }

  void onNavIconPressed(int index) {
    setState(() => currentTab = index);
  }

  Future<List<Position>> fetchRoute() async {
    final mapboxToken = AppApi.mapboxAccessToken;

    final url =
        'https://api.mapbox.com/directions/v5/mapbox/driving/105.8342,21.0278;106.6881,20.8449?geometries=geojson&overview=full&access_token=$mapboxToken';

    final res = await http.get(Uri.parse(url));
    final data = jsonDecode(res.body);

    final coords = (data['routes'][0]['geometry']['coordinates'] as List)
        .cast<List>();
    final positions = coords
        .map((c) => Position(c[0] as double, c[1] as double))
        .toList();

    return positions;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<HomeOverlayCubit>(
          create: (homeContext) => HomeOverlayCubit(AuthApi(client)),
        ),
      ],
      child: SafeArea(
        child: Scaffold(
          extendBody: true,

          extendBodyBehindAppBar: true,
          appBar: AppBar(
            elevation: 70,
            backgroundColor: AppColors.onPrimary.withOpacity(.1),
            title: Text(
              tabsName[currentTab]!,
              style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                color: AppColors.onPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: Builder(
            builder: (fabContext) {
              return FloatingActionButton(
                shape: const CircleBorder(),
                onPressed: () async {
                  if (currentTab != 0) {
                    setState(() => currentTab = 0);
                    final ok = await Utils.checkLocationPermission();
                    if (!ok) return;

                    final pos = await geo.Geolocator.getCurrentPosition(
                      desiredAccuracy: geo.LocationAccuracy.high,
                    );

                    MapService.instance.flyToUser(pos);
                  } else {
                    fabContext.read<HomeOverlayCubit>().showLocationActionSheet(
                      context,
                    );
                  }
                },

                child: Icon(
                  currentTab == 0 ? Icons.add : Icons.circle,
                  color: AppColors.onPrimary,
                ),
              );
            },
          ),

          body: Stack(
            children: [
              Positioned.fill(
                child: MapWidget(
                  key: const ValueKey("map"),

                  onMapCreated: (map) async {
                    setState(() {
                      MapService.instance.setMap(map);
                      MapService.instance.mapReady.complete();
                    });

                    MapService.instance.map?.location.updateSettings(
                      LocationComponentSettings(
                        enabled: true,
                        pulsingEnabled: true,
                        pulsingColor: Colors.blue.value,
                        showAccuracyRing: true,

                        
                      ),
                    );

                    MapService.instance.addOrMoveMarker(
                      Position(108.2022, 16.0544),
                    );

                    final positions = await fetchRoute();

                    final geojson = {
                      "type": "Feature",
                      "geometry": {
                        "type": "LineString",
                        "coordinates": positions
                            .map((p) => [p.lng, p.lat])
                            .toList(), // [lng, lat]
                      },
                      "properties": {},
                    };

                    // 1) Thêm source
                    await MapService.instance.map!.style.addSource(
                      GeoJsonSource(
                        id: "route-source",
                        data: jsonEncode(geojson),
                      ),
                    );

                    // 2) Thêm layer
                    await MapService.instance.map!.style.addLayer(
                      LineLayer(
                        id: "route-layer",
                        sourceId: "route-source",
                        lineColor: 0xFF007AFF, // xanh dương
                        lineWidth: 2.0,
                        lineCap: LineCap.ROUND,
                        lineJoin: LineJoin.ROUND,
                        lineDasharray: [2.0, 2.0], // 👈 nét đứt
                      ),
                    );
                  },

                  // onTapListener: MapService.instance.onSelectPlaceOnMap,
                ),
              ),

              Positioned.fill(
                child: IgnorePointer(
                  ignoring: false,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _buildTabUI(currentTab),
                  ),
                ),
              ),
            ],
          ),

          bottomNavigationBar: MyBottomAppBar(
            currentTab: currentTab,
            onNavIconPressed: onNavIconPressed,
          ),
        ),
      ),
    );
  }

  // UI Overlays
  Widget _buildTabUI(int index) {
    switch (index) {
      case 0:
        return const HomeOverlayUI(key: ValueKey("home"));
      case 1:
        return const TripsOverlayUi(key: ValueKey("explore"));
      case 2:
        return const TripsOverlayUi(key: ValueKey("profile"));
      default:
        return const SizedBox.shrink();
    }
  }
}
