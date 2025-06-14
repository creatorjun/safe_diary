// lib/app/controllers/profile_controller.dart

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:safe_diary/app/theme/app_theme.dart';
import 'package:safe_diary/app/utils/app_strings.dart';

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
      Get.snackbar(AppStrings.notification, AppStrings.noChanges);
      return;
    }

    if (isPasswordChanged) {
      if (newPassword.length < 4) {
        Get.snackbar(AppStrings.error, AppStrings.newPasswordMinLengthError);
        return;
      }
      if (newPassword != confirmPassword) {
        Get.snackbar(AppStrings.error, AppStrings.newPasswordMismatchError);
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
      Get.snackbar(AppStrings.success, AppStrings.saveSuccess);
      hasChanges.value = false;
    } catch (e) {
      Get.back();
      _errorController.handleError(
        e,
        userFriendlyMessage: AppStrings.saveFailed,
      );
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
        title: const Text(AppStrings.removePasswordPromptTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(AppStrings.removePasswordPromptContent),
            SizedBox(height: spacing.medium),
            TextField(
              controller: dialogPasswordController,
              obscureText: true,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: AppStrings.currentPassword,
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text(AppStrings.cancel),
            onPressed: () => Get.back(),
          ),
          FilledButton(
            child: const Text(AppStrings.removeAppPassword),
            onPressed: () async {
              final String currentPassword =
                  dialogPasswordController.text.trim();

              Get.back();

              if (currentPassword.isEmpty) {
                Get.snackbar(
                  AppStrings.error,
                  AppStrings.currentPasswordRequired,
                );
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
                  AppStrings.accountDeletion,
                  style: textStyles.titleMedium,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: spacing.medium),
                Text(
                  AppStrings.accountDeletionConfirmationContent,
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
                            color: theme.colorScheme.outline.withAlpha(128),
                          ),
                        ),
                        child: const Text(AppStrings.cancel),
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
                        child: const Text(AppStrings.proceedWithDeletion),
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
      Get.snackbar(AppStrings.error, AppStrings.invitationCodeRequired);
    }
  }

  Future<void> disconnectPartner() async {
    Get.dialog(
      AlertDialog(
        title: const Text(AppStrings.unfriendConfirmationTitle),
        content: const Text(AppStrings.unfriendConfirmationContent),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await partnerController.unfriendPartnerAndClearChat();
            },
            child: Text(
              AppStrings.unfriendButton,
              style: TextStyle(color: Theme.of(Get.context!).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> generateInvitationCode() async {
    await partnerController.createPartnerInvitationCode();
  }
}
