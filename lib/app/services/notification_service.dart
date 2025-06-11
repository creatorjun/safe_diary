// lib/app/services/notification_service.dart

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import '../../firebase_options.dart';
import '../controllers/login_controller.dart';
import '../routes/app_pages.dart'; // 라우트 사용을 위해 추가

// Background handler는 반드시 최상위 함수여야 합니다.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // 백그라운드에서 다른 Firebase 서비스를 사용하려면 초기화가 필요할 수 있습니다.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (kDebugMode) {
    print(
      "[NotificationService] Handling a background message: ${message.messageId}",
    );
    // 백그라운드에서 알림 클릭 시의 네비게이션은 여기서 처리하지 않습니다.
    // onMessageOpenedApp 리스너가 처리합니다.
  }
}

class NotificationService extends GetxService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Android 알림 채널 정의
  final AndroidNotificationChannel _androidChannel =
      const AndroidNotificationChannel(
        'high_importance_channel', // 채널 ID
        '중요 알림', // 채널 이름
        description: '중요한 알림을 위한 채널입니다.', // 채널 설명
        importance: Importance.high,
      );

  /// 서비스 초기화 메서드
  Future<NotificationService> init() async {
    await _requestIOSPermissions();
    await _setupLocalNotifications();
    await _setupFirebaseListeners();
    return this;
  }

  /// iOS 푸시 알림 권한을 요청합니다.
  Future<void> _requestIOSPermissions() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (kDebugMode) {
      print(
        '[NotificationService] User granted permission: ${settings.authorizationStatus}',
      );
    }
  }

  /// 로컬 알림 설정 (Android 채널 생성 포함)
  Future<void> _setupLocalNotifications() async {
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_androidChannel);

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (kDebugMode) {
          print(
            '[NotificationService] Local notification tapped with payload: ${response.payload}',
          );
        }
        if (response.payload != null && response.payload!.isNotEmpty) {
          // 포그라운드 알림 탭 시 네비게이션 처리
          // payload는 문자열이므로 Map으로 변환 필요
          // _handleMessageNavigation(json.decode(response.payload!));
        }
      },
    );
  }

  /// Firebase 메시징 리스너 설정
  Future<void> _setupFirebaseListeners() async {
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 앱이 백그라운드 상태일 때 알림을 탭하면 호출
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('[NotificationService] Message clicked and app opened!');
      }
      _handleMessageNavigation(message.data);
    });

    // 앱이 종료된 상태에서 알림을 탭하면 호출
    _messaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        if (kDebugMode) {
          print(
            '[NotificationService] Terminated App: Initial message received.',
          );
        }
        _handleMessageNavigation(message.data);
      }
    });

    _messaging.onTokenRefresh.listen(_updateTokenOnServer);

    // 초기 FCM 토큰 가져오기
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        _updateTokenOnServer(token);
      }
    } catch (e) {
      if (kDebugMode) {
        print('[NotificationService] Failed to get FCM token: $e');
      }
    }
  }

  /// 포그라운드 메시지 처리 및 로컬 알림 표시
  void _handleForegroundMessage(RemoteMessage message) {
    if (kDebugMode) {
      print('[NotificationService] Got a message whilst in the foreground!');
    }
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        // payload: json.encode(message.data), // data 페이로드를 payload로 전달
      );
    }
  }

  /// 메시지 데이터에 따라 적절한 화면으로 이동
  void _handleMessageNavigation(Map<String, dynamic> data) {
    if (kDebugMode) {
      print('[NotificationService] Handling navigation for data: $data');
    }

    final String? type = data['type'] as String?;
    if (type == 'chat') {
      final String? senderUid = data['senderUid'] as String?;
      final String? senderNickname = data['senderNickname'] as String?;

      if (senderUid != null) {
        // 이미 해당 채팅방에 있다면 이동하지 않음
        if (Get.currentRoute == Routes.chat &&
            (Get.arguments as Map)['partnerUid'] == senderUid) {
          return;
        }
        Get.toNamed(
          Routes.chat,
          arguments: {
            'partnerUid': senderUid,
            'partnerNickname': senderNickname ?? '상대방',
          },
        );
      }
    }
    // 다른 종류의 알림(공지사항 등)이 있다면 여기에 추가
    // else if (type == 'notice') { ... }
  }

  /// FCM 토큰을 서버로 전송
  void _updateTokenOnServer(String token) {
    if (kDebugMode) {
      print('[NotificationService] FCM Token: $token');
    }
    if (Get.isRegistered<LoginController>()) {
      final loginController = Get.find<LoginController>();
      if (loginController.isLoggedIn.value) {
        loginController.sendFcmTokenToServer(token);
      } else {
        if (kDebugMode) {
          print(
            '[NotificationService] User not logged in, FCM token will be sent after login.',
          );
        }
      }
    }
  }
}
