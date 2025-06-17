// lib/app/services/dialog_service.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safe_diary/app/theme/app_theme.dart';

class DialogService extends GetxService {
  void showLoading() {
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );
  }

  void hideLoading() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }

  void showInfoDialog({
    required String title,
    required String content,
    VoidCallback? onConfirm,
  }) {
    final ThemeData theme = Theme.of(Get.context!);
    final AppTextStyles textStyles = theme.extension<AppTextStyles>()!;

    Get.dialog(
      AlertDialog(
        title: Text(title, style: textStyles.titleMedium),
        content: Text(content, style: textStyles.bodyMedium),
        actions: [
          TextButton(
            onPressed: onConfirm ?? () => Get.back(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void showConfirmDialog({
    required String title,
    required String content,
    required VoidCallback onConfirm,
    String confirmText = '확인',
    String cancelText = '취소',
    Widget? customContent,
  }) {
    final ThemeData theme = Theme.of(Get.context!);
    final AppTextStyles textStyles = theme.extension<AppTextStyles>()!;
    final AppSpacing spacing = theme.extension<AppSpacing>()!;
    final ColorScheme colorScheme = theme.colorScheme;

    Get.dialog(
      AlertDialog(
        title: Text(title, style: textStyles.titleMedium),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(content, style: textStyles.bodyMedium),
            if (customContent != null) ...[
              SizedBox(height: spacing.medium),
              customContent,
            ],
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text(cancelText)),
          FilledButton(
            onPressed: () {
              Get.back();
              onConfirm();
            },
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  // --- 여기부터 수정 ---
  void showCustomBottomSheet({
    required Widget child,
    bool isScrollControlled = true,
    bool isDismissible = true, // 파라미터 추가
    bool enableDrag = true,    // 파라미터 추가
  }) {
    Get.bottomSheet(
      child,
      backgroundColor: Colors.transparent,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible, // 전달받은 값 사용
      enableDrag: enableDrag,       // 전달받은 값 사용
    );
  }
  // --- 여기까지 수정 ---

  void showSnackbar(
      String title,
      String message, {
        SnackPosition position = SnackPosition.BOTTOM,
      }) {
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }
    Get.snackbar(
      title,
      message,
      snackPosition: position,
      backgroundColor: Colors.black.withAlpha(200),
      colorText: Colors.white,
      margin: const EdgeInsets.all(12.0),
    );
  }
}