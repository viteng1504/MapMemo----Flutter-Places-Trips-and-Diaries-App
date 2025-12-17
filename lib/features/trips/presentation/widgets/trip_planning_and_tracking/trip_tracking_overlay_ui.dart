import 'package:flutter/material.dart';

class TripTrackingOverlayUi extends StatefulWidget {
  final VoidCallback onPlaceTap;
  const TripTrackingOverlayUi({super.key, required this.onPlaceTap});

  @override
  _TripTrackingOverlayUiState createState() => _TripTrackingOverlayUiState();
}

class _TripTrackingOverlayUiState extends State<TripTrackingOverlayUi> {
  @override
  Widget build(BuildContext context) {
    return const SizedBox(width: 100, height: 100);
  }
}
