import 'package:flutter/material.dart';

import 'core/constants/app_routes.dart';
import 'core/services/api_services.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/places/presentation/screens/place_details_screen.dart';
import 'features/places/presentation/screens/select_place_on_map_screen.dart';
import 'features/trips/presentation/screens/add_trip_screen.dart';
import 'features/trips/presentation/screens/trip_destination_search_screen.dart';
import 'features/trips/presentation/screens/trip_itinerary_screen.dart';
import 'features/trips/presentation/screens/trip_personalize_screen.dart';
import 'features/trips/presentation/screens/trip_planning_and_tracking_screen.dart';
import 'map_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ApiServices.mapboxSetup();
  await ApiServices.supabaseSetup();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MapMemo',
      theme: AppTheme.mainTheme,
      home: const MapShell(),

      routes: {
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.register: (context) => const RegisterScreen(),
        AppRoutes.home: (context) => const MapShell(),
        AppRoutes.selectPlace: (context) => const SelectPlaceOnMapScreen(),
        AppRoutes.placeDetails: (context) => const PlaceDetailsScreen(),
        AppRoutes.addTrip: (context) => const AddTripScreen(),
        AppRoutes.tripPersonalize: (context) => const TripPersonalizeScreen(),
        AppRoutes.tripItinerary: (context) => const TripItineraryScreen(),
        AppRoutes.tripDestinationSearch: (context) =>
            const TripDestinationSearchScreen(),
        AppRoutes.tripPlanningAndTracking: (context) =>
            const TripPlanningAndTrackingScreen(),
      },
    );
  }
}
