// lib/app/services/user_service.dart

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../models/user.dart';
import 'api_service.dart';

class UserService extends GetxService {
  final ApiService _apiService;

  UserService(this._apiService);


  Future<User> updateNickname(String newNickname) async {
    return await _apiService.patch<User>(
      '/api/v1/users/me',
      body: {'nickname': newNickname},
      parser: (data) => User.fromJson(data as Map<String, dynamic>),
    );
  }

  /// 최초 소셜 로그인 후 사용자가 동의를 거부했을 때 회원가입을 철회합니다.
  Future<void> withdrawRegistration() async {
    await _apiService.delete('/api/v1/users/me/withdrawal');
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

  Future<User> setOrUpdateAppPassword({
    String? currentAppPassword,
    required String newAppPassword,
  }) async {
    final body = {'newAppPassword': newAppPassword};
    if (currentAppPassword != null && currentAppPassword.isNotEmpty) {
      body['currentAppPassword'] = currentAppPassword;
    }
    // 명세에 따라 서버는 UserAccountUpdateResponseDto를 반환하며,
    // User.fromJson 팩토리에서 이를 처리합니다.
    return await _apiService.patch<User>(
      '/api/v1/users/me',
      body: body,
      parser: (data) => User.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<void> removeAppPassword(String currentAppPassword) async {
    // 명세에 따라 서버는 204 No Content를 반환하므로, 반환 타입을 void로 변경합니다.
    await _apiService.delete<void>(
      '/api/v1/users/me/app-password',
      body: {'currentAppPassword': currentAppPassword},
    );
  }

  Future<void> deleteUserAccount() async {
    await _apiService.delete('/api/v1/users/me');
  }

  Future<void> updateFcmToken(String fcmToken) async {
    if (fcmToken.isEmpty) {
      throw ArgumentError('FCM 토큰이 비어있습니다.');
    }
    try {
      await _apiService.put(
        '/api/v1/users/me/fcm-token',
        body: {'fcmToken': fcmToken},
      );
    } on ApiException {
      if(kDebugMode){
        print('[UserService] FCM 토큰 업데이트 실패: $fcmToken');
      }
    }
  }
}