import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/luck_controller.dart';
import '../models/luck_models.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class LuckView extends GetView<LuckController> {
  const LuckView({super.key});

  void _showZodiacSelectionBottomSheet(BuildContext context) {
    int selectedIndex = controller.availableZodiacsForDisplay
        .indexOf(controller.currentSelectedZodiacDisplayName);

    final FixedExtentScrollController scrollController =
    FixedExtentScrollController(initialItem: selectedIndex);

    Get.bottomSheet(
      Container(
        height: 320,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                "띠 선택",
                style: textStyleMedium.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: CupertinoPicker(
                scrollController: scrollController,
                itemExtent: 40,
                onSelectedItemChanged: (index) {
                  selectedIndex = index;
                },
                children: controller.availableZodiacsForDisplay
                    .map((zodiac) => Center(
                  child: Text(
                    zodiac,
                    style: textStyleMedium.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ))
                    .toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  final selectedZodiac =
                  controller.availableZodiacsForDisplay[selectedIndex];
                  controller.changeZodiacByDisplayName(selectedZodiac);
                },
                child: const Text("선택"),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value &&
            controller.selectedZodiacLuck.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!controller.isLoading.value &&
            controller.selectedZodiacLuck.value == null) {
          return _buildErrorView(context);
        }

        final luckData = controller.selectedZodiacLuck.value;
        if (luckData == null) {
          return _buildEmptyView(context);
        }

        return _buildLuckContentView(context, luckData);
      }),
    );
  }

  Widget _buildErrorView(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: colorScheme.error, size: 48),
            verticalSpaceMedium,
            Text(
              "운세 정보를 불러오는 데 실패했습니다.",
              style: textStyleMedium.copyWith(color: colorScheme.error),
              textAlign: TextAlign.center,
            ),
            verticalSpaceMedium,
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text("다시 시도"),
              onPressed: () =>
                  controller.fetchTodaysLuck(controller.selectedZodiacApiName.value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sentiment_neutral_outlined,
            color: colorScheme.onSurfaceVariant,
            size: 48,
          ),
          verticalSpaceMedium,
          const Text("오늘의 운세 정보가 아직 없습니다.", style: textStyleMedium),
          verticalSpaceSmall,
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text("새로고침"),
            onPressed: () =>
                controller.fetchTodaysLuck(controller.selectedZodiacApiName.value),
          ),
        ],
      ),
    );
  }

  Widget _buildLuckContentView(BuildContext context, ZodiacLuckData luckData) {
    final colorScheme = Theme.of(context).colorScheme;
    String requestDateFormatted = luckData.requestDate;
    try {
      final date = DateTime.parse(luckData.requestDate);
      requestDateFormatted = DateFormat('yyyy년 MM월 dd일', 'ko_KR').format(date);
    } catch (e) {
      // 파싱 실패 시 원본 문자열 사용
    }

    return RefreshIndicator(
      onRefresh: () =>
          controller.fetchTodaysLuck(controller.selectedZodiacApiName.value),
      child: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            title: InkWell(
              onTap: () => _showZodiacSelectionBottomSheet(context),
              borderRadius: BorderRadius.circular(8.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Obx(
                          () => Text(
                        '${controller.currentSelectedZodiacDisplayName} 띠',
                        style: textStyleLarge,
                      ),
                    ),
                    horizontalSpaceSmall,
                    Icon(
                      Icons.arrow_drop_down_circle_outlined,
                      size: 20,
                      color: Theme.of(
                        context,
                      ).textTheme.titleLarge?.color?.withAlpha(153),
                    ),
                  ],
                ),
              ),
            ),
            centerTitle: true,
            floating: true,
            snap: true,
            elevation: 1,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: "새로고침",
                onPressed: () =>
                    controller.fetchTodaysLuck(controller.selectedZodiacApiName.value),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      requestDateFormatted,
                      style: textStyleSmall.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  verticalSpaceMedium,
                  _buildLuckCategoryCard(
                    context,
                    "✨ 총운",
                    luckData.overallLuck,
                  ),
                  _buildLuckCategoryCard(
                    context,
                    "💰 재물운",
                    luckData.financialLuck,
                  ),
                  _buildLuckCategoryCard(
                    context,
                    "💕 애정운",
                    luckData.loveLuck,
                  ),
                  _buildLuckCategoryCard(
                    context,
                    "💪 건강운",
                    luckData.healthLuck,
                  ),
                  if (luckData.luckyNumber != null ||
                      luckData.luckyColor != null) ...[
                    verticalSpaceMedium,
                    Card(
                      elevation: 1.5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              "행운의 요소",
                              style: textStyleMedium.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                            verticalSpaceSmall,
                            if (luckData.luckyNumber != null)
                              _buildLuckDetailRow(
                                "🍀 행운의 숫자:",
                                luckData.luckyNumber.toString(),
                              ),
                            if (luckData.luckyColor != null)
                              _buildLuckDetailRow(
                                "🎨 행운의 색상:",
                                luckData.luckyColor!,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  _buildLuckCategoryCard(
                    context,
                    "💡 조언",
                    luckData.advice,
                  ),
                  const SizedBox(height: 108),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLuckCategoryCard(
      BuildContext context,
      String title,
      String? content,
      ) {
    if (content == null || content.isEmpty) {
      return const SizedBox.shrink();
    }
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: textStyleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            verticalSpaceSmall,
            Text(
              content,
              style: textStyleSmall.copyWith(height: 1.5),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLuckDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textStyleSmall.copyWith(fontWeight: FontWeight.w500),
          ),
          horizontalSpaceSmall,
          Expanded(child: Text(value, style: textStyleSmall)),
        ],
      ),
    );
  }
}