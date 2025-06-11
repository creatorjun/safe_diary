import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
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

  InitialBinding().dependencies();

  await Get.find<NotificationService>().init();

  await AppConfig.loadEnv();

  await initializeDateFormatting();

  final LoginController loginController = Get.find<LoginController>();

  bool autoLoginSuccess = false;
  try {
    autoLoginSuccess = await loginController.tryAutoLoginWithRefreshToken();
  } catch (e) {
    if (kDebugMode) {
      print("[main.dart] Auto login attempt failed: $e");
    }
    autoLoginSuccess = false;
  }

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

  runApp(MyApp(initialRoute: autoLoginSuccess ? Routes.home : Routes.login));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Safe Diary',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: initialRoute,
      getPages: AppPages.routes,
    );
  }
}
