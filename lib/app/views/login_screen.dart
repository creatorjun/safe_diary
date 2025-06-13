import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:get/get.dart';

import '../controllers/login_controller.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});

  Widget _buildNaverLoginButton(
    BuildContext context,
    LoginController controller,
  ) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF03C75A),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
          horizontalSpaceSmall,
          Text('네이버 로그인', style: textStyleLarge.copyWith(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildKakaoLoginButton(
    BuildContext context,
    LoginController controller,
  ) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFEE500),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
          horizontalSpaceSmall,
          Text(
            '카카오 로그인',
            style: textStyleLarge.copyWith(color: const Color(0xFF191919)),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfileView(
    BuildContext context,
    LoginController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '${controller.user.nickname ?? '사용자'}님, 환영합니다!',
          style: textStyleLarge.copyWith(fontSize: 20.0),
          textAlign: TextAlign.center,
        ),
        verticalSpaceMedium,
        Text(
          '로그인 플랫폼: ${controller.user.platform.name}',
          style: textStyleSmall,
          textAlign: TextAlign.center,
        ),
        verticalSpaceLarge,
        ElevatedButton(
          onPressed: () {
            controller.logout();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
            padding: const EdgeInsets.symmetric(vertical: 12),
            minimumSize: const Size(double.infinity, 50),
          ),
          child: Text(
            '로그아웃',
            style: textStyleMedium.copyWith(color: Colors.white),
          ),
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

    final colorScheme = Theme.of(context).colorScheme;

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
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
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
                          verticalSpaceMedium,
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
