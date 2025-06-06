// lib/app/services/chat_service.dart

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../models/chat_models.dart';
import 'api_service.dart';

class ChatService extends GetxService {
  final ApiService _apiService;
  ChatService(this._apiService);

  /// 특정 사용자와의 채팅 메시지 목록을 조회합니다. (페이지네이션)
  Future<PaginatedChatMessagesResponse> getChatMessages({
    required String otherUserUid,
    int? beforeTimestamp,
    int size = 20,
  }) async {
    final queryParams = {'size': size.toString()};
    if (beforeTimestamp != null) {
      queryParams['before'] = beforeTimestamp.toString();
    }

    try {
      final response = await _apiService.get<PaginatedChatMessagesResponse>(
        '/api/v1/chat/with/$otherUserUid/messages',
        queryParams: queryParams,
        parser: (data) =>
            PaginatedChatMessagesResponse.fromJson(data as Map<String, dynamic>),
      );
      return response;
    } on ApiException catch (e) {
      if (kDebugMode) print('[ChatService] getChatMessages Error: $e');
      rethrow;
    }
  }

  /// 특정 사용자와의 채팅 메시지에서 키워드로 검색합니다.
  Future<PaginatedChatMessagesResponse> searchChatMessages({
    required String otherUserUid,
    required String keyword,
    int page = 0,
    int size = 20,
  }) async {
    final queryParams = {
      'keyword': keyword,
      'page': page.toString(),
      'size': size.toString(),
    };

    try {
      final response = await _apiService.get<PaginatedChatMessagesResponse>(
        '/api/v1/chat/with/$otherUserUid/messages/search',
        queryParams: queryParams,
        parser: (data) =>
            PaginatedChatMessagesResponse.fromJson(data as Map<String, dynamic>),
      );
      return response;
    } on ApiException catch (e) {
      if (kDebugMode) print('[ChatService] searchChatMessages Error: $e');
      rethrow;
    }
  }

  /// 특정 채팅 메시지를 삭제합니다.
  Future<void> deleteChatMessage(String messageId) async {
    try {
      await _apiService.delete<void>(
        '/api/v1/chat/messages/$messageId',
      );
    } on ApiException catch (e) {
      if (kDebugMode) print('[ChatService] deleteChatMessage Error: $e');
      rethrow;
    }
  }
}