// lib/app/controllers/partner_controller.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/partner_dtos.dart';
import '../models/user.dart';
import 'error_controller.dart';
import 'login_controller.dart';

class PartnerController extends GetxController {
  final LoginController _loginController;

  PartnerController(this._loginController);

  ErrorController get _errorController => Get.find<ErrorController>();

  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  final Rx<PartnerInvitationResponseDto?> currentInvitation =
  Rx<PartnerInvitationResponseDto?>(null);
  final Rx<PartnerRelationResponseDto?> currentPartnerRelation =
  Rx<PartnerRelationResponseDto?>(null);

  void _setLoading(bool loading) {
    _isLoading.value = loading;
  }

  void _handleError(Object error, {String? userFriendlyMessage}) {
    _errorController.handleError(
      error,
      userFriendlyMessage: userFriendlyMessage ?? "파트너 관련 작업 중 오류가 발생했습니다.",
    );
  }

  @override
  void onInit() {
    super.onInit();
    ever(_loginController.userState, (User user) {
      _synchronizePartnerStatus(user);
    });
    _synchronizePartnerStatus(_loginController.user);
  }

  void _synchronizePartnerStatus(User user) {
    if (user.partnerUid == null || user.partnerUid!.isEmpty) {
      if (currentPartnerRelation.value != null) {
        currentPartnerRelation.value = null;
      }
    } else {
      if (currentInvitation.value != null) {
        currentInvitation.value = null;
      }
    }
    update();
  }

  Future<void> createPartnerInvitationCode() async {
    if (_loginController.user.partnerUid != null &&
        _loginController.user.partnerUid!.isNotEmpty) {
      _handleError("이미 파트너와 연결되어 있어 초대 코드를 생성할 수 없습니다.");
      return;
    }
    _setLoading(true);
    final String? baseUrl = AppConfig.apiUrl;
    final String? token = _loginController.user.safeAccessToken;

    if (baseUrl == null || token == null) {
      _handleError('API URL 또는 사용자 토큰이 유효하지 않습니다.');
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
        _handleError(
          responseBody['message'] ?? '초대 코드 생성에 실패했습니다.',
          userFriendlyMessage: responseBody['message'],
        );
      }
    } catch (e) {
      _handleError(e, userFriendlyMessage: '초대 코드 생성 중 오류가 발생했습니다.');
    }
    _setLoading(false);
  }

  Future<void> acceptPartnerInvitation(String invitationId) async {
    if (_loginController.user.partnerUid != null &&
        _loginController.user.partnerUid!.isNotEmpty) {
      _handleError("이미 파트너와 연결되어 있어 초대를 수락할 수 없습니다.");
      return;
    }
    _setLoading(true);
    final String? baseUrl = AppConfig.apiUrl;
    final String? token = _loginController.user.safeAccessToken;

    if (baseUrl == null || token == null) {
      _handleError('API URL 또는 사용자 토큰이 유효하지 않습니다.');
      _setLoading(false);
      return;
    }

    final Uri requestUri = Uri.parse(
      '$baseUrl/api/v1/partner/invitation/accept',
    );
    final requestBody =
    PartnerInvitationAcceptRequestDto(invitationId: invitationId).toJson();

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
        Get.snackbar(
          '성공',
          '파트너 초대를 수락했습니다! 이제부터 \'${relation.partnerUser.nickname ?? '파트너'}\'님과 연결됩니다.',
        );
      } else {
        final responseBody = json.decode(utf8.decode(response.bodyBytes));
        _handleError(
          responseBody['message'] ?? '초대 수락에 실패했습니다.',
          userFriendlyMessage: responseBody['message'],
        );
      }
    } catch (e) {
      _handleError(e, userFriendlyMessage: '파트너 초대 수락 중 오류가 발생했습니다.');
    }
    _setLoading(false);
  }

  Future<void> unfriendPartnerAndClearChat() async {
    _setLoading(true);
    final String? baseUrl = AppConfig.apiUrl;
    final String? token = _loginController.user.safeAccessToken;

    if (baseUrl == null || token == null) {
      _handleError('API URL 또는 사용자 토큰이 유효하지 않습니다.',
          userFriendlyMessage: '파트너 연결 해제에 실패했습니다.');
      _setLoading(false);
      return;
    }

    final Uri requestUri = Uri.parse('$baseUrl/api/v1/users/me/partner');
    try {
      final response = await http.delete(
        requestUri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 204) {
        _loginController.updateUserPartnerUid(null);
        currentPartnerRelation.value = null;
        currentInvitation.value = null;
        Get.snackbar('성공', '파트너 관계가 해제되고 대화 내역이 삭제되었습니다.');
      } else {
        final responseBody = json.decode(utf8.decode(response.bodyBytes));
        _handleError(
          responseBody['message'] ?? '파트너 관계 해제에 실패했습니다.',
          userFriendlyMessage: responseBody['message'],
        );
      }
    } catch (e) {
      _handleError(e, userFriendlyMessage: '파트너 관계 해제 중 오류가 발생했습니다.');
    } finally {
      _setLoading(false);
    }
  }

  void clearPartnerStateOnLogout() {
    currentInvitation.value = null;
    currentPartnerRelation.value = null;
    _setLoading(false);
  }
}