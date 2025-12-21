import 'package:flutter/material.dart';

class TripJournalOverlayUi extends StatefulWidget {
  final VoidCallback onPlaceTap;
  const TripJournalOverlayUi({super.key, required this.onPlaceTap});

  @override
  _TripJournalOverlayUiState createState() => _TripJournalOverlayUiState();
}

class _TripJournalOverlayUiState extends State<TripJournalOverlayUi> {
  @override
  Widget build(BuildContext context) {
    return const SizedBox(width: 100, height: 100);
  }
}
