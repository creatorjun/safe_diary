// lib/app/bindings/initial_binding.dart

import 'package:get/get.dart';
import 'package:safe_diary/app/controllers/error_controller.dart';
import 'package:safe_diary/app/controllers/login_controller.dart';
import 'package:safe_diary/app/controllers/partner_controller.dart';
import 'package:safe_diary/app/services/api_service.dart';
import 'package:safe_diary/app/services/auth_service.dart';
import 'package:safe_diary/app/services/notification_service.dart';
import 'package:safe_diary/app/services/secure_storage_service.dart';
import 'package:safe_diary/app/services/user_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // 1. 의존성이 없는 핵심 서비스들을 먼저 등록합니다.
    // permanent: true 옵션으로 앱 전역에서 항상 접근 가능하도록 설정합니다.
    Get.put(ApiService(), permanent: true);
    Get.put(SecureStorageService(), permanent: true);
    Get.put(NotificationService(), permanent: true);
    Get.put(ErrorController(), permanent: true);

    // 2. 다른 서비스에 의존하는 서비스들을 등록하고, Get.find()로 의존성을 주입합니다.
    Get.put(AuthService(Get.find(), Get.find()), permanent: true);
    Get.put(UserService(Get.find()), permanent: true);

    // 3. 핵심 컨트롤러들을 등록합니다.
    // LoginController는 여러 서비스에 의존합니다.
    Get.put(
      LoginController(Get.find(), Get.find(), Get.find()),
      permanent: true,
    );
    // PartnerController는 LoginController에 의존합니다.
    Get.put(PartnerController(Get.find()), permanent: true);
  }
}
