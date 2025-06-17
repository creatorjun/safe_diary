// lib/app/bindings/privacy_policy_binding.dart

import 'package:get/get.dart';
import 'package:safe_diary/app/controllers/privacy_policy_controller.dart';
import 'package:safe_diary/app/services/dialog_service.dart'; // <<< 추가

class PrivacyPolicyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PrivacyPolicyController>(
          () => PrivacyPolicyController(
        Get.find<DialogService>(), // <<< DialogService 주입
      ),
    );
  }
}