import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/luck_controller.dart';
import '../models/luck_models.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';

class LuckView extends GetView<LuckController> {
  const LuckView({super.key});

  void _showZodiacSelectionBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.only(top: 12.0, bottom: 8.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.1),
              blurRadius: 8.0,
              spreadRadius: 2.0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Text(
                "띠 선택",
                style: textStyleMedium.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(height: 1),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight:
                MediaQuery.of(context).size.height * 0.4, // 화면 높이의 40%
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: controller.availableZodiacsForDisplay.length,
                itemBuilder: (BuildContext context, int index) {
                  final String zodiacDisplayName =
                  controller.availableZodiacsForDisplay[index];
                  bool isSelected =
                      zodiacDisplayName ==
                          controller.currentSelectedZodiacDisplayName;
                  return ListTile(
                    title: Text(
                      zodiacDisplayName,
                      style: textStyleSmall.copyWith(
                        fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(
                      Icons.check_circle_outline_rounded,
                      color: Theme.of(context).colorScheme.primary,
                      size: 22,
                    )
                        : null,
                    onTap: () {
                      controller.changeZodiacByDisplayName(zodiacDisplayName);
                    },
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 4.0,
                    ),
                    dense: true,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value && controller.zodiacLuck.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value.isNotEmpty &&
            controller.zodiacLuck.value == null) {
          return _buildErrorView(context);
        }

        final luckData = controller.zodiacLuck.value;
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
            verticalSpaceSmall,
            Text(
              controller.errorMessage.value,
              style: textStyleSmall.copyWith(color: colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            verticalSpaceMedium,
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text("다시 시도"),
              onPressed: () {
                controller.fetchTodaysLuck(
                  controller.selectedZodiacApiName.value,
                );
              },
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
            onPressed: () {
              controller.fetchTodaysLuck(
                controller.selectedZodiacApiName.value,
              );
            },
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
      onRefresh: () => controller.fetchTodaysLuck(
        controller.selectedZodiacApiName.value,
      ),
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
                      ).textTheme.titleLarge?.color?.withOpacity(0.6),
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
                onPressed: () => controller.fetchTodaysLuck(
                  controller.selectedZodiacApiName.value,
                ),
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
                    Icons.auto_awesome,
                  ),
                  _buildLuckCategoryCard(
                    context,
                    "💰 재물운",
                    luckData.financialLuck,
                    Icons.attach_money,
                  ),
                  _buildLuckCategoryCard(
                    context,
                    "💕 애정운",
                    luckData.loveLuck,
                    Icons.favorite_border,
                  ),
                  _buildLuckCategoryCard(
                    context,
                    "💪 건강운",
                    luckData.healthLuck,
                    Icons.healing_outlined,
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
                    Icons.lightbulb_outline,
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
      BuildContext context, String title, String? content, IconData icon) {
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
            Row(
              children: [
                Icon(
                  icon,
                  size: 20.0,
                  color: colorScheme.primary,
                ),
                horizontalSpaceSmall,
                Text(
                  title,
                  style: textStyleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ],
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