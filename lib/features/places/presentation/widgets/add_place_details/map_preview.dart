import 'package:flutter/material.dart';

class MapPreview extends StatelessWidget {
  final String? imageUrl;

  const MapPreview({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 220,
        width: double.infinity,
        color: Colors.grey.shade200,
        child: imageUrl == null
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  Positioned.fill(
                    child: Image.network(imageUrl!, fit: BoxFit.cover),
                  ),

                  Container(color: Colors.black.withOpacity(0.2)),
                ],
              ),
      ),
    );
  }
}
