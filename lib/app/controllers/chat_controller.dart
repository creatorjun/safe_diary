// lib/app/controllers/chat_controller.dart

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safe_diary/app/utils/app_strings.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

import '../config/app_config.dart';
import '../models/chat_models.dart';
import '../services/chat_service.dart';
import 'error_controller.dart';
import 'login_controller.dart';

class ChatController extends GetxController {
  final ChatService _chatService;
  final LoginController _loginController;
  final String _chatPartnerUid;
  final String? _chatPartnerNickname;

  ChatController({
    required ChatService chatService,
    required LoginController loginController,
    required String partnerUid,
    String? partnerNickname,
  }) : _chatService = chatService,
       _loginController = loginController,
       _chatPartnerUid = partnerUid,
       _chatPartnerNickname = partnerNickname;

  ErrorController get _errorController => Get.find<ErrorController>();

  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isFetchingMore = false.obs;
  final RxBool hasReachedMax = false.obs;
  final RxBool hasInitialLoadError = false.obs;
  final ScrollController scrollController = ScrollController();
  final TextEditingController messageInputController = TextEditingController();

  String get chatPartnerNickname =>
      _chatPartnerNickname ?? AppStrings.defaultPartner;

  StompClient? stompClient;
  StompUnsubscribe? _chatSubscription;
  StompUnsubscribe? _readReceiptSubscription;

  @override
  void onInit() {
    super.onInit();
    _initializeChat();
    scrollController.addListener(_scrollListener);
  }

