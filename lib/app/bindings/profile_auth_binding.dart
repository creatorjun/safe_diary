// lib/app/bindings/profile_auth_binding.dart

import 'package:get/get.dart';
import 'package:safe_diary/app/controllers/profile_auth_controller.dart';

class ProfileAuthBinding extends Bindings {
  @override
  void dependencies() {
    // ProfileAuthController에 필요한 의존성들을 주입합니다.
    // 필요한 컨트롤러와 서비스는 모두 InitialBinding에서 등록되었습니다.
    Get.lazyPut<ProfileAuthController>(
      () => ProfileAuthController(Get.find(), Get.find(), Get.find()),
    );
  }
}
