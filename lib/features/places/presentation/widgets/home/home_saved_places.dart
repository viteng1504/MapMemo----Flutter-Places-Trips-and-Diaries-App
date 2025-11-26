import 'package:flutter/material.dart';

import '../../../../../core/constants/app_images.dart';
import '../home_search_bar.dart';
import 'home_category_selector.dart';
import 'home_place_card.dart';

class HomeSavedPlaces extends StatefulWidget {
  const HomeSavedPlaces({super.key});

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
          children: List.generate(5, (index) {
            return HomePlaceCard(
              title: 'Eiffel Tower',
              dateSaved: 'July 12, 2024',
              location: 'Paris, France',
              distance: '8,942 km',
              imagePath: AppImages.danang,
              onPressed: () {
                // xử lý khi bấm nút
              },
            );
          }),
        ),
      ],
    );
  }
}
