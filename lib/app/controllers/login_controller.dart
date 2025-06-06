// lib/app/controllers/login_controller.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk_user.dart' as kakao;
import 'package:naver_login_sdk/naver_login_sdk.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../models/user.dart';
import '../routes/app_pages.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/secure_storage_service.dart';
import '../services/user_service.dart';
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

  // PartnerController를 getter로 변경하여 순환 의존성 문제를 해결합니다.
  // Get.find()는 _partnerController가 실제로 사용될 때 호출됩니다.
  PartnerController get _partnerController => Get.find<PartnerController>();

  final Rx<User> _user = User(platform: LoginPlatform.none).obs;
  User get user => _user.value;
  Rx<User> get userState => _user;

  RxBool get isLoggedIn => (_user.value.platform != LoginPlatform.none && _user.value.safeAccessToken != null).obs;
  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  final RxString _errorMessage = ''.obs;
  String get errorMessage => _errorMessage.value;

  @override
  void onInit() {
    super.onInit();
    // onInit에서 PartnerController를 찾는 코드를 제거합니다.
    // ApiService에 토큰 제공자를 설정하는 역할만 남겨둡니다.
    Get.find<ApiService>().setTokenProvider(() => _user.value.safeAccessToken);
  }

  void _setLoading(bool loading) => _isLoading.value = loading;
  void _clearError() => _errorMessage.value = '';
  void _setError(String msg, {bool showGeneralMessageToUser = true}) {
    final message = showGeneralMessageToUser ? "오류가 발생했습니다. 잠시 후 다시 시도해주세요." : msg;
    if (kDebugMode) print("[LoginController] Error: $msg");
    _errorMessage.value = message;
  }

  Future<void> sendFcmTokenToServer(String fcmToken) async {
    if (!isLoggedIn.value || fcmToken.isEmpty) return;
    try {
      await _userService.updateFcmToken(fcmToken);
      if (kDebugMode) print('[LoginController] FCM token sent to server: $fcmToken');
    } catch (e) {
      if (kDebugMode) print('[LoginController] FCM 토큰 전송 실패: $e');
    }
  }

  Future<void> loginWithNaver() async {
    _setLoading(true);
    _clearError();
    try {
      await _authenticateNaver();
      final socialUser = await _getNaverSocialUser();
      await _processSocialLogin(socialUser);
    } catch (e) {
      _setError(e.toString(), showGeneralMessageToUser: false);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _authenticateNaver() {
    final completer = Completer<void>();
    NaverLoginSDK.authenticate(
      callback: OAuthLoginCallback(
        onSuccess: () => completer.complete(),
        onFailure: (status, message) => completer.completeError('네이버 로그인 실패: $message (코드: $status)'),
        onError: (code, message) => completer.completeError('네이버 로그인 오류: $message (코드: $code)'),
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
        onFailure: (httpStatus, message) => completer.completeError('네이버 프로필 요청 실패: $message (HTTP $httpStatus)'),
        onError: (errorCode, message) => completer.completeError('네이버 프로필 요청 오류: $message (코드: $errorCode)'),
      ),
    );
    return completer.future;
  }

  Future<void> loginWithKakao() async {
    _setLoading(true);
    _clearError();
    try {
      final socialUser = await _getKakaoSocialUser();
      await _processSocialLogin(socialUser);
    } catch (e) {
      _setError(e.toString(), showGeneralMessageToUser: false);
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
          throw '카카오톡 로그인이 취소되었습니다.';
        }
        try {
          token = await kakao.UserApi.instance.loginWithKakaoAccount();
        } catch (accountError) {
          throw '카카오 로그인에 실패했습니다: $accountError';
        }
      }
    } else {
      try {
        token = await kakao.UserApi.instance.loginWithKakaoAccount();
      } catch (accountError) {
        throw '카카오 로그인에 실패했습니다: $accountError';
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
      throw '카카오 사용자 정보 조회에 실패했습니다: $userError';
    }
  }

  Future<void> _processSocialLogin(User socialUser) async {
    try {
      final authenticatedUser = await _authService.signInWithSocialUser(socialUser);
      if (authenticatedUser != null) {
        _user.value = authenticatedUser;
        final fcmToken = await FirebaseMessaging.instance.getToken();
        if (fcmToken != null) {
          await sendFcmTokenToServer(fcmToken);
        }
        Get.offAllNamed(Routes.home);
      }
    } catch (e) {
      throw '서버 로그인에 실패했습니다: $e';
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    _clearError();
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
      Get.snackbar('로그아웃', '성공적으로 로그아웃되었습니다.');
    } catch (e) {
      _setError('로그아웃 중 오류 발생: $e');
    } finally {
      _setLoading(false);
    }
  }

  void updateUserPartnerUid(String? newPartnerUid, {String? partnerNickname}) {
    if (_user.value.partnerUid != newPartnerUid) {
      _user.value = _user.value.copyWith(
          partnerUid: newPartnerUid,
          partnerNickname: partnerNickname
      );
    }
  }

  Future<bool> tryAutoLoginWithRefreshToken() async {
    _setLoading(true);
    _clearError();
    try {
      final authenticatedUser = await _authService.attemptAutoLogin();
      if (authenticatedUser != null) {
        _user.value = authenticatedUser;
        final fcmToken = await FirebaseMessaging.instance.getToken();
        if (fcmToken != null) {
          await sendFcmTokenToServer(fcmToken);
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateUserNickname(String newNickname) async {
    _setLoading(true);
    _clearError();
    try {
      await _userService.updateNickname(newNickname);
      _user.value = _user.value.copyWith(nickname: newNickname);
      Get.snackbar('성공', '닉네임이 성공적으로 변경되었습니다.');
    } catch (e) {
      _setError('닉네임 변경 실패: ${e.toString()}', showGeneralMessageToUser: false);
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> verifyAppPasswordWithServer(String appPassword) async {
    _setLoading(true);
    _clearError();
    try {
      return await _userService.verifyAppPassword(appPassword);
    } catch (e) {
      _setError('비밀번호 검증 실패: ${e.toString()}', showGeneralMessageToUser: false);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> setAppPasswordOnServer(String? currentPassword, String newPassword) async {
    _setLoading(true);
    _clearError();
    try {
      await _userService.setOrUpdateAppPassword(
        currentAppPassword: currentPassword,
        newAppPassword: newPassword,
      );
      _user.value = _user.value.copyWith(isAppPasswordSet: true);
      return true;
    } catch (e) {
      _setError('비밀번호 설정 실패: ${e.toString()}', showGeneralMessageToUser: false);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> removeAppPasswordOnServer(String currentAppPassword) async {
    _setLoading(true);
    _clearError();
    try {
      await _userService.removeAppPassword(currentAppPassword);
      _user.value = _user.value.copyWith(isAppPasswordSet: false);
      Get.snackbar('성공', '앱 비밀번호가 성공적으로 해제되었습니다.');
      return true;
    } catch (e) {
      _setError('비밀번호 해제 실패: ${e.toString()}', showGeneralMessageToUser: false);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> processAccountDeletion() async {
    _setLoading(true);
    _clearError();
    try {
      if (_user.value.partnerUid != null && _user.value.partnerUid!.isNotEmpty) {
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
      Get.snackbar('회원 탈퇴 완료', '회원 탈퇴가 성공적으로 처리되었습니다.');
    } catch (e) {
      _setError('회원 탈퇴 처리 중 오류 발생: $e');
    } finally {
      _setLoading(false);
    }
  }
}