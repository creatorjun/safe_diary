// lib/app/views/profile/widgets/partner_section.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:safe_diary/app/controllers/profile_controller.dart';
import 'package:safe_diary/app/routes/app_pages.dart';
import 'package:safe_diary/app/theme/app_theme.dart';
import 'package:safe_diary/app/utils/app_strings.dart';

class PartnerSection extends GetView<ProfileController> {
  const PartnerSection({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final AppTextStyles textStyles = theme.extension<AppTextStyles>()!;
    final AppSpacing spacing = theme.extension<AppSpacing>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(AppStrings.partnerConnection, style: textStyles.titleLarge),
        SizedBox(height: spacing.medium),
        Obx(() {
          if (controller.partnerController.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = controller.loginController.user;
          final partnerRelation =
              controller.partnerController.currentPartnerRelation.value;
          final invitation =
              controller.partnerController.currentInvitation.value;

          if (user.partnerUid != null && user.partnerUid!.isNotEmpty) {
            String partnerNickname =
                user.partnerNickname ?? AppStrings.defaultPartner;
            String formattedPartnerSince = AppStrings.noDateInfo;
            if (partnerRelation != null) {
              try {
                formattedPartnerSince =
                    DateFormat('yy년 MM월 dd일', 'ko_KR').format(
                      DateTime.parse(partnerRelation.partnerSince).toLocal(),
                    );
              } catch (e) {
                /* 날짜 파싱 실패 무시 */
              }
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.connectedPartner(partnerNickname),
                  style:
                  textStyles.bodyLarge.copyWith(color: colorScheme.primary),
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
                  icon:
                  const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                  label: Text(
                    AppStrings.chatWithPartner(partnerNickname),
                    style: textStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 45),
                  ),
                  onPressed: () => Get.toNamed(
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
                    style: textStyles.bodyMedium
                        .copyWith(color: colorScheme.error),
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
              formattedExpiresAt = DateFormat('yy/MM/dd HH:mm', 'ko_KR')
                  .format(DateTime.parse(invitation.expiresAt).toLocal());
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
                  controller:
                  TextEditingController(text: invitation.invitationId),
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
                  controller: controller.invitationCodeInputController,
                  style: textStyles.bodyLarge,
                  decoration: InputDecoration(
                    hintText: AppStrings.enterInvitationCode,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.send_rounded),
                      tooltip: AppStrings.acceptInvitation,
                      onPressed: () {
                        final code =
                        controller.invitationCodeInputController.text.trim();
                        controller.acceptInvitation(code);
                      },
                    ),
                  ),
                ),
              ],
            );
          }
        }),
      ],
    );
  }
}