import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/app_api.dart';

class ApiServices {
  static Future<void> supabaseSetup() async {
    await dotenv.load(fileName: ".env");

    await Supabase.initialize(
      url: AppApi.supabaseUrl,
      anonKey: AppApi.supabaseAnonKey,
    );
  }

  static Future<void> mapboxSetup() async {
    await dotenv.load(fileName: ".env");

    MapboxOptions.setAccessToken(AppApi.mapboxAccessToken);
  }
}
