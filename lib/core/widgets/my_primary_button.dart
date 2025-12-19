import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class MyPrimaryButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String label;
  final bool? isLoading;

  const MyPrimaryButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.isLoading,
  });

  @override
  _MyPrimaryButtonState createState() => _MyPrimaryButtonState();
}

class _MyPrimaryButtonState extends State<MyPrimaryButton> {
  static const double _buttonHeight = 48;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _buttonHeight,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: widget.isLoading == true ? null : widget.onPressed,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Opacity(
              opacity: widget.isLoading == true ? 0 : 1,
              child: Text(
                widget.label,
                style: const TextStyle(
                  color: AppColors.onPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            // Loading
            if (widget.isLoading == true)
              const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator.adaptive(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
