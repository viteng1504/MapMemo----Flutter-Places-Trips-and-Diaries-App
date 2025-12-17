import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../../core/constants/app_icons.dart';
import '../../../../../core/constants/app_images.dart';
import '../../../../../core/theme/app_colors.dart';

class HomePlaceCard extends StatelessWidget {
  final String title;
  final String dateSaved;
  final String location;
  final String distance;
  final Uint8List? image;
  final VoidCallback onCardPressed;
  final VoidCallback onNavigatePressed;
  final VoidCallback? onFavorite;
  final VoidCallback? onDelete;

  const HomePlaceCard({
    super.key,
    required this.title,
    required this.dateSaved,
    required this.location,
    required this.distance,
    required this.image,
    this.onFavorite,
    this.onDelete,
    required this.onCardPressed,
    required this.onNavigatePressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Slidable(
      key: ValueKey(title),

      // startActionPane: ActionPane(
      //   motion: const StretchMotion(),
      //   extentRatio: 0.22,
      //   children: [
      //     _actionButton(
      //       icon: Icons.favorite_border,
      //       label: "Save",
      //       color: Colors.green.shade600,
      //       onTap: onFavorite,
      //     ),
      //   ],
      // ),
      endActionPane: ActionPane(
        motion: const StretchMotion(),
        extentRatio: 0.5,
        children: [
          const SizedBox(width: 5),

          _actionButton(
            icon: Icons.delete_outline,
            label: "Delete",
            color: Colors.red.shade600,
            onTap: onDelete,
          ),

          const SizedBox(width: 5),

          _actionButton(
            icon: Icons.favorite_border,
            label: "Save",
            color: Colors.green.shade600,
            onTap: onFavorite,
          ),
        ],
      ),

      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              blurRadius: 8,
              color: Colors.black.withOpacity(0.4),
              offset: const Offset(0, 2),
            ),
          ],
        ),

        // padding: const EdgeInsets.all(12),
        child: Material(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onCardPressed,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  // Ảnh
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: image == null
                        ? Image.asset(
                            AppImages.danang,
                            height: 78,
                            width: 78,
                            fit: BoxFit.cover,
                          )
                        : Image.memory(
                            image!,
                            height: 78,
                            width: 78,
                            fit: BoxFit.cover,
                          ),
                  ),

                  const SizedBox(width: 12),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),

                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 15,
                              color: colors.outline,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "Saved on $dateSaved",
                              style: TextStyle(
                                color: colors.outline,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: colors.outline,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                location,
                                style: TextStyle(
                                  color: colors.onSurfaceVariant,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Navigate button
                  InkWell(
                    onTap: onNavigatePressed,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: SvgPicture.asset(
                        AppIcons.navigate,
                        height: 18,
                        width: 18,
                        color: AppColors.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return SlidableAction(
      onPressed: (_) => onTap?.call(),
      backgroundColor: color,
      foregroundColor: Colors.white,
      borderRadius: BorderRadius.circular(10),
      icon: icon,
      label: label,
    );
  }
}
