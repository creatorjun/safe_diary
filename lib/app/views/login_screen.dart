import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:get/get.dart';

import '../controllers/login_controller.dart';
import '../theme/app_theme.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});

  Widget _buildNaverLoginButton(
      BuildContext context,
      LoginController controller,
      ) {
    final ThemeData theme = Theme.of(context);
    final AppTextStyles textStyles = theme.extension<AppTextStyles>()!;
    final AppBrandColors brandColors = theme.extension<AppBrandColors>()!;
    final AppSpacing spacing = theme.extension<AppSpacing>()!;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: brandColors.naver,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
      ),
      onPressed: () {
        controller.loginWithNaver();
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Image(
            image: Svg('assets/naver_icon.svg'),
            width: 24,
            height: 24,
          ),
          SizedBox(width: spacing.small),
          Text('네이버 로그인', style: textStyles.labelLarge),
        ],
      ),
    );
  }

  Widget _buildKakaoLoginButton(
      BuildContext context,
      LoginController controller,
      ) {
    final ThemeData theme = Theme.of(context);
    final AppTextStyles textStyles = theme.extension<AppTextStyles>()!;
    final AppBrandColors brandColors = theme.extension<AppBrandColors>()!;
    final AppSpacing spacing = theme.extension<AppSpacing>()!;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: brandColors.kakao,
        foregroundColor: const Color(0xFF191919),
        minimumSize: const Size(double.infinity, 50),
      ),
      onPressed: () {
        controller.loginWithKakao();
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Image(
            image: Svg('assets/kakao_icon.svg'),
            width: 24,
            height: 24,
          ),
          SizedBox(width: spacing.small),
          Text('카카오 로그인', style: textStyles.labelLarge),
        ],
      ),
    );
  }

  Widget _buildUserProfileView(
      BuildContext context,
      LoginController controller,
      ) {
    final ThemeData theme = Theme.of(context);
    final AppTextStyles textStyles = theme.extension<AppTextStyles>()!;
    final AppSpacing spacing = theme.extension<AppSpacing>()!;
    final ColorScheme colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '${controller.user.nickname ?? '사용자'}님, 환영합니다!',
          style: textStyles.titleMedium,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: spacing.medium),
        Text(
          '로그인 플랫폼: ${controller.user.platform.name}',
          style: textStyles.bodyMedium,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: spacing.large),
        ElevatedButton(
          onPressed: () {
            controller.logout();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.secondaryContainer,
            foregroundColor: colorScheme.onSecondaryContainer,
            minimumSize: const Size(double.infinity, 50),
          ),
          child: Text('로그아웃', style: textStyles.labelLarge),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final String backgroundImage =
    Get.isDarkMode ? "assets/dark_back.png" : "assets/light_back.png";

    return Scaffold(
      body: Obx(() {
        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(backgroundImage),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(child: _buildLoginContent(context)),
        );
      }),
    );
  }

  Widget _buildLoginContent(BuildContext context) {
    if (controller.isLoading) {
      return const CircularProgressIndicator();
    }

    final ThemeData theme = Theme.of(context);
    final AppTextStyles textStyles = theme.extension<AppTextStyles>()!;
    final AppSpacing spacing = theme.extension<AppSpacing>()!;
    final ColorScheme colorScheme = theme.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 72.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: constraints.maxHeight * 0.15),
                    SizedBox(
                      height: 120,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: Text(
                          'Safe Diary',
                          textAlign: TextAlign.center,
                          style: textStyles.titleLarge.copyWith(
                            fontSize: 48,
                            color: colorScheme.primary,
                            shadows: [
                              Shadow(
                                blurRadius: 10.0,
                                color: colorScheme.shadow.withAlpha(50),
                                offset: const Offset(2, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (!controller.isLoggedIn.value) ...[
                          _buildNaverLoginButton(context, controller),
                          SizedBox(height: spacing.medium),
                          _buildKakaoLoginButton(context, controller),
                        ] else ...[
                          _buildUserProfileView(context, controller),
                        ],
                      ],
                    ),
                    SizedBox(height: constraints.maxHeight * 0.10),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}