// lib/app/bindings/profile_binding.dart

import 'package:get/get.dart';
import 'package:safe_diary/app/controllers/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    // ProfileController는 LoginController와 PartnerController에 의존합니다.
    // 이들은 InitialBinding에서 이미 등록되었으므로 Get.find()로 찾아 주입합니다.
    Get.lazyPut<ProfileController>(
      () => ProfileController(Get.find(), Get.find()),
    );
  }
}
