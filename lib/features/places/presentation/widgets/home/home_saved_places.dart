import 'package:flutter/material.dart';

import '../../../../../core/services/map/map_service.dart';
import '../../../domain/entities/place_entity.dart';
import '../home_search_bar.dart';
import 'home_category_selector.dart';
import 'home_place_card.dart';

class HomeSavedPlaces extends StatefulWidget {
  final List<PlaceEntity> placeList;

  const HomeSavedPlaces({super.key, required this.placeList});

  @override
  _HomeSavedPlacesState createState() => _HomeSavedPlacesState();
}

class _HomeSavedPlacesState extends State<HomeSavedPlaces> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: .start,
      spacing: 10,
      children: [
        Row(
          mainAxisAlignment: .spaceBetween,
          children: [
            Text(
              "Saved Places",
              style: theme.textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Tooltip(
              message: "Swipe cards left or right on a place to reveal actions",
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  const BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(color: Colors.black),
              child: const Icon(
                Icons.error_outline,
                size: 20,
                color: Colors.black38,
              ),
            ),
          ],
        ),

        const HomeSearchBar(hintText: 'Search saved locations'),

        const HomeCategorySelector(),

        Column(
          spacing: 10,

          children: List.generate(widget.placeList.length, (index) {
            final place = widget.placeList[index];
            final image = place.images.isEmpty ? null : place.images[0];

            final created = place.createdAt;
            final dateStr = "${created.day}-${created.month}-${created.year}";

            return HomePlaceCard(
              title: place.name,
              dateSaved: dateStr,
              location: place.address,
              distance: '8,942 km',
              image: image,
              onCardPressed: () {
                // xử lý khi bấm nút
              },
              onNavigatePressed: () {
                print("Navigate");
                MapService.instance.flyToPlace(place.lng, place.lat);
              },
            );
          }),
        ),
      ],
    );
  }
}
