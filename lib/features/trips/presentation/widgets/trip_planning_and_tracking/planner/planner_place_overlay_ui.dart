import 'package:flutter/material.dart';

class PlannerPlaceOverlayUi extends StatefulWidget {
  final VoidCallback onClose;

  const PlannerPlaceOverlayUi({super.key, required this.onClose});

  @override
  _PlannerPlaceOverlayUiState createState() => _PlannerPlaceOverlayUiState();
}

class _PlannerPlaceOverlayUiState extends State<PlannerPlaceOverlayUi> {
  @override
  Widget build(BuildContext context) {
    return const SizedBox(width: 100, height: 100);
  }
}
