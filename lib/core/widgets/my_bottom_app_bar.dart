import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class MyBottomAppBar extends StatefulWidget {
  final int currentTab;
  final Function(int) onNavIconPressed;
  const MyBottomAppBar({
    super.key,
    required this.currentTab,
    required this.onNavIconPressed,
  });

  @override
  _MyBottomAppBarState createState() => _MyBottomAppBarState();
}

class _MyBottomAppBarState extends State<MyBottomAppBar> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 60,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 5,
                spreadRadius: 1,
                offset: const Offset(0, 0),
              ),
            ],
          ),
        ),

        BottomAppBar(
          height: 60,
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
          color: AppColors.background2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navIcon(Icons.trip_origin_outlined, 1, "Trips"),
              _navIcon(Icons.book, 2, "Diaries"),
              const SizedBox(width: 50),
              _navIcon(Icons.notifications, 3, "Notifications"),
              _navIcon(Icons.account_box, 4, "Profile"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _navIcon(IconData icon, int index, String label) {
    final isSelected = widget.currentTab == index;

    return Expanded(
      child: ClipRRect(
        child: Material(
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              widget.onNavIconPressed(index);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.onSurfaceGray2,
                  ),

                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.onSurfaceGray2,
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
}
