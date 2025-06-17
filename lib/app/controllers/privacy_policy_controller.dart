// lib/app/controllers/privacy_policy_controller.dart

import 'package:get/get.dart';
import 'package:safe_diary/app/controllers/login_controller.dart';
import 'package:safe_diary/app/routes/app_pages.dart';
import 'package:safe_diary/app/services/dialog_service.dart'; // <<< 추가
import 'package:safe_diary/app/utils/app_strings.dart';

class PrivacyPolicyController extends GetxController {
  // --- 여기부터 수정 ---
  final DialogService _dialogService;

  PrivacyPolicyController(this._dialogService);
  // --- 여기까지 수정 ---

  final RxBool isAgreed = false.obs;

  void toggleAgreement(bool? value) {
    isAgreed.value = value ?? false;
  }

  void proceedToHome() {
    if (isAgreed.value) {
      Get.offAllNamed(Routes.home);
    } else {
      Get.snackbar(
        AppStrings.notification,
        AppStrings.policyAgreementRequired,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// 동의를 거부하고 회원가입을 철회합니다.
  Future<void> declineAndWithdraw() async {
    _dialogService.showConfirmDialog(
      title: AppStrings.withdrawRegistrationTitle,
      content: AppStrings.withdrawRegistrationContent,
      confirmText: AppStrings.withdrawRegistrationTitle,
      onConfirm: () async {
        // 확인 버튼을 누르면 가입 철회 로직 실행
        await Get.find<LoginController>().withdrawRegistrationAndLogout();
      },
    );
  }
}