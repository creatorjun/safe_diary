// lib/app/services/user_service.dart

import 'dart:async';
import 'package:get/get.dart';
import 'api_service.dart';

class UserService extends GetxService {
  final ApiService _apiService;
  UserService(this._apiService);

  Future<void> updateNickname(String newNickname) async {
    await _apiService.patch('/api/v1/users/me', body: {'nickname': newNickname});
  }

  Future<bool> verifyAppPassword(String appPassword) async {
    try {
      return await _apiService.post(
        '/api/v1/users/me/verify-app-password',
        body: {'appPassword': appPassword},
        parser: (data) => data['isVerified'] as bool? ?? false,
      );
    } on ApiException catch (e) {
      if (e.statusCode == 401) return false;
      rethrow;
    }
  }

  Future<void> setOrUpdateAppPassword({String? currentAppPassword, required String newAppPassword}) async {
    final body = {'newAppPassword': newAppPassword};
    if (currentAppPassword != null && currentAppPassword.isNotEmpty) {
      body['currentAppPassword'] = currentAppPassword;
    }
    await _apiService.patch('/api/v1/users/me', body: body);
  }

  Future<void> removeAppPassword(String currentAppPassword) async {
    await _apiService.delete('/api/v1/users/me/app-password', body: {'currentAppPassword': currentAppPassword});
  }

  Future<void> deleteUserAccount() async {
    await _apiService.delete('/api/v1/users/me');
  }

  Future<void> updateFcmToken(String fcmToken) async {
    if (fcmToken.isEmpty) {
      throw ArgumentError('FCM 토큰이 비어있습니다.');
    }
    try {
      await _apiService.put('/api/v1/users/me/fcm-token', body: {'fcmToken': fcmToken});
    } on ApiException {
      // FCM 토큰 전송 실패는 치명적이지 않으므로 에러를 무시할 수 있습니다.
    }
  }
}