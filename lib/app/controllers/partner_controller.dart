// lib/app/controllers/partner_controller.dart

import 'package:get/get.dart';
import 'package:safe_diary/app/services/api_service.dart';

import '../models/partner_dtos.dart';
import '../models/user.dart';
import 'error_controller.dart';
import 'login_controller.dart';

class PartnerController extends GetxController {
  final LoginController _loginController;
  final ApiService _apiService;

  PartnerController(this._loginController, this._apiService);

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

    try {
      final invitation = await _apiService.post<PartnerInvitationResponseDto>(
        '/api/v1/partner/invitation',
        parser: (data) =>
            PartnerInvitationResponseDto.fromJson(data as Map<String, dynamic>),
      );
      currentInvitation.value = invitation;
      currentPartnerRelation.value = null;
      Get.snackbar('성공', '파트너 초대 코드가 생성되었습니다.');
    } catch (e) {
      _handleError(e, userFriendlyMessage: '초대 코드 생성 중 오류가 발생했습니다.');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> acceptPartnerInvitation(String invitationId) async {
    if (_loginController.user.partnerUid != null &&
        _loginController.user.partnerUid!.isNotEmpty) {
      _handleError("이미 파트너와 연결되어 있어 초대를 수락할 수 없습니다.");
      return;
    }
    _setLoading(true);

    final requestBody =
    PartnerInvitationAcceptRequestDto(invitationId: invitationId).toJson();

    try {
      final relation = await _apiService.post<PartnerRelationResponseDto>(
        '/api/v1/partner/invitation/accept',
        body: requestBody,
        parser: (data) =>
            PartnerRelationResponseDto.fromJson(data as Map<String, dynamic>),
      );

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
    } catch (e) {
      _handleError(e, userFriendlyMessage: '파트너 초대 수락 중 오류가 발생했습니다.');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> unfriendPartnerAndClearChat() async {
    _setLoading(true);
    try {
      await _apiService.delete<void>('/api/v1/users/me/partner');

      _loginController.updateUserPartnerUid(null);
      currentPartnerRelation.value = null;
      currentInvitation.value = null;
      Get.snackbar('성공', '파트너 관계가 해제되고 대화 내역이 삭제되었습니다.');
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