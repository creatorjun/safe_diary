import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/profile_auth_controller.dart';
import '../theme/app_theme.dart';

class ProfileAuthScreen extends GetView<ProfileAuthController> {
  const ProfileAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppTextStyles textStyles = theme.extension<AppTextStyles>()!;
    final AppSpacing spacing = theme.extension<AppSpacing>()!;
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('개인정보 접근 인증', style: textStyles.bodyLarge),
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(spacing.large),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '접근 비밀번호 입력',
                style: textStyles.titleLarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: spacing.medium),
              Text(
                '개인정보를 보호하기 위해 설정하신 비밀번호를 입력해주세요.',
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
                decoration: const InputDecoration(
                  hintText: '비밀번호',
                ),
                onSubmitted: (_) => controller.verifyPasswordAndNavigate(),
              ),
              SizedBox(height: spacing.small),
              Obx(() {
                if (controller.errorMessage.value.isNotEmpty) {
                  return Padding(
                    padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                    child: Text(
                      controller.errorMessage.value,
                      style: textStyles.bodyMedium
                          .copyWith(color: colorScheme.error),
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
                  child: Text('확인', style: textStyles.labelLarge),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}