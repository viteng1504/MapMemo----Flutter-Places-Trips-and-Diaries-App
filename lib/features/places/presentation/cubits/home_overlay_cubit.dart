import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart'
    show MapboxMap, Point, Position;

import '../../../../core/constants/app_routes.dart';
import '../../../../core/services/map/map_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/user_position.dart';
import 'home_overlay_state.dart';

class HomeOverlayCubit extends Cubit<HomeOverlayState> {
  HomeOverlayCubit() : super(HomeOverlayState(places: [], mapbox: null));

  void onInitialMapBox(MapboxMap? map) {
    emit(state.copyWith(mapbox: map));
  }

  Future<void> navigateToUserPos() async {
    final pos = await geo.Geolocator.getCurrentPosition(
      desiredAccuracy: geo.LocationAccuracy.high,
    );

    final userLatLng = Point(
      coordinates: Position(pos.longitude, pos.latitude),
    );

    print("Navigate $pos");

    MapService.instance.flyToUser(pos);
  }

  void showLocationActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.my_location,
                  color: AppColors.primary,
                ),
                title: const Text("Save current position"),
                onTap: () async {
                  // final ok = await Utils.checkLocationPermission();
                  // if (!ok) return;
                  print("Save current position");
                  final pos = await geo.Geolocator.getCurrentPosition(
                    desiredAccuracy: geo.LocationAccuracy.high,
                  );

                  MapService.instance.flyToUser(pos);

                  Navigator.pushNamed(
                    context,
                    AppRoutes.placeDetails,
                    arguments: UserPosition(pos.longitude, pos.latitude),
                  );

                  // TODO: thêm logic lưu vị trí
                },
              ),

              const Divider(color: AppColors.onSurfaceGray3),

              ListTile(
                leading: const Icon(
                  Icons.add_location_alt,
                  color: AppColors.primary,
                ),
                title: const Text("Save position on map"),
                onTap: () {
                  // TODO: bật chế độ chọn vị trí
                  // MapService.instance.enableSelectMode();
                  print("add  place");
                  Navigator.pushNamed(context, AppRoutes.selectPlace);
                  // Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
