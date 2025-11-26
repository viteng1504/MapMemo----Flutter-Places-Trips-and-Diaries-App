import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubits/home_overlay_cubit.dart';
import '../cubits/home_overlay_state.dart';
import '../widgets/home/home_saved_places.dart';
import '../widgets/home/home_statistics.dart';

class HomeOverlayUI extends StatefulWidget {
  const HomeOverlayUI({super.key});

  @override
  State<HomeOverlayUI> createState() => _HomeOverlayUIState();
}

class _HomeOverlayUIState extends State<HomeOverlayUI> {
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeOverlayCubit(),
      child: BlocConsumer<HomeOverlayCubit, HomeOverlayState>(
        listener: (context, state) {},
        builder: (context, state) {
          return Stack(
            children: [
              DraggableScrollableSheet(
                controller: _sheetController,
                initialChildSize: 0.2,
                minChildSize: 0.2,
                maxChildSize: 0.75,
                snap: true,
                snapSizes: const [0.2, 0.5, 0.75],
                snapAnimationDuration: const Duration(milliseconds: 250),
                builder: (context, controller) {
                  return Container(
                    decoration: const BoxDecoration(
                      color: AppColors.background2,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      // boxShadow: [
                      //   BoxShadow(color: AppColors.shadow, blurRadius: 1),
                      // ],
                    ),
                    child: ListView(
                      controller: controller,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 24,
                      ),
                      children: [
                        // drag handle
                        Center(
                          child: Container(
                            width: 40,
                            height: 5,
                            decoration: BoxDecoration(
                              color: AppColors.onSurfaceGray2,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        _buildProfileHeader(context),
                        const SizedBox(height: 20),

                        const HomeStatistics(),
                        const SizedBox(height: 20),

                        const HomeSavedPlaces(),
                        const SizedBox(height: 200),
                      ],
                    ),
                  );
                },
              ),

              // Navigate to current position
              Positioned(
                right: 10,
                top: 150, // <<–– DI CHUYỂN KHI KÉO
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(14),
                    backgroundColor: AppColors.primary,
                  ),
                  onPressed: () {
                    context.read<HomeOverlayCubit>().navigateToUserPos();
                  },
                  child: const Icon(Icons.my_location, color: Colors.white),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        SvgPicture.asset(
          AppIcons.user,
          width: 56,
          height: 56,
          color: AppColors.primary,
        ),
        const SizedBox(width: 16),
        Column(
          spacing: 2,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Việt Nguyễn Thanh 🇻🇳",
              style: theme.textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Row(
              spacing: 5,
              children: [
                Text("1 Countries"),
                SizedBox(
                  height: 20,
                  child: VerticalDivider(
                    width: 20,
                    thickness: 1,
                    color: AppColors.onSurfaceGray2,
                  ),
                ),
                Text("1 Following"),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
