// lib/app/views/profile_auth_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/profile_auth_controller.dart';
import '../theme/app_theme.dart';
import '../utils/app_strings.dart';
import 'widgets/shared_background.dart';

class ProfileAuthScreen extends GetView<ProfileAuthController> {
  const ProfileAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppTextStyles textStyles = theme.extension<AppTextStyles>()!;
    final AppSpacing spacing = theme.extension<AppSpacing>()!;
    final ColorScheme colorScheme = theme.colorScheme;

    return SharedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(AppStrings.profileAuthTitle, style: textStyles.bodyLarge),
          centerTitle: true,
          automaticallyImplyLeading: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(spacing.large),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  AppStrings.profileAuthPrompt,
                  style: textStyles.titleLarge,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: spacing.medium),
                Text(
                  AppStrings.profileAuthDescription,
                  style: textStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: spacing.large),
                TextField(
                  controller: controller.passwordController,
                  obscureText: true,
                  autofocus: true,
                  textAlign: TextAlign.center,
                  style: textStyles.bodyLarge,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: AppStrings.password,
                  ),
                  onSubmitted: (_) => controller.verifyPasswordAndNavigate(),
                ),
                SizedBox(height: spacing.small),
                Obx(() {
                  if (controller.errorMessage.value.isNotEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                      child: Text(
                        controller.errorMessage.value,
                        style: textStyles.bodyMedium.copyWith(
                          color: colorScheme.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),
                SizedBox(height: spacing.medium),
                Obx(() {
                  return controller.isLoading.value
                      ? const Center(child: CircularProgressIndicator())
                      : FilledButton(
                    onPressed: controller.verifyPasswordAndNavigate,
                    child: Text(
                      AppStrings.confirm,
                      style: textStyles.labelLarge,
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}