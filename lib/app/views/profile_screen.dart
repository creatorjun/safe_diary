// lib/app/views/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safe_diary/app/controllers/profile_controller.dart';
import 'package:safe_diary/app/theme/app_theme.dart';
import 'package:safe_diary/app/views/widgets/account_section.dart';
import 'package:safe_diary/app/views/widgets/partner_section.dart';
import 'package:safe_diary/app/views/widgets/profile_edit_section.dart';
import 'package:safe_diary/app/views/widgets/shared_background.dart';

import '../utils/app_strings.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppSpacing spacing = Theme.of(context).extension<AppSpacing>()!;
    final AppTextStyles textStyles = Theme.of(context).extension<AppTextStyles>()!;

    return SharedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            AppStrings.profileAndSettings,
            style: textStyles.titleMedium,
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(spacing.medium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const ProfileEditSection(),
                SizedBox(height: spacing.large),
                const Divider(),
                const PartnerSection(),
                SizedBox(height: spacing.large),
                const Divider(),
                const AccountSection(),
                SizedBox(height: spacing.large),
              ],
            ),
          ),
        ),
      ),
    );
  }
}