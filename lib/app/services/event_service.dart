// lib/app/services/event_service.dart

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../models/event_item.dart';
import 'api_service.dart';

class EventService extends GetxService {
  final ApiService _apiService;
  EventService(this._apiService);

  /// 사용자의 모든 이벤트 목록을 조회합니다.
  Future<List<EventItem>> getEvents() async {
    try {
      final events = await _apiService.get<List<EventItem>>(
        '/api/v1/events',
        parser: (data) => (data as List<dynamic>)
            .map((item) => EventItem.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
      return events;
    } on ApiException catch (e) {
      if (kDebugMode) print('[EventService] getEvents Error: $e');
      rethrow;
    }
  }

  /// 새로운 이벤트를 생성합니다.
  Future<EventItem> createEvent(EventItem event) async {
    try {
      final createdEvent = await _apiService.post<EventItem>(
        '/api/v1/events',
        body: event.toJsonForCreate(),
        parser: (data) => EventItem.fromJson(data as Map<String, dynamic>),
      );
      return createdEvent;
    } on ApiException catch (e) {
      if (kDebugMode) print('[EventService] createEvent Error: $e');
      rethrow;
    }
  }

  /// 기존 이벤트를 수정합니다.
  Future<EventItem> updateEvent(EventItem event) async {
    if (event.backendEventId == null) {
      throw ArgumentError('수정할 이벤트의 ID가 없습니다.');
    }
    try {
      final updatedEvent = await _apiService.put<EventItem>(
        '/api/v1/events',
        body: event.toJsonForUpdate(), // backendEventId가 포함된 JSON
        parser: (data) => EventItem.fromJson(data as Map<String, dynamic>),
      );
      return updatedEvent;
    } on ApiException catch (e) {
      if (kDebugMode) print('[EventService] updateEvent Error: $e');
      rethrow;
    }
  }

  /// 이벤트를 삭제합니다.
  Future<void> deleteEvent(String backendEventId) async {
    try {
      await _apiService.delete<void>(
        '/api/v1/events',
        body: {'eventId': backendEventId},
      );
    } on ApiException catch (e) {
      if (kDebugMode) print('[EventService] deleteEvent Error: $e');
      rethrow;
    }
  }
}