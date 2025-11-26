import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../../core/constants/app_icons.dart';
import '../../../../../core/theme/app_colors.dart';

class HomePlaceCard extends StatefulWidget {
  final String title;
  final String dateSaved;
  final String location;
  final String distance;
  final String imagePath;
  final VoidCallback onPressed;

  final VoidCallback? onFavorite;
  final VoidCallback? onDelete;

  const HomePlaceCard({
    super.key,
    required this.title,
    required this.dateSaved,
    required this.location,
    required this.distance,
    required this.imagePath,
    required this.onPressed,
    this.onFavorite,
    this.onDelete,
  });

  @override
  _HomePlaceCardState createState() => _HomePlaceCardState();
}

class _HomePlaceCardState extends State<HomePlaceCard> {
  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(widget.title),
      startActionPane: ActionPane(
        motion: const StretchMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (_) => widget.onFavorite?.call(),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            icon: Icons.favorite_outline,
            label: "Save",
            borderRadius: BorderRadius.circular(12),
          ),
        ],
      ),

      endActionPane: ActionPane(
        motion: const StretchMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (_) => widget.onDelete?.call(),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete_outline,
            label: "Delete",
            borderRadius: BorderRadius.circular(12),
          ),
        ],
      ),

      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            spacing: 10,
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  widget.imagePath,
                  height: 70,
                  width: 70,
                  fit: BoxFit.cover,
                ),
              ),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: AppColors.onSurface,
                        ),
                        const SizedBox(width: 4),
                        Text('Saved on ${widget.dateSaved}'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(widget.location),
                  ],
                ),
              ),

              // Action button
              CircleAvatar(
                backgroundColor: AppColors.primary,
                child: IconButton(
                  icon: SvgPicture.asset(
                    AppIcons.navigate,
                    color: AppColors.onPrimary,
                    fit: BoxFit.cover,
                    height: 17,
                    width: 17,
                  ),
                  onPressed: widget.onPressed,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
