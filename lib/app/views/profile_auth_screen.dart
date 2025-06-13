import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/profile_auth_controller.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class ProfileAuthScreen extends GetView<ProfileAuthController> {
  const ProfileAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('개인정보 접근 인증', style: textStyleMedium),
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '접근 비밀번호 입력',
                style: textStyleLarge.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              verticalSpaceMedium,
              Text(
                '개인정보를 보호하기 위해 설정하신 비밀번호를 입력해주세요.',
                style: textStyleSmall,
                textAlign: TextAlign.center,
              ),
              verticalSpaceLarge,
              TextField(
                controller: controller.passwordController,
                obscureText: true,
                autofocus: true,
                textAlign: TextAlign.center,
                style: textStyleMedium,
                decoration: InputDecoration(
                  hintText: '비밀번호',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onSubmitted: (_) => controller.verifyPasswordAndNavigate(),
              ),
              verticalSpaceSmall,
              Obx(() {
                if (controller.errorMessage.value.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                    child: Text(
                      controller.errorMessage.value,
                      style: textStyleSmall.copyWith(color: colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
              verticalSpaceMedium,
              Obx(() {
                return controller.isLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                  ),
                  onPressed: controller.verifyPasswordAndNavigate,
                  child: const Text('확인', style: textStyleMedium),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}