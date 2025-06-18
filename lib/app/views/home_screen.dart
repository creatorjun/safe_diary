// lib/app/views/home_screen.dart

import 'package:crystal_navigation_bar/crystal_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';
import '../controllers/login_controller.dart';
import '../routes/app_pages.dart';
import '../theme/app_theme.dart';
import '../utils/app_strings.dart';
import '../views/widgets/shared_background.dart';
import './calendar_view.dart';
import './luck_view.dart';
import './weather_view.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginController loginController = Get.find<LoginController>();
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final AppTextStyles textStyles = theme.extension<AppTextStyles>()!;
    final AppSpacing spacing = theme.extension<AppSpacing>()!;

    final List<Widget> screens = [
      const CalendarView(),
      const WeatherView(),
      const LuckView(),
    ];

    return SharedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        appBar: AppBar(
          title: Obx(() {
            final displayTitle = AppStrings.homeTitle(
              controller.currentTitle,
            );
            return Text(
              displayTitle,
              style: textStyles.titleMedium,
              overflow: TextOverflow.ellipsis,
            );
          }),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              tooltip: AppStrings.more,
              onSelected: (String value) {
                if (value == 'profile') {
                  Get.toNamed(Routes.profileAuth);
                } else if (value == 'logout') {
                  loginController.logout();
                }
              },
              itemBuilder:
                  (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'profile',
                  child: Row(
                    children: [
                      const Icon(Icons.person_outline),
                      SizedBox(width: spacing.small),
                      Text(
                        AppStrings.profile,
                        style: textStyles.bodyMedium,
                      ),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      const Icon(Icons.logout),
                      SizedBox(width: spacing.small),
                      Text(AppStrings.logout, style: textStyles.bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: Obx(
              () => IndexedStack(
            index: controller.selectedIndex.value,
            children: screens,
          ),
        ),
        bottomNavigationBar: Obx(
              () => CrystalNavigationBar(
            currentIndex: controller.selectedIndex.value,
            onTap: (index) {
              controller.changeTabIndex(index);
            },
            unselectedItemColor: colorScheme.onSurfaceVariant.withAlpha(150),
            backgroundColor: theme.cardColor.withAlpha(200),
            borderRadius: 24,
            enableFloatingNavBar: true,
            items: [
              CrystalNavigationBarItem(
                icon: Icons.calendar_month_outlined,
                selectedColor: colorScheme.primary,
              ),
              CrystalNavigationBarItem(
                icon: Icons.wb_sunny_outlined,
                selectedColor: colorScheme.primary,
              ),
              CrystalNavigationBarItem(
                icon: Icons.explore_outlined,
                selectedColor: colorScheme.primary,
              ),
            ],
          ),
        ),
        floatingActionButton: Obx(() {
          if (controller.selectedIndex.value == 0) {
            return FloatingActionButton.small(
              onPressed: () {
                controller.showAddEventDialog();
              },
              tooltip: AppStrings.addEvent,
              backgroundColor: colorScheme.secondary,
              foregroundColor: colorScheme.onSecondary,
              child: const Icon(Icons.add),
            );
          } else {
            return const SizedBox.shrink();
          }
        }),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}