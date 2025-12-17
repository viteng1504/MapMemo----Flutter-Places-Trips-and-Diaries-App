import 'dart:typed_data';

import 'package:flutter/material.dart';

class PlaceImagesGrid extends StatelessWidget {
  final List<Uint8List> images;

  const PlaceImagesGrid({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: images.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
      ),
      itemBuilder: (_, i) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.memory(images[i], fit: BoxFit.cover),
        );
      },
    );
  }
}
