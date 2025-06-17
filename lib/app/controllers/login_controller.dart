// lib/app/controllers/login_controller.dart

import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk_user.dart' as kakao;
import 'package:naver_login_sdk/naver_login_sdk.dart';
import 'package:safe_diary/app/utils/app_strings.dart';

import '../models/user.dart';
import '../routes/app_pages.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/secure_storage_service.dart';
import '../services/user_service.dart';
import 'error_controller.dart';
import 'partner_controller.dart';

class LoginController extends GetxController {
  final AuthService _authService;
  final UserService _userService;
  // ignore: unused_field
  final SecureStorageService _secureStorageService;

  LoginController(
      this._authService,
      this._userService,
      this._secureStorageService,
      );

  PartnerController get _partnerController => Get.find<PartnerController>();

  ErrorController get _errorController => Get.find<ErrorController>();

  final Rx<User> _user = User(platform: LoginPlatform.none).obs;
  User get user => _user.value;
  Rx<User> get userState => _user;

  RxBool get isLoggedIn =>
      (_user.value.platform != LoginPlatform.none &&
          _user.value.safeAccessToken != null)
          .obs;
  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    Get.find<ApiService>().setTokenProvider(() => _user.value.safeAccessToken);
  }

  void _setLoading(bool loading) => _isLoading.value = loading;

  void _handleError(Object e, {String? userFriendlyMsg}) {
    _errorController.handleError(e, userFriendlyMessage: userFriendlyMsg);
  }

  Future<void> sendFcmTokenToServer(String fcmToken) async {
    if (!isLoggedIn.value || fcmToken.isEmpty) return;
    try {
      await _userService.updateFcmToken(fcmToken);
      if (kDebugMode) {
        print('[LoginController] FCM token sent to server: $fcmToken');
      }
    } catch (e) {
      if (kDebugMode) print('[LoginController] FCM 토큰 전송 실패: $e');
    }
  }

  Future<void> loginWithNaver() async {
    _setLoading(true);
    try {
      await _authenticateNaver();
      final socialUser = await _getNaverSocialUser();
      await _processSocialLogin(socialUser);
    } catch (e) {
      _handleError(e, userFriendlyMsg: AppStrings.naverLoginFailed);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _authenticateNaver() {
    final completer = Completer<void>();
    NaverLoginSDK.authenticate(
      callback: OAuthLoginCallback(
        onSuccess: () => completer.complete(),
        onFailure: (status, message) => completer.completeError(
          'Naver Login Failed: $message (Status: $status)',
        ),
        onError: (code, message) => completer.completeError(
          'Naver Login Error: $message (Code: $code)',
        ),
      ),
    );
    return completer.future;
  }

  Future<User> _getNaverSocialUser() async {
    final profile = await _fetchNaverProfile();
    final accessToken = await NaverLoginSDK.getAccessToken();
    return User(
      platform: LoginPlatform.naver,
      id: profile.id,
      nickname: profile.nickName,
      socialAccessToken: accessToken,
    );
  }

  Future<NaverLoginProfile> _fetchNaverProfile() {
    final completer = Completer<NaverLoginProfile>();
    NaverLoginSDK.profile(
      callback: ProfileCallback(
        onSuccess: (resultCode, message, response) {
          completer.complete(NaverLoginProfile.fromJson(response: response));
        },
        onFailure: (httpStatus, message) => completer.completeError(
          'Naver Profile Fail: $message (HTTP: $httpStatus)',
        ),
        onError: (errorCode, message) => completer.completeError(
          'Naver Profile Error: $message (Code: $errorCode)',
        ),
      ),
    );
    return completer.future;
  }

  Future<void> loginWithKakao() async {
    _setLoading(true);
    try {
      final socialUser = await _getKakaoSocialUser();
      await _processSocialLogin(socialUser);
    } catch (e) {
      if (e is PlatformException && e.code == 'CANCELED') {
        // 사용자가 로그인을 취소한 경우는 오류로 처리하지 않음
      } else {
        _handleError(e, userFriendlyMsg: AppStrings.kakaoLoginFailed);
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<User> _getKakaoSocialUser() async {
    kakao.OAuthToken token;
    final bool isKakaoTalkInstalled = await kakao.isKakaoTalkInstalled();

    if (isKakaoTalkInstalled) {
      try {
        token = await kakao.UserApi.instance.loginWithKakaoTalk();
      } catch (error) {
        if (error is PlatformException && error.code == 'CANCELED') {
          rethrow;
        }
        try {
          token = await kakao.UserApi.instance.loginWithKakaoAccount();
        } catch (accountError) {
          throw Exception('Kakao account login failed: $accountError');
        }
      }
    } else {
      try {
        token = await kakao.UserApi.instance.loginWithKakaoAccount();
      } catch (accountError) {
        throw Exception('Kakao account login failed: $accountError');
      }
    }

    try {
      final kakaoApiUser = await kakao.UserApi.instance.me();
      return User(
        platform: LoginPlatform.kakao,
        id: kakaoApiUser.id.toString(),
        nickname: kakaoApiUser.kakaoAccount?.profile?.nickname,
        socialAccessToken: token.accessToken,
      );
    } catch (userError) {
      throw Exception('Failed to get Kakao user info: $userError');
    }
  }

  Future<void> _processSocialLogin(User socialUser) async {
    try {
      final authenticatedUser = await _authService.signInWithSocialUser(
        socialUser,
      );
      if (authenticatedUser != null) {
        _user.value = authenticatedUser;
        await _getAndSendFcmTokenWithRetry();

        if (authenticatedUser.isNew) {
          Get.offAllNamed(Routes.privacyPolicy);
        } else {
          Get.offAllNamed(Routes.home);
        }
      }
    } catch (e) {
      _handleError(e, userFriendlyMsg: AppStrings.serverConnectionError);
      rethrow;
    }
  }

  Future<String> tryAutoLoginAndGetInitialRoute() async {
    _setLoading(true);
    try {
      final authenticatedUser = await _authService.attemptAutoLogin();
      if (authenticatedUser != null) {
        _user.value = authenticatedUser;
        await _getAndSendFcmTokenWithRetry();
        _setLoading(false);
        return authenticatedUser.isNew ? Routes.privacyPolicy : Routes.home;
      }
    } catch (e) {
      //
    }
    _setLoading(false);
    return Routes.login;
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      if (_user.value.platform == LoginPlatform.naver) {
        await NaverLoginSDK.release();
      } else if (_user.value.platform == LoginPlatform.kakao) {
        await kakao.UserApi.instance.logout();
      }

      _partnerController.clearPartnerStateOnLogout();
      await _authService.clearTokensOnLogout();
      _user.value = User(platform: LoginPlatform.none);

      Get.offAllNamed(Routes.login);
      Get.snackbar(AppStrings.logout, AppStrings.logoutSuccess);
    } catch (e) {
      _handleError(e, userFriendlyMsg: AppStrings.logoutError);
    } finally {
      _setLoading(false);
    }
  }

  // --- 여기부터 추가 ---

  /// 개인정보 동의 거부에 따른 회원가입을 철회하고 로그아웃합니다.
  Future<void> withdrawRegistrationAndLogout() async {
    _setLoading(true);
    try {
      // 서버에 회원가입 철회 요청
      await _userService.withdrawRegistration();

      // 소셜 SDK 로그아웃 처리
      if (_user.value.platform == LoginPlatform.naver) {
        await NaverLoginSDK.release();
      } else if (_user.value.platform == LoginPlatform.kakao) {
        await kakao.UserApi.instance.logout();
      }

      // 로컬 데이터 및 상태 초기화
      _partnerController.clearPartnerStateOnLogout();
      await _authService.clearTokensOnLogout();
      _user.value = User(platform: LoginPlatform.none);

      // 로그인 화면으로 이동
      Get.offAllNamed(Routes.login);
      Get.snackbar(AppStrings.notification, "회원가입이 정상적으로 철회되었습니다.");

    } catch (e) {
      _handleError(e, userFriendlyMsg: "가입 철회 중 오류가 발생했습니다. 다시 시도해주세요.");
      // 실패하더라도 일단 로그인 화면으로 보내서 사용자가 다시 시도할 수 있도록 함
      if (isLoggedIn.value) {
        await logout();
      }
    } finally {
      _setLoading(false);
    }
  }

  // --- 여기까지 추가 ---

  void updateUserPartnerUid(String? newPartnerUid, {String? partnerNickname}) {
    if (_user.value.partnerUid != newPartnerUid) {
      _user.value = _user.value.copyWith(
        partnerUid: newPartnerUid,
        partnerNickname: partnerNickname,
      );
    }
  }

  Future<void> _getAndSendFcmTokenWithRetry({int maxRetries = 3}) async {
    for (int i = 0; i < maxRetries; i++) {
      try {
        final fcmToken = await FirebaseMessaging.instance.getToken();
        if (fcmToken != null) {
          await sendFcmTokenToServer(fcmToken);
          return;
        }
      } catch (e) {
        if (kDebugMode) {
          print('[LoginController] FCM Token attempt ${i + 1} failed: $e');
          if (i < maxRetries - 1) {
            await Future.delayed(const Duration(seconds: 2));
          }
        }
      }
    }
  }

  Future<User> updateUserNickname(String newNickname) async {
    try {
      final updatedUserFromServer = await _userService.updateNickname(
        newNickname,
      );
      _user.value = updatedUserFromServer.copyWith(
        safeAccessToken: _user.value.safeAccessToken,
        safeRefreshToken: _user.value.safeRefreshToken,
      );
      return _user.value;
    } catch (e) {
      _handleError(e, userFriendlyMsg: AppStrings.nicknameUpdateFailed);
      rethrow;
    }
  }

  Future<bool> verifyAppPassword(String appPassword) async {
    try {
      return await _userService.verifyAppPassword(appPassword);
    } catch (e) {
      _handleError(e, userFriendlyMsg: AppStrings.passwordVerifyFailed);
      return false;
    }
  }

  Future<bool> setOrUpdateAppPassword({
    String? currentAppPassword,
    required String newAppPassword,
  }) async {
    try {
      await _userService.setOrUpdateAppPassword(
        currentAppPassword: currentAppPassword,
        newAppPassword: newAppPassword,
      );
      _user.value = _user.value.copyWith(isAppPasswordSet: true);
      return true;
    } catch (e) {
      _handleError(e, userFriendlyMsg: AppStrings.passwordSetFailed);
      rethrow;
    }
  }

  Future<bool> removeAppPassword(String currentAppPassword) async {
    try {
      await _userService.removeAppPassword(currentAppPassword);
      _user.value = _user.value.copyWith(isAppPasswordSet: false);
      return true;
    } catch (e) {
      _handleError(e, userFriendlyMsg: AppStrings.passwordRemoveFailed);
      rethrow;
    }
  }

  Future<void> processAccountDeletion() async {
    _setLoading(true);
    try {
      if (_user.value.partnerUid != null &&
          _user.value.partnerUid!.isNotEmpty) {
        await _partnerController.unfriendPartnerAndClearChat();
      }
      await _userService.deleteUserAccount();

      if (_user.value.platform == LoginPlatform.kakao) {
        await kakao.UserApi.instance.unlink();
      } else if (_user.value.platform == LoginPlatform.naver) {
        await NaverLoginSDK.release();
      }

      await _authService.clearTokensOnLogout();
      _partnerController.clearPartnerStateOnLogout();
      _user.value = User(platform: LoginPlatform.none);

      Get.offAllNamed(Routes.login);
      Get.snackbar(
        AppStrings.accountDeletion,
        AppStrings.accountDeletionSuccess,
      );
    } catch (e) {
      _handleError(e, userFriendlyMsg: AppStrings.accountDeletionFailed);
    } finally {
      _setLoading(false);
    }
  }
}