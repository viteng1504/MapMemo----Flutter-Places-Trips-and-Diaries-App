import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../../core/constants/app_images.dart';
import 'trip_dates_section.dart';

class CoverPhotoSection extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final bool showDateError;
  final Uint8List? coverImageBytes;

  final Function(BuildContext) onPickStart;
  final Function(BuildContext) onPickEnd;
  final VoidCallback onPickCoverPhoto;

  const CoverPhotoSection({
    super.key,
    required this.coverImageBytes,
    required this.startDate,
    required this.endDate,
    required this.showDateError,
    required this.onPickStart,
    required this.onPickEnd,
    required this.onPickCoverPhoto,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: 200,
            child: coverImageBytes == null
                ? Image.asset(AppImages.danang, fit: BoxFit.cover)
                : Image.memory(coverImageBytes!, fit: BoxFit.cover),
          ),

          // Button
          Positioned(
            top: 50,
            left: 30,
            right: 30,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A2540),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: InkWell(
                  onTap: onPickCoverPhoto,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.camera_alt_outlined,
                        color: Colors.white,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Pick a cover photo",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Date card
          Positioned(
            bottom: 0,
            left: 20,
            right: 20,
            child: TripDatesSection(
              startDate: startDate,
              endDate: endDate,
              showError: showDateError,
              onPickStart: onPickStart,
              onPickEnd: onPickEnd,
            ),
          ),
        ],
      ),
    );
  }
}
