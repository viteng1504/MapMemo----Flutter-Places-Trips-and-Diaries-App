import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/map/map_service.dart';
import 'trip_overlay_state.dart';

class TripOverlayCubit extends Cubit<TripOverlayState> {
  TripOverlayCubit() : super(TripOverlayState(name: "name"));

  void getPlaces() {}

  void zoomOutMap() {
    MapService.instance.zoomOut();
  }
}
