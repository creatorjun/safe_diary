// lib/app/views/home_screen.dart

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:crystal_navigation_bar/crystal_navigation_bar.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../controllers/home_controller.dart';
import '../controllers/login_controller.dart';
import '../routes/app_pages.dart';
import './calendar_view.dart';
import './weather_view.dart';
import './luck_view.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginController loginController = Get.find<LoginController>();
    final ThemeData theme = Theme.of(context);

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
            // gradient: LinearGradient(
            //   colors: [
            //     Colors.redAccent,
            //     Colors.purpleAccent,
            //     Colors.greenAccent,
            //   ],
            //   begin: Alignment.topLeft,
            //   end: Alignment.bottomRight,
            // ),
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
            itemBuilder:
                (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'profile',
                    child: Row(
                      children: [
                        const Icon(Icons.person_outline, color: Colors.black87),
                        horizontalSpaceSmall,
                        const Text('개인정보', style: textStyleSmall),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: [
                        const Icon(Icons.logout, color: Colors.black87),
                        horizontalSpaceSmall,
                        const Text('로그아웃', style: textStyleSmall),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: Obx(
        // SafeArea 래핑을 제거했습니다.
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
          unselectedItemColor: Colors.grey.shade400,
          backgroundColor: theme.cardColor.withAlpha(15),
          borderRadius: 24,
          enableFloatingNavBar: true,
          items: [
            CrystalNavigationBarItem(
              icon: Icons.calendar_month_outlined,
              selectedColor: theme.colorScheme.primary,
            ),
            CrystalNavigationBarItem(
              icon: Icons.wb_sunny_outlined,
              selectedColor: theme.colorScheme.primary,
            ),
            CrystalNavigationBarItem(
              icon: Icons.explore_outlined,
              selectedColor: theme.colorScheme.primary,
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
            backgroundColor: Colors.purpleAccent,
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
