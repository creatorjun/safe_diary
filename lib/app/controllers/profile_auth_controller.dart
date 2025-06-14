// lib/app/controllers/profile_auth_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/login_controller.dart';
import '../controllers/partner_controller.dart';
import '../routes/app_pages.dart';
import '../services/secure_storage_service.dart';
import '../utils/app_strings.dart';

class ProfileAuthController extends GetxController {
  final LoginController _loginController;
  final PartnerController _partnerController;
  final SecureStorageService _secureStorageService;

  ProfileAuthController(
    this._loginController,
    this._partnerController,
    this._secureStorageService,
  );

  late TextEditingController passwordController;

  final RxString errorMessage = ''.obs;
  final RxBool isLoading = false.obs;
  final int maxFailedAttempts = 4;

  @override
  void onInit() {
    super.onInit();
    passwordController = TextEditingController();
  }

  @override
  void onReady() {
    super.onReady();
    _checkPasswordStatusAndProceed();
  }

  void _checkPasswordStatusAndProceed() async {
    if (!_loginController.user.isAppPasswordSet) {
      await _secureStorageService.clearFailedAttemptCount();
      Get.offNamed(Routes.profile);
    }
  }

  Future<void> verifyPasswordAndNavigate() async {
    isLoading.value = true;
    errorMessage.value = '';
    final String enteredPassword = passwordController.text;

    if (enteredPassword.isEmpty) {
      errorMessage.value = AppStrings.passwordRequired;
      isLoading.value = false;
      return;
    }

    final bool isVerified = await _loginController.verifyAppPassword(
      enteredPassword,
    );

    if (isVerified) {
      await _secureStorageService.clearFailedAttemptCount();
      final enteredPasswordCopy = passwordController.text;
      passwordController.clear();
      isLoading.value = false;
      Get.offNamed(
        Routes.profile,
        arguments: {'verifiedPassword': enteredPasswordCopy},
      );
    } else {
      int currentAttempts = await _secureStorageService.getFailedAttemptCount();
      currentAttempts++;
      await _secureStorageService.saveFailedAttemptCount(currentAttempts);

      errorMessage.value = AppStrings.passwordIncorrect;
      passwordController.clear();

      if (currentAttempts >= maxFailedAttempts) {
        await _handleMaxFailedAttempts();
      }
      isLoading.value = false;
    }
  }

  Future<void> _handleMaxFailedAttempts() async {
    errorMessage.value = '비밀번호를 $maxFailedAttempts회 이상 잘못 입력하여 로그아웃됩니다.';
    Get.snackbar(
      "보안 조치",
      AppStrings.securityLogoutWarning,
      duration: const Duration(seconds: 5),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(12.0),
    );

    if (_loginController.user.partnerUid != null &&
        _loginController.user.partnerUid!.isNotEmpty) {
      await _partnerController.unfriendPartnerAndClearChat();
    }

    await _loginController.logout();
  }

  @override
  void onClose() {
    passwordController.dispose();
    super.onClose();
  }
}
