// lib/app/models/chat_models.dart

import 'package:safe_diary/app/models/event_item.dart';

enum MessageType {
  chat,
  join,
  leave,
  date,
  schedule;

  String toJson() => name;

  static MessageType fromJson(String? jsonValue) {
    if (jsonValue == null) return MessageType.chat;
    return MessageType.values.firstWhere(
          (e) => e.name.toLowerCase() == jsonValue.toLowerCase(),
      orElse: () => MessageType.chat,
    );
  }
}

class EventDetails {
  final String backendEventId;
  final String text;
  final String? startTime;
  final String? endTime;
  final String createdAt;
  final String? eventDate;
  final int displayOrder;

  EventDetails({
    required this.backendEventId,
    required this.text,
    this.startTime,
    this.endTime,
    required this.createdAt,
    this.eventDate,
    required this.displayOrder,
  });

  factory EventDetails.fromJson(Map<String, dynamic> json) {
    return EventDetails(
      backendEventId: json['backendEventId'] as String,
      text: json['text'] as String,
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
      createdAt: json['createdAt'] as String,
      eventDate: json['eventDate'] as String?,
      displayOrder: json['displayOrder'] as int,
    );
  }

  // EventItem을 EventDetails로 변환하는 헬퍼 메서드
  factory EventDetails.fromEventItem(EventItem event) {
    return EventDetails(
      backendEventId: event.backendEventId ?? '',
      text: event.title,
      startTime: event.startTime != null ? '${event.startTime!.hour.toString().padLeft(2, '0')}:${event.startTime!.minute.toString().padLeft(2, '0')}' : null,
      endTime: event.endTime != null ? '${event.endTime!.hour.toString().padLeft(2, '0')}:${event.endTime!.minute.toString().padLeft(2, '0')}' : null,
      createdAt: event.createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      eventDate: event.eventDate.toIso8601String().split('T').first,
      displayOrder: event.displayOrder ?? 0,
    );
  }
}


class ChatMessage {
  final String? id;
  final MessageType type;
  final String? content;
  final String senderUid;
  final String? senderNickname;
  final String? receiverUid;
  final int timestamp;
  final bool isRead;
  final EventDetails? eventDetails;

  ChatMessage({
    this.id,
    required this.type,
    this.content,
    required this.senderUid,
    this.senderNickname,
    this.receiverUid,
    required this.timestamp,
    required this.isRead,
    this.eventDetails,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String?,
      type: MessageType.fromJson(json['type'] as String?),
      content: json['content'] as String?,
      senderUid: json['senderUid'] as String,
      senderNickname: json['senderNickname'] as String?,
      receiverUid: json['receiverUid'] as String?,
      timestamp: json['timestamp'] as int,
      isRead: json['isRead'] as bool? ?? false,
      eventDetails: json['eventDetails'] != null
          ? EventDetails.fromJson(json['eventDetails'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toJson(),
      'content': content,
      'senderUid': senderUid,
      'senderNickname': senderNickname,
      'receiverUid': receiverUid,
      'timestamp': timestamp,
      'isRead': isRead,
      'eventDetails': null,
    };
  }

  DateTime get dateTime => DateTime.fromMillisecondsSinceEpoch(timestamp);

  ChatMessage copyWith({
    String? id,
    MessageType? type,
    String? content,
    String? senderUid,
    String? senderNickname,
    String? receiverUid,
    int? timestamp,
    bool? isRead,
    EventDetails? eventDetails,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      type: type ?? this.type,
      content: content ?? this.content,
      senderUid: senderUid ?? this.senderUid,
      senderNickname: senderNickname ?? this.senderNickname,
      receiverUid: receiverUid ?? this.receiverUid,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      eventDetails: eventDetails ?? this.eventDetails,
    );
  }
}

class PaginatedChatMessagesResponse {
  final List<ChatMessage> messages;
  final bool hasNextPage;
  final int? oldestMessageTimestamp;

  PaginatedChatMessagesResponse({
    required this.messages,
    required this.hasNextPage,
    this.oldestMessageTimestamp,
  });

  factory PaginatedChatMessagesResponse.fromJson(Map<String, dynamic> json) {
    var messagesList = json['messages'] as List? ?? [];
    List<ChatMessage> messages =
    messagesList.map((i) => ChatMessage.fromJson(i as Map<String, dynamic>)).toList();

    return PaginatedChatMessagesResponse(
      messages: messages,
      hasNextPage: json['hasNextPage'] as bool? ?? false,
      oldestMessageTimestamp: json['oldestMessageTimestamp'] as int?,
    );
  }
}