import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_colors.dart';

class PlannerSearchDestinationOverlayUi extends StatelessWidget {
  const PlannerSearchDestinationOverlayUi({
    super.key,
    this.onSearchTap,
    this.onGetSuggestions,
    this.searchHint = 'Search for a location',
  });

  final VoidCallback? onSearchTap;
  final VoidCallback? onGetSuggestions;
  final String searchHint;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.fromLTRB(16, 10, 16, 16 + bottomInset),
          decoration: const BoxDecoration(
            color: Color(0xFFE9EAEC),
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
            boxShadow: [
              BoxShadow(
                blurRadius: 20,
                color: Colors.black26,
                offset: Offset(0, -6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Grab handle
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 14),

              // Search box
              InkWell(
                onTap: onSearchTap,
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 12,
                        color: Colors.black.withOpacity(0.12),
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, size: 24, color: Colors.black87),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          searchHint,
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.55),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Divider + "or"
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      thickness: 1,
                      color: Colors.black.withOpacity(0.12),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'or',
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.45),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      thickness: 1,
                      color: Colors.black.withOpacity(0.12),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: onGetSuggestions,
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text(
                    'Get suggestions',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary, // đỏ như hình
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
