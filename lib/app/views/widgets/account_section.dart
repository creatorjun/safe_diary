// lib/app/views/profile/widgets/account_section.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:get/get.dart';
import 'package:safe_diary/app/controllers/profile_controller.dart';
import 'package:safe_diary/app/models/user.dart';
import 'package:safe_diary/app/theme/app_theme.dart';
import 'package:safe_diary/app/utils/app_strings.dart';

class AccountSection extends GetView<ProfileController> {
  const AccountSection({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final AppTextStyles textStyles = theme.extension<AppTextStyles>()!;
    final AppSpacing spacing = theme.extension<AppSpacing>()!;
    final user = controller.loginController.user;
    final formattedCreatedAt = user.formattedCreatedAt;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(AppStrings.accountInfo, style: textStyles.titleLarge),
        SizedBox(height: spacing.small),
        Card(
          elevation: 2.0,
          child: Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: user.platform == LoginPlatform.naver
                          ? const Image(image: Svg('assets/naver_icon.svg'))
                          : user.platform == LoginPlatform.kakao
                          ? const Image(
                          image: Svg('assets/kakao_icon.svg'))
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
        ),
        SizedBox(height: spacing.medium),
        ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: BorderSide(color: colorScheme.error.withAlpha(80)),
          ),
          leading:
          Icon(Icons.delete_forever_outlined, color: colorScheme.error),
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
        )
      ],
    );
  }
}