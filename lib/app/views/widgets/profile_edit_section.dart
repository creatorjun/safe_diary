// lib/app/views/profile/widgets/profile_edit_section.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safe_diary/app/controllers/profile_controller.dart';
import 'package:safe_diary/app/theme/app_theme.dart';
import 'package:safe_diary/app/utils/app_strings.dart';

class ProfileEditSection extends GetView<ProfileController> {
  const ProfileEditSection({super.key});

  @override
  Widget build(BuildContext context) {
    final AppTextStyles textStyles = Theme.of(context).extension<AppTextStyles>()!;
    final AppSpacing spacing = Theme.of(context).extension<AppSpacing>()!;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(AppStrings.editProfile, style: textStyles.titleLarge),
        SizedBox(height: spacing.small),
        Padding(
          padding: EdgeInsets.symmetric(vertical: spacing.medium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: controller.nicknameController,
                style: textStyles.bodyLarge,
                decoration: const InputDecoration(
                  labelText: AppStrings.nickname,
                  hintText: AppStrings.newNicknameHint,
                ),
              ),
              SizedBox(height: spacing.large),
              Text(
                controller.loginController.user.isAppPasswordSet
                    ? AppStrings.changeAppPassword
                    : AppStrings.setAppPassword,
                style: textStyles.bodyLarge,
              ),
              SizedBox(height: spacing.small),
              _buildPasswordField(
                context: context,
                controller: controller.newPasswordController,
                labelText: AppStrings.newPassword,
                hintText: AppStrings.newPasswordHint,
                isObscured: controller.isNewPasswordObscured,
                toggleVisibility: controller.toggleNewPasswordVisibility,
              ),
              SizedBox(height: spacing.medium),
              _buildPasswordField(
                context: context,
                controller: controller.confirmPasswordController,
                labelText: AppStrings.newPasswordConfirm,
                hintText: AppStrings.newPasswordConfirmHint,
                isObscured: controller.isConfirmPasswordObscured,
                toggleVisibility: controller.toggleConfirmPasswordVisibility,
              ),
            ],
          ),
        ),
        SizedBox(height: spacing.small),
        Obx(
              () => FilledButton.icon(
            icon: const Icon(Icons.save_outlined, size: 18),
            label: Text(
              AppStrings.saveChanges,
              style: textStyles.labelLarge,
            ),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
            onPressed:
            controller.hasChanges.value ? controller.saveChanges : null,
          ),
        ),
        Obx(() {
          if (controller.loginController.user.isAppPasswordSet) {
            return Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: OutlinedButton.icon(
                icon: Icon(
                  Icons.lock_open_outlined,
                  color: colorScheme.error,
                ),
                label: Text(
                  AppStrings.removeAppPassword,
                  style: textStyles.bodyLarge.copyWith(
                    color: colorScheme.error,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  side: BorderSide(
                    color: colorScheme.error.withAlpha(80),
                  ),
                ),
                onPressed: controller.promptForPasswordAndRemove,
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        }),
      ],
    );
  }

  Widget _buildPasswordField({
    required BuildContext context,
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required RxBool isObscured,
    required VoidCallback toggleVisibility,
  }) {
    final AppTextStyles textStyles =
    Theme.of(context).extension<AppTextStyles>()!;
    return Obx(
          () => TextField(
        controller: controller,
        obscureText: isObscured.value,
        style: textStyles.bodyLarge,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          suffixIcon: IconButton(
            icon: Icon(
              isObscured.value ? Icons.visibility_off : Icons.visibility,
            ),
            onPressed: toggleVisibility,
          ),
        ),
      ),
    );
  }
}