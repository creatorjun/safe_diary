// lib/app/routes/app_pages.dart

import 'package:get/get.dart';

import '../bindings/chat_binding.dart';
import '../bindings/home_binding.dart';
import '../bindings/login_binding.dart';
import '../bindings/privacy_policy_binding.dart'; // <<< 추가
import '../bindings/profile_auth_binding.dart';
import '../bindings/profile_binding.dart';
import '../views/chat_screen.dart';
import '../views/home_screen.dart';
import '../views/login_screen.dart';
import '../views/privacy_policy_screen.dart'; // <<< 추가
import '../views/profile_auth_screen.dart';
import '../views/profile_screen.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = Routes.login;

  static final routes = [
    GetPage(
      name: _Paths.login,
      page: () => const LoginScreen(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.home,
      page: () => const HomeScreen(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.profileAuth,
      page: () => const ProfileAuthScreen(),
      binding: ProfileAuthBinding(),
    ),
    GetPage(
      name: _Paths.profile,
      page: () => const ProfileScreen(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.chat,
      page: () => const ChatScreen(),
      binding: ChatBinding(),
    ),
    GetPage( // <<< 추가
      name: _Paths.privacyPolicy,
      page: () => const PrivacyPolicyScreen(),
      binding: PrivacyPolicyBinding(),
    ),
  ];
}