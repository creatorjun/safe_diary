// lib/app/controllers/chat_controller.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

import '../models/chat_models.dart';
import '../services/chat_service.dart';
import 'login_controller.dart';
import '../config/app_config.dart';

class ChatController extends GetxController {
  // 생성자를 통해 의존성을 주입받습니다.
  final ChatService _chatService;
  final LoginController _loginController;
  final String _chatPartnerUid;
  final String? _chatPartnerNickname;

  ChatController({
    required ChatService chatService,
    required LoginController loginController,
    required String partnerUid,
    String? partnerNickname,
  })  : _chatService = chatService,
        _loginController = loginController,
        _chatPartnerUid = partnerUid,
        _chatPartnerNickname = partnerNickname;

  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isFetchingMore = false.obs;
  final RxBool hasReachedMax = false.obs;
  final RxString errorMessage = ''.obs;
  final ScrollController scrollController = ScrollController();
  final TextEditingController messageInputController = TextEditingController();

  String get chatPartnerNickname => _chatPartnerNickname ?? '상대방';

  StompClient? stompClient;
  StompUnsubscribe? _stompSubscription;


  @override
  void onInit() {
    super.onInit();
    _initializeChat();
    scrollController.addListener(_scrollListener);
  }

  void _initializeChat() {
    if (_loginController.user.id == null || _chatPartnerUid.isEmpty) {
      errorMessage.value = "채팅 상대방 정보가 유효하지 않습니다.";
      isLoading.value = false;
      return;
    }
    fetchInitialMessages();
    _connectToStomp();
  }

  String get _currentUserUid => _loginController.user.id!;

  void _connectToStomp() {
    final String? baseApiUrl = AppConfig.apiUrl;
    if (baseApiUrl == null) {
      errorMessage.value = "STOMP 연결을 위한 API URL을 찾을 수 없습니다.";
      return;
    }

    String stompUrl = "${baseApiUrl.replaceFirst(RegExp(r'^http'), 'ws')}/ws";

    final String? token = _loginController.user.safeAccessToken;
    if (token == null) {
      errorMessage.value = "STOMP 연결을 위한 인증 토큰이 없습니다.";
      return;
    }

    stompClient = StompClient(
      config: StompConfig(
        url: stompUrl,
        onConnect: _onStompConnected,
        onWebSocketError: (dynamic error) {
          if (kDebugMode) print('[ChatController] STOMP WebSocket Error: $error');
          errorMessage.value = '채팅 서버 연결 오류: ${error.toString()}';
        },
        onStompError: (StompFrame frame) {
          if (kDebugMode) print('[ChatController] STOMP Error: ${frame.body}');
          errorMessage.value = '채팅 프로토콜 오류: ${frame.body}';
        },
        onDisconnect: (StompFrame frame) {
          if (kDebugMode) print('[ChatController] STOMP Disconnected.');
        },
        stompConnectHeaders: {'Authorization': 'Bearer $token'},
        webSocketConnectHeaders: {'Authorization': 'Bearer $token'},
      ),
    );
    stompClient?.activate();
  }

  void _onStompConnected(StompFrame frame) {
    if (kDebugMode) print('[ChatController] STOMP Connected.');
    final String subscriptionDestination = '/user/queue/private';

    _stompSubscription = stompClient?.subscribe(
      destination: subscriptionDestination,
      callback: (StompFrame frame) {
        if (frame.body != null) {
          if (kDebugMode) print('[ChatController] STOMP Message Received: ${frame.body}');
          try {
            final Map<String, dynamic> jsonMessage = json.decode(frame.body!);
            final ChatMessage receivedMessage = ChatMessage.fromJson(jsonMessage);

            bool isMyEchoMessage = receivedMessage.senderUid == _currentUserUid &&
                receivedMessage.receiverUid == _chatPartnerUid;
            bool isPartnerOriginatedMessage = receivedMessage.senderUid == _chatPartnerUid &&
                receivedMessage.receiverUid == _currentUserUid;

            if (isMyEchoMessage || isPartnerOriginatedMessage) {
              if (receivedMessage.id != null && !messages.any((m) => m.id == receivedMessage.id)) {
                messages.insert(0, receivedMessage);
                messages.refresh();
              }
            }
          } catch (e) {
            if (kDebugMode) print('[ChatController] Error processing STOMP message: $e');
          }
        }
      },
    );
  }


  Future<void> fetchInitialMessages() async {
    if (_chatPartnerUid.isEmpty) {
      errorMessage.value = "상대방 정보가 없어 메시지를 조회할 수 없습니다.";
      return;
    }
    isLoading.value = true;
    errorMessage.value = '';
    hasReachedMax.value = false;
    try {
      final response = await _chatService.getChatMessages(
          otherUserUid: _chatPartnerUid, size: 20);
      messages.assignAll(response.messages.reversed.toList());
      hasReachedMax.value = !response.hasNextPage;
    } catch (e) {
      errorMessage.value = "메시지 로딩 중 오류: ${e.toString()}";
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchMoreMessages() async {
    if (isFetchingMore.value || hasReachedMax.value || messages.isEmpty) return;

    isFetchingMore.value = true;
    try {
      final lastTimestamp = messages.first.timestamp;
      final response = await _chatService.getChatMessages(
        otherUserUid: _chatPartnerUid,
        beforeTimestamp: lastTimestamp,
        size: 20,
      );
      if (response.messages.isNotEmpty) {
        messages.insertAll(0, response.messages.reversed.toList());
      }
      hasReachedMax.value = !response.hasNextPage;
    } catch (e) {
      if (kDebugMode) print('[ChatController] Fetch more messages error: $e');
    } finally {
      isFetchingMore.value = false;
    }
  }

  void sendMessage() {
    final String content = messageInputController.text.trim();
    if (content.isEmpty) return;
    if (stompClient == null || !stompClient!.connected) {
      Get.snackbar("전송 실패", "채팅 서버에 연결되어 있지 않습니다.");
      return;
    }

    final messageToSendPayload = {
      'type': MessageType.chat.name,
      'content': content,
      'senderUid': _currentUserUid,
      'receiverUid': _chatPartnerUid,
    };

    stompClient?.send(
      destination: '/app/chat.sendMessage',
      body: json.encode(messageToSendPayload),
      headers: {'Authorization': 'Bearer ${_loginController.user.safeAccessToken}'},
    );
    messageInputController.clear();
  }

  void _scrollListener() {
    if (scrollController.position.pixels <= scrollController.position.minScrollExtent + 50 &&
        !isFetchingMore.value &&
        !hasReachedMax.value) {
      fetchMoreMessages();
    }
  }

  @override
  void onClose() {
    _stompSubscription?.call();
    stompClient?.deactivate();
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();
    messageInputController.dispose();
    super.onClose();
  }
}