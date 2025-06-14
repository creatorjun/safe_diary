// lib/app/views/luck_view.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/luck_controller.dart';
import '../models/luck_models.dart';
import '../theme/app_theme.dart';
import '../utils/app_strings.dart';

class LuckView extends GetView<LuckController> {
  const LuckView({super.key});

  void _showZodiacSelectionBottomSheet(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppTextStyles textStyles = theme.extension<AppTextStyles>()!;
    int selectedIndex = controller.availableZodiacsForDisplay
        .indexOf(controller.currentSelectedZodiacDisplayName);

    final FixedExtentScrollController scrollController =
    FixedExtentScrollController(initialItem: selectedIndex);

    Get.bottomSheet(
      Container(
        height: 320,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(AppStrings.selectZodiac, style: textStyles.bodyLarge),
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
                    style: textStyles.bodyLarge.copyWith(
                      color: theme.colorScheme.onSurface,
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
    return Obx(() {
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
    });
  }

  Widget _buildErrorView(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final AppTextStyles textStyles = theme.extension<AppTextStyles>()!;
    final AppSpacing spacing = theme.extension<AppSpacing>()!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline,
                color: colorScheme.error.withAlpha(179), size: 48),
            SizedBox(height: spacing.medium),
            Text(
              AppStrings.luckInfoError,
              style: textStyles.bodyLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: spacing.medium),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text(AppStrings.tryAgain),
              onPressed: () => controller
                  .fetchTodaysLuck(controller.selectedZodiacApiName.value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final AppTextStyles textStyles = theme.extension<AppTextStyles>()!;
    final AppSpacing spacing = theme.extension<AppSpacing>()!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sentiment_neutral_outlined,
            color: colorScheme.onSurfaceVariant,
            size: 48,
          ),
          SizedBox(height: spacing.medium),
          Text(AppStrings.noLuckInfo, style: textStyles.bodyLarge),
          SizedBox(height: spacing.small),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text("새로고침"),
            onPressed: () => controller
                .fetchTodaysLuck(controller.selectedZodiacApiName.value),
          ),
        ],
      ),
    );
  }

  Widget _buildLuckContentView(BuildContext context, ZodiacLuckData luckData) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final AppTextStyles textStyles = theme.extension<AppTextStyles>()!;
    final AppSpacing spacing = theme.extension<AppSpacing>()!;
    String requestDateFormatted = luckData.requestDate;
    try {
      final date = DateTime.parse(luckData.requestDate);
      requestDateFormatted = DateFormat('yyyy년 MM월 dd일', 'ko_KR').format(date);
    } catch (e) {
      //
    }

    final List<Widget> luckCards = [
      _buildLuckCategoryCard(context, AppStrings.overallLuck, luckData.overallLuck),
      _buildLuckCategoryCard(
          context, AppStrings.financialLuck, luckData.financialLuck),
      _buildLuckCategoryCard(context, AppStrings.loveLuck, luckData.loveLuck),
      _buildLuckCategoryCard(context, AppStrings.healthLuck, luckData.healthLuck),
      if (luckData.luckyNumber != null)
        _buildLuckCategoryCard(
            context, AppStrings.luckyNumber, luckData.luckyNumber.toString()),
      if (luckData.luckyColor != null)
        _buildLuckCategoryCard(
            context, AppStrings.luckyColor, luckData.luckyColor),
      _buildLuckCategoryCard(context, AppStrings.advice, luckData.advice),
    ];

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                SizedBox(height: spacing.small),
                Center(
                  child: InkWell(
                    onTap: () => _showZodiacSelectionBottomSheet(context),
                    borderRadius: BorderRadius.circular(8.0),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Obx(
                                () => Text(
                              AppStrings.zodiacLuckTitle(
                                  controller.currentSelectedZodiacDisplayName),
                              style: textStyles.titleMedium,
                            ),
                          ),
                          SizedBox(width: spacing.small),
                          Icon(
                            Icons.arrow_drop_down_circle_outlined,
                            size: 20,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    requestDateFormatted,
                    style: textStyles.bodyMedium
                        .copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ),
                SizedBox(height: spacing.medium),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => controller
                  .fetchTodaysLuck(controller.selectedZodiacApiName.value),
              child: ListView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 8.0),
                children: [
                  ...luckCards,
                  SizedBox(height: spacing.large * 5),
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
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final AppTextStyles textStyles = theme.extension<AppTextStyles>()!;
    final AppSpacing spacing = theme.extension<AppSpacing>()!;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: textStyles.bodyLarge),
            SizedBox(height: spacing.small),
            Text(
              content,
              style: textStyles.bodyMedium
                  .copyWith(height: 1.5, color: colorScheme.onSurfaceVariant),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }
}