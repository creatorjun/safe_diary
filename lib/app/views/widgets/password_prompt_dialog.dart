// lib/app/views/profile/widgets/password_prompt_dialog.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safe_diary/app/controllers/login_controller.dart';
import 'package:safe_diary/app/controllers/profile_controller.dart';
import 'package:safe_diary/app/utils/app_strings.dart';

class PasswordPromptDialog extends StatefulWidget {
  const PasswordPromptDialog({super.key});

  @override
  State<PasswordPromptDialog> createState() => _PasswordPromptDialogState();
}

class _PasswordPromptDialogState extends State<PasswordPromptDialog> {
  late final TextEditingController _passwordController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleConfirm() async {
    final loginController = Get.find<LoginController>();
    final profileController = Get.find<ProfileController>();

    final currentPassword = _passwordController.text.trim();
    if (currentPassword.isEmpty) {
      Get.snackbar(
        AppStrings.error,
        AppStrings.currentPasswordRequired,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final bool success = await loginController.removeAppPassword(currentPassword);

    if (success) {
      profileController.clearVerifiedPassword();
    }

    // 위젯이 아직 화면에 있다면 다이얼로그를 닫습니다.
    if (mounted) {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return AlertDialog(
      title: const Text(AppStrings.removePasswordPromptTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(AppStrings.removePasswordPromptContent),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            obscureText: true,
            autofocus: true,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: AppStrings.currentPassword,
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Get.back(),
          child: const Text(AppStrings.cancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: colorScheme.error,
            foregroundColor: colorScheme.onError,
          ),
          onPressed: _isLoading ? null : _handleConfirm,
          child: _isLoading
              ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colorScheme.onError,
            ),
          )
              : const Text(AppStrings.removeAppPassword),
        ),
      ],
    );
  }
}