// lib/app/bindings/chat_binding.dart

import 'package:get/get.dart';
import 'package:safe_diary/app/controllers/chat_controller.dart';
import 'package:safe_diary/app/services/chat_service.dart';

class ChatBinding extends Bindings {
  @override
  void dependencies() {
    // ChatService는 ApiService에 의존합니다.
    Get.lazyPut<ChatService>(() => ChatService(Get.find()));

    // 이전 화면에서 전달받은 파트너 정보를 가져옵니다.
    final arguments = Get.arguments as Map<String, dynamic>?;
    final String? partnerUid = arguments?['partnerUid'] as String?;
    final String? partnerNickname = arguments?['partnerNickname'] as String?;

    if (partnerUid == null) {
      throw Exception("ChatBinding: partnerUid가 전달되지 않았습니다.");
    }

    // ChatController에 필요한 모든 의존성을 주입합니다.
    Get.lazyPut<ChatController>(
          () => ChatController(
        chatService: Get.find(),
        loginController: Get.find(),
        partnerUid: partnerUid,
        partnerNickname: partnerNickname,
      ),
    );
  }
}