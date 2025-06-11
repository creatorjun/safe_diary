import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safe_diary/app/services/api_service.dart';

class ErrorController extends GetxController {
  void handleError(Object e, {String? userFriendlyMessage}) {
    // 개발 중에는 상세한 에러 로그를 콘솔에 출력
    if (kDebugMode) {
      print('==================== ERROR HANDLED ====================');
      print('Error Type: ${e.runtimeType}');
      print('Error Details: $e');
      print('=======================================================');
    }

    String messageToShow;

    // 미리 정의된 사용자 친화적 메시지가 있으면 그것을 사용함
    if (userFriendlyMessage != null) {
      messageToShow = userFriendlyMessage;
    } else {
      // 오류 종류에 따라 다른 기본 메시지를 설정
      switch (e.runtimeType) {
        case SocketException:
          messageToShow = "네트워크에 연결할 수 없습니다. 인터넷 상태를 확인해주세요.";
          break;
        case ApiException:
          // ApiService에서 보낸 메시지를 그대로 사용하거나, 더 일반적인 메시지로 교체 가능
          messageToShow = (e as ApiException).message;
          break;
        default:
          messageToShow = "알 수 없는 오류가 발생했습니다. 잠시 후 다시 시도해주세요.";
      }
    }

    // 사용자에게는 표준화된 스낵바를 통해 메시지 표시
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }
    Get.snackbar(
      '알림',
      messageToShow,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black.withOpacity(0.7),
      colorText: Colors.white,
      margin: const EdgeInsets.all(12.0),
    );
  }
}
