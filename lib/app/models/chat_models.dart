// lib/app/models/chat_models.dart

enum MessageType {
  chat,
  join,
  leave;

  String toJson() => name;

  static MessageType fromJson(String? jsonValue) {
    if (jsonValue == null) return MessageType.chat; // 기본값 또는 오류 처리
    return MessageType.values.firstWhere(
      (e) => e.name.toLowerCase() == jsonValue.toLowerCase(),
      orElse: () => MessageType.chat, // 매칭되는 값이 없을 경우 기본값
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
  final int timestamp; // Epoch milliseconds
  final bool isRead;

  ChatMessage({
    this.id,
    required this.type,
    this.content,
    required this.senderUid,
    this.senderNickname,
    this.receiverUid,
    required this.timestamp,
    required this.isRead,
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
      isRead:
          json['isRead'] as bool? ??
          json['read'] as bool? ??
          false, // API 명세에 read (writeOnly)도 있어서 isRead 우선
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
    };
  }

  DateTime get dateTime => DateTime.fromMillisecondsSinceEpoch(timestamp);

  @override
  String toString() {
    return 'ChatMessage(id: $id, type: $type, content: $content, senderUid: $senderUid, senderNickname: $senderNickname, receiverUid: $receiverUid, timestamp: $timestamp, isRead: $isRead)';
  }

  // ✅ '읽음' 상태 변경을 위해 copyWith 메서드를 추가합니다.
  ChatMessage copyWith({
    String? id,
    MessageType? type,
    String? content,
    String? senderUid,
    String? senderNickname,
    String? receiverUid,
    int? timestamp,
    bool? isRead,
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
        messagesList.map((i) => ChatMessage.fromJson(i)).toList();

    return PaginatedChatMessagesResponse(
      messages: messages,
      hasNextPage: json['hasNextPage'] as bool? ?? false,
      oldestMessageTimestamp: json['oldestMessageTimestamp'] as int?,
    );
  }
}
