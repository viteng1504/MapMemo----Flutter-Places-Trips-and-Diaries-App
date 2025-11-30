import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'core/services/map/map_service.dart';
import 'core/theme/app_colors.dart';
import 'core/utils/utils.dart';
import 'core/widgets/my_bottom_app_bar.dart';
import 'features/places/presentation/cubits/home_overlay_cubit.dart';
import 'features/places/presentation/screens/explore_overlay_ui.dart';
import 'features/places/presentation/screens/home_overlay_ui.dart';

enum CurrentScreen { home, trips, diaries }

class MapShell extends StatefulWidget {
  const MapShell({super.key});

  @override
  State<MapShell> createState() => _MapShellState();
}

class _MapShellState extends State<MapShell> {
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
  }

  void onNavIconPressed(int index) {
    setState(() => currentTab = index);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<HomeOverlayCubit>(
          create: (homeContext) => HomeOverlayCubit(),
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
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
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
                  },
                  onTapListener: MapService.instance.onSelectPlaceOnMap,
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
        return const ExploreOverlayUI(key: ValueKey("explore"));
      case 2:
        return const ExploreOverlayUI(key: ValueKey("profile"));
      default:
        return const SizedBox.shrink();
    }
  }
}
