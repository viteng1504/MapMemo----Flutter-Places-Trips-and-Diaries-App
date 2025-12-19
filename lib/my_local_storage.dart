import 'package:uuid/uuid.dart';

import 'features/places/domain/entities/place_entity.dart';
import 'features/trips/data/models/trip_model.dart';

class MyLocalStorage {
  static List<PlaceEntity> places = [
    PlaceEntity(
      id: const Uuid().v4(),
      name: "Hồ Gươm",
      description: "Biểu tượng nổi tiếng của Hà Nội",
      lat: 21.028511,
      lng: 105.848198,
      address: "Hoàn Kiếm, Hà Nội",
      // city: "Hà Nội",
      // country: "Việt Nam",
      images: [],
      createdAt: DateTime.now(),
    ),
    PlaceEntity(
      id: const Uuid().v4(),
      name: "Chợ Bến Thành",
      description: "Khu chợ truyền thống lâu đời",
      lat: 10.772,
      lng: 106.698,
      address: "Quận 1, TP.HCM",
      // city: "TP.HCM",
      // country: "Việt Nam",
      images: [],

      createdAt: DateTime.now(),
    ),
    PlaceEntity(
      id: const Uuid().v4(),
      name: "Cầu Rồng",
      description: "Cây cầu nổi tiếng ở Đà Nẵng",
      lat: 16.0615,
      lng: 108.227,
      address: "Sông Hàn, Đà Nẵng",
      images: [],
      // city: "Đà Nẵng",
      // country: "Việt Nam",
      createdAt: DateTime.now(),
    ),
  ];

  static List<TripModel> trips = [];

  static void printPlacesData() {
    for (int i = 0; i < MyLocalStorage.places.length; i++) {
      final place = MyLocalStorage.places[i];

      print("===== Place ${i + 1} =====");
      print("ID: ${place.id}");
      print("Name: ${place.name}");
      print("Description: ${place.description}");
      print("Address: ${place.address}");
      print("Lat: ${place.lat}");
      print("Lng: ${place.lng}");
      print("Created: ${place.createdAt}");

      // In ảnh theo format Ảnh 1, Ảnh 2
      if (place.images.isEmpty) {
        print("Images: Không có ảnh");
      } else {
        for (int j = 0; j < place.images.length; j++) {
          print("Image ${j + 1}: (Uint8List image)");
        }
      }

      print("===========================\n");
    }
  }
}
