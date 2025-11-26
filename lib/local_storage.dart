import 'package:uuid/uuid.dart';

import 'features/places/domain/entities/place_entity.dart';

class LocalStorage {
  static List<PlaceEntity> places = [
    PlaceEntity(
      id: const Uuid().v4(),
      name: "Hồ Gươm",
      description: "Biểu tượng nổi tiếng của Hà Nội",
      lat: 21.028511,
      lng: 105.848198,
      address: "Hoàn Kiếm, Hà Nội",
      city: "Hà Nội",
      country: "Việt Nam",
      createdAt: DateTime.now(),
    ),
    PlaceEntity(
      id: const Uuid().v4(),
      name: "Chợ Bến Thành",
      description: "Khu chợ truyền thống lâu đời",
      lat: 10.772,
      lng: 106.698,
      address: "Quận 1, TP.HCM",
      city: "TP.HCM",
      country: "Việt Nam",
      createdAt: DateTime.now(),
    ),
    PlaceEntity(
      id: const Uuid().v4(),
      name: "Cầu Rồng",
      description: "Cây cầu nổi tiếng ở Đà Nẵng",
      lat: 16.0615,
      lng: 108.227,
      address: "Sông Hàn, Đà Nẵng",
      city: "Đà Nẵng",
      country: "Việt Nam",
      createdAt: DateTime.now(),
    ),
  ];
}
