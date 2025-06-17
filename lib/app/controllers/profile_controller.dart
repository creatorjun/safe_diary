import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:safe_diary/app/services/dialog_service.dart';
import 'package:safe_diary/app/theme/app_theme.dart';
import 'package:safe_diary/app/utils/app_strings.dart';

import '../routes/app_pages.dart';
import 'error_controller.dart';
import 'login_controller.dart';
import 'partner_controller.dart';

class ProfileController extends GetxController {
  final LoginController loginController;
  final PartnerController partnerController;
  final DialogService _dialogService;

  ProfileController(
      this.loginController,
      this.partnerController,
      this._dialogService,
      );

  ErrorController get _errorController => Get.find<ErrorController>();

  String? _verifiedPassword;

  late final TextEditingController nicknameController;
  late final TextEditingController newPasswordController;
  late final TextEditingController confirmPasswordController;
  late final TextEditingController invitationCodeInputController;

  final RxString initialNickname = ''.obs;
  final RxBool hasChanges = false.obs;
  final RxBool isNewPasswordObscured = true.obs;
  final RxBool isConfirmPasswordObscured = true.obs;

  @override
  void onInit() {
    super.onInit();
    _verifiedPassword = Get.arguments?['verifiedPassword'];
    initialNickname.value = loginController.user.nickname ?? '';

    nicknameController = TextEditingController(text: initialNickname.value);
    newPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();
    invitationCodeInputController = TextEditingController();

    nicknameController.addListener(_onChanged);
    newPasswordController.addListener(_onChanged);
  }

  @override
  void onClose() {
    nicknameController.removeListener(_onChanged);
    newPasswordController.removeListener(_onChanged);

    nicknameController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    invitationCodeInputController.dispose();
    super.onClose();
  }

  void _onChanged() {
    checkForChanges(
      nicknameController.text,
      newPasswordController.text,
    );
  }

  void checkForChanges(String currentNickname, String newPassword) {
    final isNicknameChanged = currentNickname != initialNickname.value;
    final isPasswordEntered = newPassword.isNotEmpty;
    hasChanges.value = isNicknameChanged || isPasswordEntered;
  }

  Future<void> saveChanges() async {
    final newNickname = nicknameController.text;
    final newPassword = newPasswordController.text;
    final confirmPassword = confirmPasswordController.text;

    final isNicknameChanged =
        newNickname.isNotEmpty && newNickname != initialNickname.value;
    final isPasswordChanged = newPassword.isNotEmpty;

    if (!isNicknameChanged && !isPasswordChanged) {
      _dialogService.showSnackbar(
        AppStrings.notification,
        AppStrings.noChanges,
      );
      return;
    }

    if (isPasswordChanged) {
      if (newPassword.length < 4) {
        _dialogService.showSnackbar(
          AppStrings.error,
          AppStrings.newPasswordMinLengthError,
        );
        return;
      }
      if (newPassword != confirmPassword) {
        _dialogService.showSnackbar(
          AppStrings.error,
          AppStrings.newPasswordMismatchError,
        );
        return;
      }
    }

    _dialogService.showLoading();

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

      _dialogService.hideLoading();
      _dialogService.showSnackbar(AppStrings.success, AppStrings.saveSuccess);
      hasChanges.value = false;
      newPasswordController.clear();
      confirmPasswordController.clear();
    } catch (e) {
      _dialogService.hideLoading();
      _errorController.handleError(
        e,
        userFriendlyMessage: AppStrings.saveFailed,
      );
    }
  }

  void promptForPasswordAndRemove() {
    final TextEditingController dialogPasswordController =
    TextEditingController();

    _dialogService.showConfirmDialog(
      title: AppStrings.removePasswordPromptTitle,
      content: AppStrings.removePasswordPromptContent,
      confirmText: AppStrings.removeAppPassword,
      customContent: TextField(
        controller: dialogPasswordController,
        obscureText: true,
        autofocus: true,
        decoration: const InputDecoration(
          labelText: AppStrings.currentPassword,
          border: OutlineInputBorder(),
        ),
      ),
      onConfirm: () async {
        final String currentPassword = dialogPasswordController.text.trim();
        dialogPasswordController.dispose();

        if (currentPassword.isEmpty) {
          _dialogService.showSnackbar(
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

    _dialogService.showCustomBottomSheet(
      child: Container(
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
    );
  }

  Future<void> acceptInvitation(String code) async {
    if (code.isNotEmpty) {
      await partnerController.acceptPartnerInvitation(code);
    } else {
      _dialogService.showSnackbar(
        AppStrings.error,
        AppStrings.invitationCodeRequired,
      );
    }
  }

  Future<void> disconnectPartner() async {
    _dialogService.showConfirmDialog(
      title: AppStrings.unfriendConfirmationTitle,
      content: AppStrings.unfriendConfirmationContent,
      confirmText: AppStrings.unfriendButton,
      onConfirm: () async {
        await partnerController.unfriendPartnerAndClearChat();
      },
    );
  }

  Future<void> generateInvitationCode() async {
    await partnerController.createPartnerInvitationCode();
  }
}