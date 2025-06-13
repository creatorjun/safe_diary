import 'package:crystal_navigation_bar/crystal_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';
import '../controllers/login_controller.dart';
import '../routes/app_pages.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
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

    final List<Widget> screens = [
      const CalendarView(),
      const WeatherView(),
      const LuckView(),
    ];

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Obx(() {
          final displayTitle =
              '${loginController.user.nickname ?? '사용자'}님 - ${controller.currentTitle}';
          return Text(
            displayTitle,
            style: textStyleLarge,
            overflow: TextOverflow.ellipsis,
          );
        }),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            color: Colors.transparent,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            tooltip: '더보기',
            onSelected: (String value) {
              if (value == 'profile') {
                Get.toNamed(Routes.profileAuth);
              } else if (value == 'logout') {
                loginController.logout();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person_outline),
                    horizontalSpaceSmall,
                    Text('개인정보', style: textStyleSmall),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    horizontalSpaceSmall,
                    Text('로그아웃', style: textStyleSmall),
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
            tooltip: '일정 추가',
            backgroundColor: colorScheme.secondary,
            foregroundColor: colorScheme.onSecondary,
            child: const Icon(Icons.add),
          );
        } else {
          return const SizedBox.shrink();
        }
      }),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}