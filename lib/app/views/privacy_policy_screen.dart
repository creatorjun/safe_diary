// lib/app/views/privacy_policy_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safe_diary/app/controllers/privacy_policy_controller.dart';
import 'package:safe_diary/app/theme/app_theme.dart';
import 'package:safe_diary/app/utils/app_strings.dart';
import 'package:safe_diary/app/utils/privacy_policy_content.dart';
import 'package:safe_diary/app/views/widgets/shared_background.dart';

class PrivacyPolicyScreen extends GetView<PrivacyPolicyController> {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppTextStyles textStyles = theme.extension<AppTextStyles>()!;
    final AppSpacing spacing = theme.extension<AppSpacing>()!;

    return SharedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(PrivacyPolicyContent.title, style: textStyles.titleMedium),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
        body: Padding(
          padding: EdgeInsets.all(spacing.medium),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(spacing.medium),
                  decoration: BoxDecoration(
                    color: theme.cardColor.withAlpha(204),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      PrivacyPolicyContent.content,
                      style: textStyles.bodyMedium.copyWith(height: 1.6),
                    ),
                  ),
                ),
              ),
              SizedBox(height: spacing.medium),
              Obx(
                    () => CheckboxListTile(
                  title: Text(
                    "위 개인정보 처리 방침 내용에 모두 동의합니다.",
                    style: textStyles.bodyMedium,
                  ),
                  value: controller.isAgreed.value,
                  onChanged: controller.toggleAgreement,
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: theme.colorScheme.primary,
                  tileColor: theme.cardColor.withAlpha(204),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: spacing.medium),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        side: BorderSide(
                          color: theme.colorScheme.outline.withAlpha(128),
                        ),
                      ),
                      onPressed: controller.declineAndWithdraw,
                      child: const Text(AppStrings.decline),
                    ),
                  ),
                  SizedBox(width: spacing.small),
                  Expanded(
                    child: Obx(
                          () => FilledButton(
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                        ),
                        onPressed: controller.isAgreed.value
                            ? controller.proceedToHome
                            : null,
                        child: Text(
                          AppStrings.agreeAndStart,
                          style: textStyles.labelLarge,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}