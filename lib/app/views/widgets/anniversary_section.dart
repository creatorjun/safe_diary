// lib/app/views/widgets/anniversary_section.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:safe_diary/app/controllers/profile_controller.dart';
import 'package:safe_diary/app/theme/app_theme.dart';

class AnniversarySection extends GetView<ProfileController> {
  const AnniversarySection({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppTextStyles textStyles = theme.extension<AppTextStyles>()!;
    final AppSpacing spacing = theme.extension<AppSpacing>()!;
    final ColorScheme colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("기념일 관리", style: textStyles.titleLarge),
            IconButton(
              onPressed: controller.fetchAnniversaries,
              icon: const Icon(Icons.refresh),
              tooltip: "새로고침",
            ),
          ],
        ),
        SizedBox(height: spacing.small),
        Obx(() {
          if (controller.isAnniversaryLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.anniversaries.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24.0),
                child: Text("등록된 기념일이 없습니다."),
              ),
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.anniversaries.length,
            itemBuilder: (context, index) {
              final anniversary = controller.anniversaries[index];
              final now = DateTime.now();
              final anniversaryDate = anniversary.dateTime;
              final difference = anniversaryDate
                  .difference(DateTime(now.year, now.month, now.day))
                  .inDays;
              String dDayText;

              if (difference == 0) {
                dDayText = 'D-DAY';
              } else if (difference < 0) {
                dDayText = 'D+${-difference}';
              } else {
                dDayText = 'D-$difference';
              }

              return Card(
                child: ListTile(
                  leading: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(dDayText,
                          style: textStyles.bodyLarge
                              .copyWith(color: colorScheme.primary)),
                    ],
                  ),
                  title: Text(anniversary.title, style: textStyles.bodyLarge),
                  subtitle: Text(
                    DateFormat('yyyy. MM. dd. (E)', 'ko_KR')
                        .format(anniversaryDate),
                    style: textStyles.bodyMedium
                        .copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit,
                            color: colorScheme.secondary, size: 20),
                        tooltip: "수정",
                        onPressed: () =>
                            controller.showEditAnniversaryDialog(anniversary),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline,
                            color: colorScheme.error, size: 20),
                        tooltip: "삭제",
                        onPressed: () => controller
                            .confirmDeleteAnniversary(anniversary.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ],
    );
  }
}