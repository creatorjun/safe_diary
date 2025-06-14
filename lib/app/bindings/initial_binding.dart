import 'package:get/get.dart';
import 'package:safe_diary/app/controllers/error_controller.dart';
import 'package:safe_diary/app/controllers/login_controller.dart';
import 'package:safe_diary/app/controllers/partner_controller.dart';
import 'package:safe_diary/app/services/api_service.dart';
import 'package:safe_diary/app/services/auth_service.dart';
import 'package:safe_diary/app/services/dialog_service.dart';
import 'package:safe_diary/app/services/notification_service.dart';
import 'package:safe_diary/app/services/secure_storage_service.dart';
import 'package:safe_diary/app/services/user_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ApiService(), permanent: true);
    Get.put(SecureStorageService(), permanent: true);
    Get.put(NotificationService(), permanent: true);
    Get.put(ErrorController(), permanent: true);
    Get.put(DialogService(), permanent: true);

    Get.put(AuthService(Get.find(), Get.find()), permanent: true);
    Get.put(UserService(Get.find()), permanent: true);

    Get.put(
      LoginController(Get.find(), Get.find(), Get.find()),
      permanent: true,
    );
    Get.put(PartnerController(Get.find(), Get.find()), permanent: true);
  }
}
