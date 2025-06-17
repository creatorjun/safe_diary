import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
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
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  InitialBinding().dependencies();

  await Get.find<NotificationService>().init();

  await AppConfig.loadEnv();

  await initializeDateFormatting();

  final LoginController loginController = Get.find<LoginController>();

  // 자동 로그인 및 초기 화면 설정
  final String initialRoute =
      await loginController.tryAutoLoginAndGetInitialRoute();

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

  FlutterNativeSplash.remove();

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
