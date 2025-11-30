import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class MyPrimaryButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String label;

  const MyPrimaryButton({
    super.key,
    required this.onPressed,
    required this.label,
  });

  @override
  _MyPrimaryButtonState createState() => _MyPrimaryButtonState();
}

class _MyPrimaryButtonState extends State<MyPrimaryButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: widget.onPressed,

      child: Row(
        mainAxisAlignment: .center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(
              widget.label,
              style: const TextStyle(
                color: AppColors.onPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
