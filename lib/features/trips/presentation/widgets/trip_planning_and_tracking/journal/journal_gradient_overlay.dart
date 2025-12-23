import 'package:flutter/material.dart';

class JournalGradientOverlay extends StatelessWidget {
  const JournalGradientOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return const Positioned.fill(
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              // Tinh chỉnh lại màu gradient cho mượt hơn
              colors: [Colors.black26, Colors.transparent, Colors.black45],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        ),
      ),
    );
  }
}
