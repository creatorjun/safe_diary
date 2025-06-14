// lib/app/views/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:safe_diary/app/utils/app_strings.dart';

import '../controllers/profile_controller.dart';
import '../models/user.dart' show LoginPlatform;
import '../routes/app_pages.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileController controller = Get.find<ProfileController>();

  late final TextEditingController _nicknameController;
  late final TextEditingController _newPasswordController;
  late final TextEditingController _confirmPasswordController;
  late final TextEditingController _invitationCodeInputController;

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController(
      text: controller.initialNickname.value,
    );
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _invitationCodeInputController = TextEditingController();

    _nicknameController.addListener(_onChanged);
    _newPasswordController.addListener(_onChanged);
  }

  @override
  void dispose() {
    _nicknameController.removeListener(_onChanged);
    _newPasswordController.removeListener(_onChanged);

    _nicknameController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _invitationCodeInputController.dispose();
    super.dispose();
  }

  void _onChanged() {
    controller.checkForChanges(
      _nicknameController.text,
      _newPasswordController.text,
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required RxBool isObscured,
    required VoidCallback toggleVisibility,
  }) {
    final AppTextStyles textStyles =
        Theme.of(context).extension<AppTextStyles>()!;
    return Obx(
      () => TextField(
        controller: controller,
        obscureText: isObscured.value,
        style: textStyles.bodyLarge,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          suffixIcon: IconButton(
            icon: Icon(
              isObscured.value ? Icons.visibility_off : Icons.visibility,
            ),
            onPressed: toggleVisibility,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final AppTextStyles textStyles = theme.extension<AppTextStyles>()!;
    final AppSpacing spacing = theme.extension<AppSpacing>()!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.profileAndSettings,
          style: textStyles.titleMedium,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(spacing.medium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(AppStrings.editProfile, style: textStyles.titleLarge),
              SizedBox(height: spacing.small),
              Padding(
                padding: EdgeInsets.symmetric(vertical: spacing.medium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _nicknameController,
                      style: textStyles.bodyLarge,
                      decoration: const InputDecoration(
                        labelText: AppStrings.nickname,
                        hintText: AppStrings.newNicknameHint,
                      ),
                    ),
                    SizedBox(height: spacing.large),
                    Text(
                      controller.loginController.user.isAppPasswordSet
                          ? AppStrings.changeAppPassword
                          : AppStrings.setAppPassword,
                      style: textStyles.bodyLarge,
                    ),
                    SizedBox(height: spacing.small),
                    _buildPasswordField(
                      controller: _newPasswordController,
                      labelText: AppStrings.newPassword,
                      hintText: AppStrings.newPasswordHint,
                      isObscured: controller.isNewPasswordObscured,
                      toggleVisibility: controller.toggleNewPasswordVisibility,
                    ),
                    SizedBox(height: spacing.medium),
                    _buildPasswordField(
                      controller: _confirmPasswordController,
                      labelText: AppStrings.newPasswordConfirm,
                      hintText: AppStrings.newPasswordConfirmHint,
                      isObscured: controller.isConfirmPasswordObscured,
                      toggleVisibility:
                          controller.toggleConfirmPasswordVisibility,
                    ),
                  ],
                ),
              ),
              SizedBox(height: spacing.small),
              Obx(
                () => FilledButton.icon(
                  icon: const Icon(Icons.save_outlined, size: 18),
                  label: Text(
                    AppStrings.saveChanges,
                    style: textStyles.labelLarge,
                  ),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed:
                      controller.hasChanges.value
                          ? () {
                            controller
                                .saveChanges(
                                  newNickname: _nicknameController.text,
                                  newPassword: _newPasswordController.text,
                                  confirmPassword:
                                      _confirmPasswordController.text,
                                )
                                .then((_) {
                                  _newPasswordController.clear();
                                  _confirmPasswordController.clear();
                                });
                          }
                          : null,
                ),
              ),
              Obx(() {
                if (controller.loginController.user.isAppPasswordSet) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: OutlinedButton.icon(
                      icon: Icon(
                        Icons.lock_open_outlined,
                        color: colorScheme.error,
                      ),
                      label: Text(
                        AppStrings.removeAppPassword,
                        style: textStyles.bodyLarge.copyWith(
                          color: colorScheme.error,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        side: BorderSide(
                          color: colorScheme.error.withAlpha(80),
                        ),
                      ),
                      onPressed: controller.promptForPasswordAndRemove,
                    ),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              }),
              SizedBox(height: spacing.large),
              const Divider(),
              SizedBox(height: spacing.large),
              Text(AppStrings.partnerConnection, style: textStyles.titleLarge),
              SizedBox(height: spacing.medium),
              _buildPartnerSection(context),
              SizedBox(height: spacing.large),
              const Divider(),
              SizedBox(height: spacing.medium),
              Text(AppStrings.accountInfo, style: textStyles.titleLarge),
              SizedBox(height: spacing.small),
              _buildAccountInfoSection(),
              SizedBox(height: spacing.medium),
              _buildAccountDeletionSection(),
              SizedBox(height: spacing.large),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPartnerSection(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final AppTextStyles textStyles = theme.extension<AppTextStyles>()!;
    final AppSpacing spacing = theme.extension<AppSpacing>()!;

    return Obx(() {
      if (controller.partnerController.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      final user = controller.loginController.user;
      final partnerRelation =
          controller.partnerController.currentPartnerRelation.value;
      final invitation = controller.partnerController.currentInvitation.value;

      if (user.partnerUid != null && user.partnerUid!.isNotEmpty) {
        String partnerNickname =
            user.partnerNickname ?? AppStrings.defaultPartner;
        String formattedPartnerSince = AppStrings.noDateInfo;
        if (partnerRelation != null) {
          try {
            formattedPartnerSince = DateFormat(
              'yy년 MM월 dd일',
              'ko_KR',
            ).format(DateTime.parse(partnerRelation.partnerSince).toLocal());
          } catch (e) {
            /* 날짜 파싱 실패 무시 */
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.connectedPartner(partnerNickname),
              style: textStyles.bodyLarge.copyWith(color: colorScheme.primary),
            ),
            SizedBox(height: spacing.small),
            if (formattedPartnerSince != AppStrings.noDateInfo)
              Text(
                AppStrings.partnerSince(formattedPartnerSince),
                style: textStyles.bodyMedium.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            SizedBox(height: spacing.medium),
            FilledButton.icon(
              icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
              label: Text(
                AppStrings.chatWithPartner(partnerNickname),
                style: textStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 45),
              ),
              onPressed:
                  () => Get.toNamed(
                    Routes.chat,
                    arguments: {
                      'partnerUid': user.partnerUid,
                      'partnerNickname': partnerNickname,
                    },
                  ),
            ),
            SizedBox(height: spacing.small),
            OutlinedButton.icon(
              icon: Icon(
                Icons.link_off_rounded,
                size: 18,
                color: colorScheme.error,
              ),
              label: Text(
                AppStrings.unfriendButton,
                style: textStyles.bodyMedium.copyWith(color: colorScheme.error),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 45),
                side: BorderSide(color: colorScheme.error.withAlpha(80)),
              ),
              onPressed: controller.disconnectPartner,
            ),
          ],
        );
      } else if (invitation != null) {
        String formattedExpiresAt = AppStrings.unknown;
        try {
          formattedExpiresAt = DateFormat(
            'yy/MM/dd HH:mm',
            'ko_KR',
          ).format(DateTime.parse(invitation.expiresAt).toLocal());
        } catch (e) {
          /* 날짜 파싱 실패 무시 */
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.generatedInvitationCode,
              style: textStyles.bodyLarge,
            ),
            SizedBox(height: spacing.small),
            TextField(
              controller: TextEditingController(text: invitation.invitationId),
              readOnly: true,
              style: textStyles.bodyMedium,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.copy, size: 20),
                  tooltip: AppStrings.copyCode,
                  onPressed: () {
                    Clipboard.setData(
                      ClipboardData(text: invitation.invitationId),
                    );
                    Get.snackbar(
                      AppStrings.success,
                      AppStrings.copyCodeSuccess,
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: spacing.small),
            Text(
              AppStrings.expiresAt(formattedExpiresAt),
              style: textStyles.bodyMedium.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: spacing.medium),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 45),
              ),
              onPressed: controller.generateInvitationCode,
              child: const Text(AppStrings.generateNewCode),
            ),
          ],
        );
      } else {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: colorScheme.secondary,
                foregroundColor: colorScheme.onSecondary,
              ),
              onPressed: controller.generateInvitationCode,
              child: Text(
                AppStrings.createInvitationCode,
                style: textStyles.labelLarge,
              ),
            ),
            SizedBox(height: spacing.medium),
            TextField(
              controller: _invitationCodeInputController,
              style: textStyles.bodyLarge,
              decoration: InputDecoration(
                hintText: AppStrings.enterInvitationCode,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send_rounded),
                  tooltip: AppStrings.acceptInvitation,
                  onPressed: () {
                    final code = _invitationCodeInputController.text.trim();
                    controller.acceptInvitation(code);
                  },
                ),
              ),
            ),
          ],
        );
      }
    });
  }

  Widget _buildAccountInfoSection() {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final AppTextStyles textStyles = theme.extension<AppTextStyles>()!;
    final AppSpacing spacing = theme.extension<AppSpacing>()!;

    final user = controller.loginController.user;
    final formattedCreatedAt = user.formattedCreatedAt;

    return Card(
      elevation: 2.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: 22,
                  height: 22,
                  child:
                      user.platform == LoginPlatform.naver
                          ? const Image(image: Svg('assets/naver_icon.svg'))
                          : user.platform == LoginPlatform.kakao
                          ? const Image(image: Svg('assets/kakao_icon.svg'))
                          : Icon(
                            Icons.device_unknown_outlined,
                            color: colorScheme.onSurfaceVariant,
                            size: 22,
                          ),
                ),
                SizedBox(width: spacing.small),
                Text(
                  user.platform == LoginPlatform.naver
                      ? AppStrings.naverLogin
                      : user.platform == LoginPlatform.kakao
                      ? AppStrings.kakaoLogin
                      : AppStrings.noInfo,
                  style: textStyles.bodyLarge,
                ),
              ],
            ),
            if (formattedCreatedAt.isNotEmpty) ...[
              SizedBox(height: spacing.small),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  '${AppStrings.memberSince}: $formattedCreatedAt',
                  style: textStyles.bodyMedium.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAccountDeletionSection() {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final AppTextStyles textStyles = theme.extension<AppTextStyles>()!;

    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: colorScheme.error.withAlpha(80)),
      ),
      leading: Icon(Icons.delete_forever_outlined, color: colorScheme.error),
      title: Text(
        AppStrings.accountDeletion,
        style: textStyles.bodyLarge.copyWith(color: colorScheme.error),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        color: colorScheme.onSurfaceVariant,
        size: 16,
      ),
      onTap: controller.handleAccountDeletionRequest,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 4.0,
      ),
    );
  }
}