  void _initializeChat() {
    if (_loginController.user.id == null || _chatPartnerUid.isEmpty) {
      hasInitialLoadError.value = true;
      _errorController.handleError(AppStrings.invalidChatPartnerInfo);
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
      _errorController.handleError(AppStrings.stompApiUrlNotFound);
      return;
    }
    String stompUrl;
    if (baseApiUrl.startsWith('https')) {
      stompUrl = "${baseApiUrl.replaceFirst('https', 'wss')}/ws";
    } else {
      stompUrl = "${baseApiUrl.replaceFirst('http', 'ws')}/ws";
    }

    final String? token = _loginController.user.safeAccessToken;
    if (token == null) {
      _errorController.handleError(AppStrings.stompTokenNotFound);
      return;
    }

    stompClient = StompClient(
      config: StompConfig(
        url: stompUrl,
        onConnect: _onStompConnected,
        onWebSocketError: (dynamic error) {
          _errorController.handleError(
            error,
            userFriendlyMessage: AppStrings.chatConnectionError,
          );
        },
        onStompError: (StompFrame frame) {
          _errorController.handleError(
            frame.body ?? 'STOMP 프로토콜 오류',
            userFriendlyMessage: AppStrings.chatProtocolError,
          );
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

    _onEnterChatRoom();

    _chatSubscription = stompClient?.subscribe(
      destination: '/user/queue/private',
      callback: (StompFrame frame) {
        if (frame.body != null) {
          try {
            final ChatMessage receivedMessage = ChatMessage.fromJson(
              json.decode(frame.body!),
            );

            bool isMyEchoMessage = receivedMessage.senderUid == _currentUserUid;

            if (isMyEchoMessage) {
              final index = messages.lastIndexWhere(
                (msg) =>
                    (msg.id?.startsWith('temp_') ?? false) &&
                    msg.content == receivedMessage.content,
              );
              if (index != -1) {
                messages[index] = receivedMessage;
              }
            } else {
              if (!messages.any((m) => m.id == receivedMessage.id)) {
                messages.add(receivedMessage);
              }
            }
          } catch (e) {
            _errorController.handleError(
              e,
              userFriendlyMessage: AppStrings.newMessageProcessingError,
            );
          }
        }
      },
    );

    _readReceiptSubscription = stompClient?.subscribe(
      destination: '/user/queue/readReceipts',
      callback: (StompFrame frame) {
        if (frame.body != null) {
          try {
            if (kDebugMode) {
              print('[ChatController] Read receipt received: ${frame.body}');
            }
            final confirmation = json.decode(frame.body!);
            final List<String> updatedMessageIds = List<String>.from(
              confirmation['updatedMessageIds'] ?? [],
            );

            for (String msgId in updatedMessageIds) {
              final index = messages.indexWhere((m) => m.id == msgId);
              if (index != -1 && !messages[index].isRead) {
                messages[index] = messages[index].copyWith(isRead: true);
              }
            }
          } catch (e) {
            if (kDebugMode) {
              print('[ChatController] Error processing read receipt: $e');
            }
          }
        }
      },
    );
  }

  void _onEnterChatRoom() {
    if (stompClient == null || !stompClient!.connected) return;

    final payload = {'partnerUid': _chatPartnerUid};
    final body = json.encode(payload);

    stompClient?.send(
      destination: '/app/chat.activity.enter',
      body: body,
      headers: {
        'Authorization': 'Bearer ${_loginController.user.safeAccessToken}',
      },
    );
    if (kDebugMode) {
      print(
        '[ChatController] Sent activity.enter event for partner: $_chatPartnerUid',
      );
    }

    stompClient?.send(
      destination: '/app/chat.messageRead',
      body: body,
      headers: {
        'Authorization': 'Bearer ${_loginController.user.safeAccessToken}',
      },
    );
    if (kDebugMode) {
      print(
        '[ChatController] Sent messageRead event for partner: $_chatPartnerUid',
      );
    }
  }

  void _onLeaveChatRoom() {
    if (stompClient == null || !stompClient!.connected) return;

    final payload = {'partnerUid': _chatPartnerUid};

    stompClient?.send(
      destination: '/app/chat.activity.leave',
      body: json.encode(payload),
      headers: {
        'Authorization': 'Bearer ${_loginController.user.safeAccessToken}',
      },
    );
    if (kDebugMode) {
      print(
        '[ChatController] Sent activity.leave event for partner: $_chatPartnerUid',
      );
    }
  }

  Future<void> fetchInitialMessages() async {
    if (_chatPartnerUid.isEmpty) {
      hasInitialLoadError.value = true;
      _errorController.handleError(AppStrings.cannotFetchMessagesNoPartner);
      return;
    }
    isLoading.value = true;
    hasInitialLoadError.value = false;
    try {
      final response = await _chatService.getChatMessages(
        otherUserUid: _chatPartnerUid,
        size: 20,
      );

      final fetchedMessages = response.messages;
      fetchedMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      messages.assignAll(fetchedMessages);
      hasReachedMax.value = !response.hasNextPage;
    } catch (e) {
      hasInitialLoadError.value = true;
      _errorController.handleError(
        e,
        userFriendlyMessage: AppStrings.messageLoadError,
      );
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
        final newMessages = response.messages;
        newMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        messages.insertAll(0, newMessages);
      }
      hasReachedMax.value = !response.hasNextPage;
    } catch (e) {
      _errorController.handleError(
        e,
        userFriendlyMessage: AppStrings.fetchPreviousMessagesError,
      );
    } finally {
      isFetchingMore.value = false;
    }
  }

  void sendMessage() {
    final String content = messageInputController.text.trim();
    if (content.isEmpty) return;
    if (stompClient == null || !stompClient!.connected) {
      _errorController.handleError(AppStrings.chatServerError);
      return;
    }

    final tempMessage = ChatMessage(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      type: MessageType.chat,
      content: content,
      senderUid: _currentUserUid,
      receiverUid: _chatPartnerUid,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      isRead: false,
    );
    messages.add(tempMessage);

    final messageToSendPayload = {
      'type': MessageType.chat.name,
      'content': content,
      'senderUid': _currentUserUid,
      'receiverUid': _chatPartnerUid,
    };

    stompClient?.send(
      destination: '/app/chat.sendMessage',
      body: json.encode(messageToSendPayload),
      headers: {
        'Authorization': 'Bearer ${_loginController.user.safeAccessToken}',
      },
    );
    messageInputController.clear();
  }

  void _scrollListener() {
    if (scrollController.position.pixels <=
            scrollController.position.minScrollExtent + 50 &&
        !isFetchingMore.value &&
        !hasReachedMax.value) {
      fetchMoreMessages();
    }
  }

  @override
  void onClose() {
    _onLeaveChatRoom();
    _chatSubscription?.call();
    _readReceiptSubscription?.call();
    stompClient?.deactivate();
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();
    messageInputController.dispose();
    super.onClose();
  }
}
