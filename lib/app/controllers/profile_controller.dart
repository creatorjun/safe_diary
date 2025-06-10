import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart'; // WidgetsBinding을 사용하기 위해 import
import 'package:get/get.dart';
import 'package:safe_diary/app/theme/app_spacing.dart';
import 'package:safe_diary/app/theme/app_text_styles.dart';

import '../routes/app_pages.dart';
import 'login_controller.dart';
import 'partner_controller.dart';

class ProfileController extends GetxController {
  final LoginController loginController;
  final PartnerController partnerController;

  ProfileController(this.loginController, this.partnerController);

  String? _verifiedPassword;

  late TextEditingController nicknameController;
  final RxString _initialNickname = ''.obs;

  late TextEditingController newPasswordController;
  late TextEditingController confirmPasswordController;
  late TextEditingController invitationCodeInputController;

  final RxBool isNewPasswordObscured = true.obs;
  final RxBool isConfirmPasswordObscured = true.obs;

  final RxBool hasChanges = false.obs;

  @override
  void onInit() {
    super.onInit();
    _verifiedPassword = Get.arguments?['verifiedPassword'];

    _initialNickname.value = loginController.user.nickname ?? '';
    nicknameController = TextEditingController(text: _initialNickname.value);

    newPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();
    invitationCodeInputController = TextEditingController();

    nicknameController.addListener(_checkForChanges);
    newPasswordController.addListener(_checkForChanges);
    confirmPasswordController.addListener(_checkForChanges);
  }

  @override
  void onClose() {
    nicknameController.removeListener(_checkForChanges);
    newPasswordController.removeListener(_checkForChanges);
    confirmPasswordController.removeListener(_checkForChanges);

    nicknameController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    invitationCodeInputController.dispose();
    super.onClose();
  }

  void _checkForChanges() {
    final isNicknameChanged = nicknameController.text != _initialNickname.value;
    final isPasswordEntered = newPasswordController.text.isNotEmpty;
    hasChanges.value = isNicknameChanged || isPasswordEntered;
  }

  Future<void> saveChanges() async {
    final newNickname = nicknameController.text.trim();
    final newPassword = newPasswordController.text;
    final confirmPassword = confirmPasswordController.text;

    bool nicknameChanged =
        newNickname.isNotEmpty && newNickname != _initialNickname.value;
    bool passwordChanged = newPassword.isNotEmpty;

    if (!nicknameChanged && !passwordChanged) {
      Get.snackbar('알림', '변경된 내용이 없습니다.');
      return;
    }

    if (passwordChanged) {
      if (newPassword.length < 4) {
        Get.snackbar('오류', '새 비밀번호는 4자 이상이어야 합니다.');
        return;
      }
      if (newPassword != confirmPassword) {
        Get.snackbar('오류', '새 비밀번호와 확인 비밀번호가 일치하지 않습니다.');
        return;
      }
    }

    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      if (nicknameChanged) {
        await loginController.updateUserNickname(newNickname);
        _initialNickname.value = newNickname;
      }

      if (passwordChanged) {
        final currentPwd =
        loginController.user.isAppPasswordSet ? _verifiedPassword : null;
        final success = await loginController.setAppPasswordOnServer(
          currentPwd,
          newPassword,
        );

        if (success) {
          _verifiedPassword = newPassword;
        }
      }

      Get.back();
      Get.snackbar('성공', '변경 내용이 성공적으로 저장되었습니다.');

      newPasswordController.clear();
      confirmPasswordController.clear();
      _checkForChanges();
    } catch (e) {
      Get.back();
      Get.snackbar('오류', '변경 내용 저장에 실패했습니다: ${e.toString()}');
    }
  }

  void promptForPasswordAndRemove() {
    final TextEditingController dialogPasswordController =
    TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('비밀번호 해제'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('비밀번호를 해제하려면 현재 비밀번호를 입력해주세요.'),
            verticalSpaceMedium,
            TextField(
              controller: dialogPasswordController,
              obscureText: true,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: '현재 비밀번호',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('취소'),
            onPressed: () => Get.back(),
          ),
          FilledButton(
            child: const Text('해제'),
            onPressed: () async {
              final String currentPassword =
              dialogPasswordController.text.trim();

              Get.back();

              if (currentPassword.isEmpty) {
                Get.snackbar('오류', '현재 비밀번호를 입력해주세요.');
                return;
              }

              final success = await loginController.removeAppPasswordOnServer(
                currentPassword,
              );

              if (success) {
                // 현재 프레임이 모두 렌더링 된 후, 다음 프레임에서 내비게이션 실행
                SchedulerBinding.instance.addPostFrameCallback((_) {
                  Get.offNamedUntil(Routes.home, (route) => route.isFirst);
                  Get.toNamed(Routes.profileAuth);
                });
              }
            },
          ),
        ],
      ),
    );
  }

  void toggleNewPasswordVisibility() =>
      isNewPasswordObscured.value = !isNewPasswordObscured.value;

  void toggleConfirmPasswordVisibility() =>
      isConfirmPasswordObscured.value = !isConfirmPasswordObscured.value;

  void handleAccountDeletionRequest() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Get.isDarkMode ? Colors.grey[800] : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
        ),
        child: Wrap(
          children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '회원 탈퇴',
                  style: textStyleLarge.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                verticalSpaceMedium,
                Text(
                  '회원 탈퇴 즉시 사용자의 모든 정보가 파기되며 복구할 수 없습니다. 정말로 탈퇴하시겠습니까?',
                  style: textStyleMedium,
                  textAlign: TextAlign.center,
                ),
                verticalSpaceLarge,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(
                            color: Get.isDarkMode
                                ? Colors.grey.shade600
                                : Colors.grey.shade400,
                          ),
                        ),
                        child: Text(
                          '취소',
                          style: textStyleMedium.copyWith(
                            color: Get.isDarkMode
                                ? Colors.white70
                                : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    horizontalSpaceMedium,
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Get.back();
                          await loginController.processAccountDeletion();
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Colors.red.shade600,
                        ),
                        child: Text(
                          '탈퇴 진행',
                          style: textStyleMedium.copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                verticalSpaceSmall,
              ],
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Future<void> acceptInvitation(String code) async {
    await partnerController.acceptPartnerInvitation(code);
  }

  Future<void> disconnectPartner() async {
    Get.dialog(
      AlertDialog(
        title: const Text("파트너 연결 끊기"),
        content: const Text(
          "파트너와의 연결을 끊고 모든 대화 내역을 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.",
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("취소")),
          TextButton(
            onPressed: () async {
              Get.back();
              await partnerController.unfriendPartnerAndClearChat();
            },
            child: const Text("연결 끊기", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> generateInvitationCode() async {
    await partnerController.createPartnerInvitationCode();
  }
}