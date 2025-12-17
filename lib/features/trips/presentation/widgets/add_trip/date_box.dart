import 'package:flutter/material.dart';

class DateBox extends StatelessWidget {
  final String label;
  final String value;
  final bool showError;
  final Function(BuildContext) onTap;

  const DateBox({
    super.key,
    required this.label,
    required this.value,
    required this.showError,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap(context);
      },
      child: Container(
        width: 120,
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: showError ? Colors.redAccent : Colors.grey.shade300,
            width: showError ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
