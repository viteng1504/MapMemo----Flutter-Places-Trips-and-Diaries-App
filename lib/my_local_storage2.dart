import 'features/trips/domain/entities/trip_entity.dart';

class MyLocalStorage2 {
  final List<TripEntity> trips = [
    const TripEntity(
      id: '1',
      name: 'Hà Nội City Tour',
      summary: 'Khám phá phố cổ, văn hóa và ẩm thực Hà Nội.',
      startDate: '2025-01-10',
      days: 3,
      image: null,
    ),
    const TripEntity(
      id: '2',
      name: 'Đà Nẵng - Hội An',
      summary: 'Hành trình biển xanh và phố cổ di sản.',
      startDate: '2025-02-14',
      days: 4,
      image: null,
    ),
    const TripEntity(
      id: '3',
      name: 'TP.HCM – Vũng Tàu',
      summary: 'Một chuyến nghỉ dưỡng ngắn ngày gần biển.',
      startDate: '2025-03-01',
      days: 2,
      image: null,
    ),
    const TripEntity(
      id: '4',
      name: 'Đà Lạt Chill Trip',
      summary: 'Không khí se lạnh, rừng thông và hồ nước yên bình.',
      startDate: '2025-04-05',
      days: 5,
      image: null,
    ),
  ];
}
