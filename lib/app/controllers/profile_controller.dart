// lib/app/controllers/profile_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safe_diary/app/theme/app_spacing.dart';
import 'package:safe_diary/app/theme/app_text_styles.dart';

import '../routes/app_pages.dart';
import 'login_controller.dart';
import 'partner_controller.dart';

class ProfileController extends GetxController {
  // 생성자를 통해 의존성을 주입받습니다.
  final LoginController loginController;
  final PartnerController partnerController;

  ProfileController(this.loginController, this.partnerController);

  // 이전 화면에서 인증된 비밀번호를 저장할 변수
  String? _verifiedPassword;

  late TextEditingController nicknameController;
  final RxString _initialNickname = ''.obs;

  late TextEditingController newPasswordController;
  late TextEditingController confirmPasswordController;

  // --- 컨트롤러를 멤버 변수로 추가 ---
  late TextEditingController currentPasswordController;

  final RxBool isNewPasswordObscured = true.obs;
  final RxBool isConfirmPasswordObscured = true.obs;

  // 변경 사항이 있는지 여부를 감지하는 RxBool
  final RxBool hasChanges = false.obs;

  @override
  void onInit() {
    super.onInit();
    // arguments에서 인증된 비밀번호를 받아옵니다.
    _verifiedPassword = Get.arguments?['verifiedPassword'];

    _initialNickname.value = loginController.user.nickname ?? '';
    nicknameController = TextEditingController(text: _initialNickname.value);

    newPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();
    // --- onInit에서 컨트롤러 초기화 ---
    currentPasswordController = TextEditingController();

    // 닉네임이나 비밀번호 입력에 변경이 있을 때마다 hasChanges 값을 업데이트합니다.
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
    // --- onClose에서 컨트롤러 폐기 ---
    currentPasswordController.dispose();
    super.onClose();
  }

  void _checkForChanges() {
    final isNicknameChanged = nicknameController.text != _initialNickname.value;
    final isPasswordEntered = newPasswordController.text.isNotEmpty;
    hasChanges.value = isNicknameChanged || isPasswordEntered;
  }

  // 닉네임과 비밀번호 변경을 한번에 처리하는 통합 메서드
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

    // 비밀번호 변경 유효성 검사
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
      // 1. 닉네임 변경 처리
      if (nicknameChanged) {
        await loginController.updateUserNickname(newNickname);
        _initialNickname.value = newNickname; // 초기 닉네임 값 업데이트
      }

      // 2. 비밀번호 변경 처리
      if (passwordChanged) {
        // isAppPasswordSet 값에 따라 현재 비밀번호를 전달할지 결정
        final currentPwd =
            loginController.user.isAppPasswordSet ? _verifiedPassword : null;
        final success = await loginController.setAppPasswordOnServer(
          currentPwd,
          newPassword,
        );

        // 비밀번호 변경 성공 시, 인증된 비밀번호를 새 비밀번호로 업데이트
        if (success) {
          _verifiedPassword = newPassword;
        }
      }

      Get.back(); // 로딩 다이얼로그 닫기
      Get.snackbar('성공', '변경 내용이 성공적으로 저장되었습니다.');

      // 저장 후 컨트롤러 상태 초기화
      newPasswordController.clear();
      confirmPasswordController.clear();
      _checkForChanges();
    } catch (e) {
      Get.back(); // 로딩 다이얼로그 닫기
      Get.snackbar('오류', '변경 내용 저장에 실패했습니다: ${e.toString()}');
    }
  }

  /// 비밀번호 해제를 위해 현재 비밀번호 입력을 요청하는 다이얼로그 표시
  void promptForPasswordAndRemove() {
    // --- 멤버 변수로 변경된 컨트롤러를 사용하기 전에 초기화 ---
    currentPasswordController.clear();

    Get.dialog(
      AlertDialog(
        title: const Text('비밀번호 해제'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('비밀번호를 해제하려면 현재 비밀번호를 입력해주세요.'),
            verticalSpaceMedium,
            TextField(
              // --- 지역 변수 대신 멤버 변수 사용 ---
              controller: currentPasswordController,
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
                  currentPasswordController.text.trim();
              if (currentPassword.isEmpty) {
                Get.snackbar('오류', '현재 비밀번호를 입력해주세요.');
                return;
              }

              Get.back(); // 입력 다이얼로그 닫기
              final success = await loginController.removeAppPasswordOnServer(
                currentPassword,
              );

              // 비밀번호가 성공적으로 해제되면, 인증 화면으로 돌아가서
              // 다음 번 프로필 접근 시 비밀번호를 묻지 않도록 합니다.
              if (success) {
                Get.offNamedUntil(Routes.home, (route) => route.isFirst);
                Get.toNamed(Routes.profileAuth);
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
                            color:
                                Get.isDarkMode
                                    ? Colors.grey.shade600
                                    : Colors.grey.shade400,
                          ),
                        ),
                        child: Text(
                          '취소',
                          style: textStyleMedium.copyWith(
                            color:
                                Get.isDarkMode
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

  Future<void> generateInvitationCode() async {
    await partnerController.createPartnerInvitationCode();
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
}
