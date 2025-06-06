// lib/app/services/auth_service.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../models/user.dart';
import 'api_service.dart';
import 'secure_storage_service.dart';

class AuthService extends GetxService {
  final ApiService _apiService;
  final SecureStorageService _secureStorageService;

  AuthService(this._apiService, this._secureStorageService);

  Future<User?> signInWithSocialUser(User socialUserInfo) async {
    final requestBody = {
      'id': socialUserInfo.id,
      'nickname': socialUserInfo.nickname,
      'platform': socialUserInfo.platform.name,
      'socialAccessToken': socialUserInfo.socialAccessToken,
    };

    try {
      final responseData = await _apiService.post('/api/v1/auth/social/login', body: requestBody);
      return _processAuthResponse(responseData, socialUserInfo: socialUserInfo);
    } catch (e) {
      if (kDebugMode) print('[AuthService] signInWithSocialUser Error: $e');
      rethrow;
    }
  }

  Future<User?> attemptAutoLogin() async {
    final refreshToken = await _secureStorageService.getRefreshToken();
    if (refreshToken == null) {
      return null;
    }

    try {
      final responseData = await _apiService.post(
        '/api/v1/auth/refresh',
        body: {'refreshToken': refreshToken},
      );
      return _processAuthResponse(responseData, existingRefreshToken: refreshToken);
    } catch (e) {
      if (e is ApiException && e.statusCode == 401) {
        await _secureStorageService.clearRefreshToken();
      }
      return null;
    }
  }

  Future<User> _processAuthResponse(Map<String, dynamic> responseData, {User? socialUserInfo, String? existingRefreshToken}) async {
    final newAccessToken = responseData['accessToken'] as String?;
    final newRefreshToken = responseData['refreshToken'] as String?;
    final serverUserId = responseData['uid'] as String?;

    if (serverUserId == null || newAccessToken == null) {
      throw ApiException('서버로부터 필수 사용자 정보를 받지 못했습니다.');
    }

    final finalRefreshToken = newRefreshToken ?? existingRefreshToken;
    if (finalRefreshToken == null) {
      throw ApiException('리프레시 토큰을 찾을 수 없습니다.');
    }
    await _secureStorageService.saveRefreshToken(refreshToken: finalRefreshToken);

    DateTime? createdAtDate;
    final createdAtString = responseData['createdAt'] as String?;
    if (createdAtString != null && createdAtString.isNotEmpty) {
      createdAtDate = DateTime.tryParse(createdAtString);
    }

    return User(
      id: serverUserId,
      nickname: responseData['nickname'] as String? ?? socialUserInfo?.nickname,
      platform: LoginPlatform.values.firstWhere(
            (e) => e.name == (responseData['loginProvider'] as String?),
        orElse: () => socialUserInfo?.platform ?? LoginPlatform.none,
      ),
      safeAccessToken: newAccessToken,
      safeRefreshToken: finalRefreshToken,
      isNew: responseData['isNew'] as bool? ?? false,
      isAppPasswordSet: responseData['appPasswordSet'] as bool? ?? false,
      partnerUid: responseData['partnerUid'] as String?,
      partnerNickname: responseData['partnerNickname'] as String?,
      createdAt: createdAtDate,
      socialAccessToken: socialUserInfo?.socialAccessToken,
    );
  }

  Future<void> clearTokensOnLogout() async {
    await _secureStorageService.clearAllUserData();
  }
}