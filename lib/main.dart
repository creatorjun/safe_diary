// lib/main.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk_user.dart';
import 'package:naver_login_sdk/naver_login_sdk.dart';

import 'app/bindings/initial_binding.dart';
import 'app/config/app_config.dart';
import 'app/controllers/login_controller.dart';
import 'app/routes/app_pages.dart';
import 'app/services/notification_service.dart';
import 'app/theme/app_theme.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // InitialBinding을 먼저 실행하여 모든 서비스와 컨트롤러를 등록합니다.
  InitialBinding().dependencies();

  await Get.find<NotificationService>().init();

  await AppConfig.loadEnv();

  await initializeDateFormatting();

  final LoginController loginController = Get.find<LoginController>();

  // --- 여기부터 수정 ---

  // 자동 로그인을 시도하고 결과에 따라 초기 라우트 경로를 결정합니다.
  final String initialRoute = await loginController.tryAutoLoginAndGetInitialRoute();

  // --- 여기까지 수정 ---

  final String naverAppName = dotenv.env['AppName'] ?? 'YOUR_APP_NAME_DEFAULT';
  final String naverClientId =
      dotenv.env['ClientId'] ?? 'YOUR_NAVER_CLIENT_ID_DEFAULT';
  final String naverClientSecret =
      dotenv.env['ClientSecret'] ?? 'YOUR_NAVER_CLIENT_SECRET_DEFAULT';
  final String? naverUrlScheme = dotenv.env['UrlScheme'];

  final String kakaoNativeAppKey =
      dotenv.env['NativeAppKey'] ?? 'YOUR_KAKAO_NATIVE_APP_KEY_DEFAULT';

  await NaverLoginSDK.initialize(
    clientId: naverClientId,
    clientSecret: naverClientSecret,
    clientName: naverAppName,
    urlScheme: naverUrlScheme,
  );

  KakaoSdk.init(nativeAppKey: kakaoNativeAppKey);

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Safe Diary',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      initialRoute: initialRoute,
      getPages: AppPages.routes,
    );
  }
}