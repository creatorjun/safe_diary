// lib/app/controllers/partner_controller.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/partner_dtos.dart';
import '../models/user.dart';
import 'login_controller.dart';

class PartnerController extends GetxController {
  // The LoginController dependency is now injected via the constructor.
  final LoginController _loginController;
  PartnerController(this._loginController);

  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  final RxString _errorMessage = ''.obs;
  String get errorMessage => _errorMessage.value;

  final Rx<PartnerInvitationResponseDto?> currentInvitation = Rx<PartnerInvitationResponseDto?>(null);
  final Rx<PartnerRelationResponseDto?> currentPartnerRelation = Rx<PartnerRelationResponseDto?>(null);

  void _setLoading(bool loading) {
    _isLoading.value = loading;
  }

  void _clearError() {
    _errorMessage.value = '';
  }

  void _setError(String detailedLogMessage, {bool showGeneralMessageToUser = true}) {
    if (kDebugMode) {
      print("[PartnerController] Detailed Error: $detailedLogMessage");
    }
    _errorMessage.value = showGeneralMessageToUser ? "파트너 관련 작업 중 오류가 발생했습니다." : detailedLogMessage;
  }

  @override
  void onInit() {
    super.onInit();
    // Listen to changes in the user object from the injected LoginController.
    ever(_loginController.userState, (User user) {
      _synchronizePartnerStatus(user);
    });
    // Also run the sync once at initialization.
    _synchronizePartnerStatus(_loginController.user);
  }

  void _synchronizePartnerStatus(User user) {
    if (user.partnerUid == null || user.partnerUid!.isEmpty) {
      if (currentPartnerRelation.value != null) {
        currentPartnerRelation.value = null;
      }
    } else {
      if (currentInvitation.value != null) {
        currentInvitation.value = null; // A partner is connected, so clear any existing invitation code.
      }
    }
    update();
  }

  Future<void> createPartnerInvitationCode() async {
    if (_loginController.user.partnerUid != null && _loginController.user.partnerUid!.isNotEmpty) {
      _setError("이미 파트너와 연결되어 있어 초대 코드를 생성할 수 없습니다.", showGeneralMessageToUser: false);
      return;
    }
    _setLoading(true);
    _clearError();
    final String? baseUrl = AppConfig.apiUrl;
    final String? token = _loginController.user.safeAccessToken;

    if (baseUrl == null || token == null) {
      _setError('API URL 또는 사용자 토큰이 유효하지 않습니다.');
      _setLoading(false);
      return;
    }

    final Uri requestUri = Uri.parse('$baseUrl/api/v1/partner/invitation');

    try {
      final response = await http.post(
        requestUri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 201) {
        final responseData = json.decode(utf8.decode(response.bodyBytes));
        final invitation = PartnerInvitationResponseDto.fromJson(responseData);
        currentInvitation.value = invitation;
        currentPartnerRelation.value = null;
        Get.snackbar('성공', '파트너 초대 코드가 생성되었습니다.');
      } else {
        final responseBody = json.decode(utf8.decode(response.bodyBytes));
        _setError(responseBody['message'] ?? '초대 코드 생성 실패.', showGeneralMessageToUser: false);
      }
    } catch (e, s) {
      _setError('초대 코드 생성 중 예외 발생: $e\n$s');
    }
    _setLoading(false);
  }

  Future<void> acceptPartnerInvitation(String invitationId) async {
    if (_loginController.user.partnerUid != null && _loginController.user.partnerUid!.isNotEmpty) {
      _setError("이미 파트너와 연결되어 있어 초대를 수락할 수 없습니다.", showGeneralMessageToUser: false);
      return;
    }
    _setLoading(true);
    _clearError();
    final String? baseUrl = AppConfig.apiUrl;
    final String? token = _loginController.user.safeAccessToken;

    if (baseUrl == null || token == null) {
      _setError('API URL 또는 사용자 토큰이 유효하지 않습니다.');
      _setLoading(false);
      return;
    }

    final Uri requestUri = Uri.parse('$baseUrl/api/v1/partner/invitation/accept');
    final requestBody = PartnerInvitationAcceptRequestDto(invitationId: invitationId).toJson();

    try {
      final response = await http.post(
        requestUri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(utf8.decode(response.bodyBytes));
        final relation = PartnerRelationResponseDto.fromJson(responseData);
        currentPartnerRelation.value = relation;
        _loginController.updateUserPartnerUid(
          relation.partnerUser.userUid,
          partnerNickname: relation.partnerUser.nickname,
        );
        currentInvitation.value = null;
        Get.snackbar('성공', '파트너 초대를 수락했습니다! 이제부터 \'${relation.partnerUser.nickname ?? '파트너'}\'님과 연결됩니다.');
      } else {
        final responseBody = json.decode(utf8.decode(response.bodyBytes));
        _setError(responseBody['message'] ?? '초대 수락에 실패했습니다.', showGeneralMessageToUser: false);
      }
    } catch (e, s) {
      _setError('파트너 초대 수락 중 예외 발생: $e\n$s');
    }
    _setLoading(false);
  }

  Future<void> unfriendPartnerAndClearChat() async {
    _setLoading(true);
    _clearError();
    final String? baseUrl = AppConfig.apiUrl;
    final String? token = _loginController.user.safeAccessToken;

    if (baseUrl == null || token == null) {
      _setError('API URL 또는 사용자 토큰이 유효하지 않습니다. (파트너 해제 실패)');
      _setLoading(false);
      return;
    }

    final Uri requestUri = Uri.parse('$baseUrl/api/v1/users/me/partner');
    try {
      final response = await http.delete(
        requestUri,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 204) {
        _loginController.updateUserPartnerUid(null);
        currentPartnerRelation.value = null;
        currentInvitation.value = null;
        Get.snackbar('성공', '파트너 관계가 해제되고 대화 내역이 삭제되었습니다.');
      } else {
        final responseBody = json.decode(utf8.decode(response.bodyBytes));
        _setError(responseBody['message'] ?? '파트너 관계 해제 실패 (코드: ${response.statusCode})');
      }
    } catch (e,s) {
      _setError('파트너 관계 해제 중 예외 발생: $e\n$s');
    } finally {
      _setLoading(false);
    }
  }

  void clearPartnerStateOnLogout() {
    currentInvitation.value = null;
    currentPartnerRelation.value = null;
    _clearError();
    _setLoading(false);
  }
}