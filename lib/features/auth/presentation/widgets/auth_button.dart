import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class AuthButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String label;

  const AuthButton({super.key, required this.onPressed, required this.label});

  @override
  _AuthButtonState createState() => _AuthButtonState();
}

class _AuthButtonState extends State<AuthButton> {
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
              style: const TextStyle(color: AppColors.onPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
