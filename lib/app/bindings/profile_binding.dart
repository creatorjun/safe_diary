import 'package:get/get.dart';
import 'package:safe_diary/app/controllers/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileController>(
      () => ProfileController(Get.find(), Get.find(), Get.find()),
    );
  }
}
