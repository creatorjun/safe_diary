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
              // Get.back()을 onConfirm 내부에서 호출하도록 변경하여
              // onConfirm 내의 비동기 작업이 완료된 후 닫히게 할 수 있음.
              // 여기서는 즉시 닫고 onConfirm을 호출합니다.
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

  void showCustomBottomSheet({
    required Widget child,
    bool isScrollControlled = true,
  }) {
    Get.bottomSheet(
      child,
      backgroundColor: Colors.transparent,
      isScrollControlled: isScrollControlled,
    );
  }

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
