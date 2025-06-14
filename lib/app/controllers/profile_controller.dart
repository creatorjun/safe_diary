import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:safe_diary/app/theme/app_theme.dart';

import '../routes/app_pages.dart';
import 'error_controller.dart';
import 'login_controller.dart';
import 'partner_controller.dart';

class ProfileController extends GetxController {
  final LoginController loginController;
  final PartnerController partnerController;

  ProfileController(this.loginController, this.partnerController);

  ErrorController get _errorController => Get.find<ErrorController>();

  String? _verifiedPassword;

  final RxString initialNickname = ''.obs;
  final RxBool hasChanges = false.obs;
  final RxBool isNewPasswordObscured = true.obs;
  final RxBool isConfirmPasswordObscured = true.obs;

  @override
  void onInit() {
    super.onInit();
    _verifiedPassword = Get.arguments?['verifiedPassword'];
    initialNickname.value = loginController.user.nickname ?? '';
  }

  void checkForChanges(String currentNickname, String newPassword) {
    final isNicknameChanged = currentNickname != initialNickname.value;
    final isPasswordEntered = newPassword.isNotEmpty;
    hasChanges.value = isNicknameChanged || isPasswordEntered;
  }

  Future<void> saveChanges({
    required String newNickname,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final isNicknameChanged =
        newNickname.isNotEmpty && newNickname != initialNickname.value;
    final isPasswordChanged = newPassword.isNotEmpty;

    if (!isNicknameChanged && !isPasswordChanged) {
      Get.snackbar('알림', '변경된 내용이 없습니다.');
      return;
    }

    if (isPasswordChanged) {
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
      if (isNicknameChanged) {
        await loginController.updateUserNickname(newNickname);
        initialNickname.value = newNickname;
      }

      if (isPasswordChanged) {
        final currentPwd =
        loginController.user.isAppPasswordSet ? _verifiedPassword : null;
        final bool success = await loginController.setOrUpdateAppPassword(
          currentAppPassword: currentPwd,
          newAppPassword: newPassword,
        );

        if (success) {
          _verifiedPassword = newPassword;
        }
      }

      Get.back();
      Get.snackbar('성공', '변경 내용이 성공적으로 저장되었습니다.');
      hasChanges.value = false;
    } catch (e) {
      Get.back();
      _errorController.handleError(e, userFriendlyMessage: '변경 내용 저장에 실패했습니다.');
    }
  }

  void promptForPasswordAndRemove() {
    final BuildContext context = Get.context!;
    final ThemeData theme = Theme.of(context);
    final AppSpacing spacing = theme.extension<AppSpacing>()!;
    final TextEditingController dialogPasswordController =
    TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('비밀번호 해제'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('비밀번호를 해제하려면 현재 비밀번호를 입력해주세요.'),
            SizedBox(height: spacing.medium),
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
          TextButton(child: const Text('취소'), onPressed: () => Get.back()),
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

              final bool success = await loginController.removeAppPassword(
                currentPassword,
              );

              if (success) {
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
    final BuildContext context = Get.context!;
    final ThemeData theme = Theme.of(context);
    final AppTextStyles textStyles = theme.extension<AppTextStyles>()!;
    final AppSpacing spacing = theme.extension<AppSpacing>()!;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: theme.cardColor,
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
                  style: textStyles.titleMedium,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: spacing.medium),
                Text(
                  '회원 탈퇴 즉시 사용자의 모든 정보가 파기되며 복구할 수 없습니다. 정말로 탈퇴하시겠습니까?',
                  style: textStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: spacing.large),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(
                              color: theme.colorScheme.outline.withAlpha(128)),
                        ),
                        child: Text('취소'),
                      ),
                    ),
                    SizedBox(width: spacing.medium),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Get.back();
                          await loginController.processAccountDeletion();
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: theme.colorScheme.error,
                          foregroundColor: theme.colorScheme.onError,
                        ),
                        child: Text('탈퇴 진행'),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: spacing.small),
              ],
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Future<void> acceptInvitation(String code) async {
    if (code.isNotEmpty) {
      await partnerController.acceptPartnerInvitation(code);
    } else {
      Get.snackbar('오류', '초대 코드를 입력해주세요.');
    }
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
            child: Text("연결 끊기",
                style: TextStyle(color: Theme.of(Get.context!).colorScheme.error)),
          ),
        ],
      ),
    );
  }

  Future<void> generateInvitationCode() async {
    await partnerController.createPartnerInvitationCode();
  }
}