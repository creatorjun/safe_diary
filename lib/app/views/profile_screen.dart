// lib/app/views/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/profile_controller.dart';
import '../models/user.dart' show LoginPlatform;
import '../routes/app_pages.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';

class ProfileScreen extends GetView<ProfileController> {
  ProfileScreen({super.key});

  final TextEditingController _invitationCodeInputController = TextEditingController();

  // 비밀번호 필드 위젯 (재사용을 위해 분리)
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required RxBool isObscured,
    required VoidCallback toggleVisibility,
  }) {
    return Obx(
          () => TextField(
        controller: controller,
        obscureText: isObscured.value,
        style: textStyleMedium,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
          suffixIcon: IconButton(
            icon: Icon(isObscured.value ? Icons.visibility_off : Icons.visibility),
            onPressed: toggleVisibility,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필 및 계정 설정', style: textStyleLarge),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- 닉네임 및 비밀번호 변경 섹션 (통합) ---
              Text(
                '프로필 변경',
                style: textStyleLarge.copyWith(fontWeight: FontWeight.bold),
              ),
              verticalSpaceSmall,
              Card(
                elevation: 2.0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 닉네임 변경
                      TextField(
                        controller: controller.nicknameController,
                        style: textStyleMedium,
                        decoration: InputDecoration(
                          labelText: '닉네임',
                          hintText: '새 닉네임을 입력하세요',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                        ),
                      ),
                      verticalSpaceLarge,
                      // 비밀번호 변경
                      Text(
                        controller.loginController.user.isAppPasswordSet ? '앱 비밀번호 변경' : '앱 비밀번호 설정',
                        style: textStyleMedium.copyWith(fontWeight: FontWeight.w500),
                      ),
                      verticalSpaceSmall,
                      // '현재 비밀번호' 입력란 제거됨
                      _buildPasswordField(
                        controller: controller.newPasswordController,
                        labelText: '새 비밀번호',
                        hintText: '새 비밀번호 (4자 이상)',
                        isObscured: controller.isNewPasswordObscured,
                        toggleVisibility: controller.toggleNewPasswordVisibility,
                      ),
                      verticalSpaceMedium,
                      _buildPasswordField(
                        controller: controller.confirmPasswordController,
                        labelText: '새 비밀번호 확인',
                        hintText: '새 비밀번호 다시 입력',
                        isObscured: controller.isConfirmPasswordObscured,
                        toggleVisibility: controller.toggleConfirmPasswordVisibility,
                      ),
                    ],
                  ),
                ),
              ),
              verticalSpaceMedium,
              // 통합 저장 버튼
              Obx(() => FilledButton.icon(
                icon: const Icon(Icons.save_alt_rounded, size: 18),
                label: const Text('변경 내용 저장'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                  // hasChanges가 true일 때만 버튼 활성화
                  disabledBackgroundColor: Colors.grey.shade300,
                ),
                onPressed: controller.hasChanges.value ? controller.saveChanges : null,
              )),

              verticalSpaceLarge,
              const Divider(),
              verticalSpaceLarge,

              // --- 파트너 연결 섹션 ---
              Text(
                '파트너 연결',
                style: textStyleLarge.copyWith(fontWeight: FontWeight.bold),
              ),
              verticalSpaceMedium,
              _buildPartnerSection(context),

              verticalSpaceLarge,
              const Divider(),
              verticalSpaceMedium,

              // --- 로그인 정보 및 회원 탈퇴 섹션 ---
              Text(
                '계정 정보',
                style: textStyleLarge.copyWith(fontWeight: FontWeight.bold),
              ),
              verticalSpaceSmall,
              _buildAccountInfoSection(),
              verticalSpaceMedium,
              _buildAccountDeletionSection(),

              verticalSpaceLarge,
            ],
          ),
        ),
      ),
    );
  }

  // 파트너 섹션 위젯
  Widget _buildPartnerSection(BuildContext context) {
    return Obx(() {
      if (controller.partnerController.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      final user = controller.loginController.user;
      final partnerRelation = controller.partnerController.currentPartnerRelation.value;
      final invitation = controller.partnerController.currentInvitation.value;

      // 1. 파트너와 이미 연결된 경우
      if (user.partnerUid != null && user.partnerUid!.isNotEmpty) {
        String partnerNickname = user.partnerNickname ?? '파트너';
        String formattedPartnerSince = '날짜 정보 없음';
        if (partnerRelation != null) {
          try {
            formattedPartnerSince = DateFormat('yy년 MM월 dd일', 'ko_KR')
                .format(DateTime.parse(partnerRelation.partnerSince).toLocal());
          } catch (e) { /* 날짜 파싱 실패 무시 */ }
        }

        return Card(
          elevation: 2.0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('연결된 파트너: $partnerNickname', style: textStyleMedium.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                verticalSpaceSmall,
                Text('UID: ${user.partnerUid}', style: textStyleSmall.copyWith(color: Colors.grey.shade600)),
                if (formattedPartnerSince != '날짜 정보 없음')
                  Text('연결 시작일: $formattedPartnerSince', style: textStyleSmall.copyWith(color: Colors.grey.shade600)),
                verticalSpaceMedium,
                ElevatedButton.icon(
                  icon: Icon(Icons.chat_bubble_outline_rounded, size: 18, color: Theme.of(context).colorScheme.onPrimary),
                  label: Text('$partnerNickname님과 채팅하기', style: textStyleSmall.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onPrimary)),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 45),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                  ),
                  onPressed: () => Get.toNamed(Routes.chat, arguments: {'partnerUid': user.partnerUid, 'partnerNickname': partnerNickname}),
                ),
                verticalSpaceSmall,
                OutlinedButton.icon(
                  icon: Icon(Icons.link_off_rounded, size: 18, color: Colors.red.shade700),
                  label: Text('파트너 연결 끊기', style: textStyleSmall.copyWith(color: Colors.red.shade700)),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 45),
                    side: BorderSide(color: Colors.red.shade300),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                  ),
                  onPressed: controller.disconnectPartner,
                ),
              ],
            ),
          ),
        );
      }
      // 2. 생성된 초대 코드가 있는 경우
      else if (invitation != null) {
        String formattedExpiresAt = '알 수 없음';
        try {
          formattedExpiresAt = DateFormat('yy/MM/dd HH:mm', 'ko_KR')
              .format(DateTime.parse(invitation.expiresAt).toLocal());
        } catch (e) { /* 날짜 파싱 실패 무시 */ }

        return Card(
          elevation: 2.0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('생성된 파트너 초대 코드', style: textStyleMedium.copyWith(fontWeight: FontWeight.bold)),
                verticalSpaceSmall,
                TextField(
                  controller: TextEditingController(text: invitation.invitationId),
                  readOnly: true,
                  style: textStyleSmall,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.copy, size: 20),
                      tooltip: '코드 복사',
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: invitation.invitationId));
                        Get.snackbar('복사 완료', '초대 코드가 클립보드에 복사되었습니다.');
                      },
                    ),
                  ),
                ),
                verticalSpaceSmall,
                Text('만료 시간: $formattedExpiresAt', style: textStyleSmall.copyWith(color: Colors.grey.shade600)),
                verticalSpaceMedium,
                OutlinedButton(
                  style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 45), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0))),
                  onPressed: controller.generateInvitationCode,
                  child: const Text('새 코드로 다시 생성'),
                ),
              ],
            ),
          ),
        );
      }
      // 3. 파트너도 없고, 생성된 초대 코드도 없는 경우
      else {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              ),
              onPressed: controller.generateInvitationCode,
              child: Text('파트너 초대 코드 생성하기', style: textStyleMedium.copyWith(color: Colors.white)),
            ),
            verticalSpaceMedium,
            TextField(
              controller: _invitationCodeInputController,
              style: textStyleMedium,
              decoration: InputDecoration(
                hintText: '받은 초대 코드 입력',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send_rounded),
                  tooltip: '초대 수락',
                  onPressed: () {
                    final code = _invitationCodeInputController.text.trim();
                    if (code.isNotEmpty) {
                      controller.acceptInvitation(code);
                      _invitationCodeInputController.clear();
                    } else {
                      Get.snackbar('오류', '초대 코드를 입력해주세요.');
                    }
                  },
                ),
              ),
            ),
          ],
        );
      }
    });
  }

  // 계정 정보 섹션 위젯
  Widget _buildAccountInfoSection() {
    final user = controller.loginController.user;
    final formattedCreatedAt = user.formattedCreatedAt;
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: 22, height: 22,
                  child: user.platform == LoginPlatform.naver
                      ? Image(image: Svg('assets/naver_icon.svg', color: Colors.green.shade600))
                      : user.platform == LoginPlatform.kakao
                      ? const Image(image: Svg('assets/kakao_icon.svg'))
                      : Icon(Icons.device_unknown_outlined, color: Colors.grey.shade700, size: 22),
                ),
                horizontalSpaceSmall,
                Text(
                  user.platform == LoginPlatform.naver ? "네이버 로그인" : user.platform == LoginPlatform.kakao ? "카카오 로그인" : "정보 없음",
                  style: textStyleMedium.copyWith(color: Colors.grey.shade800),
                ),
              ],
            ),
            if (formattedCreatedAt.isNotEmpty) ...[
              verticalSpaceSmall,
              Align(
                alignment: Alignment.bottomRight,
                child: Text('가입일: $formattedCreatedAt', style: textStyleSmall.copyWith(color: Colors.grey.shade600)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // 회원 탈퇴 섹션 위젯
  Widget _buildAccountDeletionSection() {
    return Card(
      elevation: 1.0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: BorderSide(color: Colors.red.shade100)
      ),
      child: ListTile(
        leading: Icon(Icons.delete_forever_outlined, color: Colors.red.shade600),
        title: Text('회원 탈퇴', style: textStyleMedium.copyWith(color: Colors.red.shade700, fontWeight: FontWeight.w500)),
        trailing: Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey.shade500, size: 16),
        onTap: controller.handleAccountDeletionRequest,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      ),
    );
  }
}