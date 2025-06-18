import 'package:get/get.dart';
import 'package:safe_diary/app/controllers/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    // AnniversaryService는 HomeBinding에서 이미 등록되었으므로 Get.find()로 찾을 수 있습니다.
    Get.lazyPut<ProfileController>(
          () => ProfileController(
        Get.find(), // LoginController
        Get.find(), // PartnerController
        Get.find(), // DialogService
        Get.find(), // AnniversaryService
      ),
    );
  }
}