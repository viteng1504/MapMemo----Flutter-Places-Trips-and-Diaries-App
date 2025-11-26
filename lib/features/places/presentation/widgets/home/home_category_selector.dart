import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

class HomeCategorySelector extends StatefulWidget {
  const HomeCategorySelector({super.key});

  @override
  _HomeCategorySelectorState createState() => _HomeCategorySelectorState();
}

class _HomeCategorySelectorState extends State<HomeCategorySelector> {
  int _currentCategoryIndex = 0;

  void _onCategoryPressed(int selectIndex) {
    setState(() {
      debugPrint("oncategorypressed");
      _currentCategoryIndex = selectIndex;
    });
  }

  List<String> category = ["All", "Favorites"];

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 10,
      children: List.generate(category.length, (index) {
        return _categorySelector(
          index: index,
          currentCategoryIndex: _currentCategoryIndex,
          text: category[index],
          context: context,
          onPressed: _onCategoryPressed,
        );
      }).toList(),
    );
  }

  Widget _categorySelector({
    required int index,
    required int currentCategoryIndex,
    required String text,
    required BuildContext context,
    required Function(int) onPressed,
  }) {
    final theme = Theme.of(context);
    final isSelected = index == currentCategoryIndex;

    return TextButton(
      onPressed: () => onPressed(index),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.all(12),
        minimumSize: const Size(60, 0),
        backgroundColor: isSelected
            ? AppColors.primary
            : AppColors.onSurfaceGray3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Text(
        text,
        style: theme.textTheme.bodyMedium!.copyWith(
          color: isSelected ? AppColors.onPrimary : AppColors.onSurface,
        ),
      ),
    );
  }
}
