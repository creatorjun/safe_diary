import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class EventItem {
  final String? backendEventId;
  final String title;
  final DateTime eventDate;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final DateTime? createdAt;
  final int? displayOrder;

  EventItem({
    this.backendEventId,
    required this.title,
    required this.eventDate,
    this.startTime,
    this.endTime,
    this.createdAt,
    this.displayOrder,
  });

  factory EventItem.fromJson(Map<String, dynamic> json) {
    final DateTime parsedEventDate = DateTime.parse(
      json['eventDate'] as String,
    );
    TimeOfDay? parsedStartTime;
    TimeOfDay? parsedEndTime;

    if (json['startTime'] != null) {
      final List<String> startParts = (json['startTime'] as String).split(':');
      parsedStartTime = TimeOfDay(
        hour: int.parse(startParts[0]),
        minute: int.parse(startParts[1]),
      );
    }

    if (json['endTime'] != null) {
      final List<String> endParts = (json['endTime'] as String).split(':');
      parsedEndTime = TimeOfDay(
        hour: int.parse(endParts[0]),
        minute: int.parse(endParts[1]),
      );
    }

    DateTime? parsedCreatedAt;
    if (json['createdAt'] != null) {
      parsedCreatedAt = DateTime.parse(json['createdAt'] as String);
    }

    return EventItem(
      backendEventId: json['backendEventId'] as String?,
      title: json['text'] as String,
      eventDate: parsedEventDate,
      startTime: parsedStartTime,
      endTime: parsedEndTime,
      createdAt: parsedCreatedAt,
      displayOrder: json['displayOrder'] as int?,
    );
  }

  Map<String, dynamic> toJsonForCreate() {
    final DateFormat dateFormatter = DateFormat('yyyy-MM-dd');
    final String formattedEventDate = dateFormatter.format(eventDate);

    return {
      'text': title,
      'eventDate': formattedEventDate,
      'startTime': startTime != null
          ? '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}'
          : null,
      'endTime': endTime != null
          ? '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}'
          : null,
      'displayOrder': displayOrder,
    };
  }

  Map<String, dynamic> toJsonForUpdate() {
    final Map<String, dynamic> json = toJsonForCreate();
    json['eventId'] = backendEventId;
    return json;
  }

  String _formatTimeOfDay(TimeOfDay? time, BuildContext context) {
    if (time == null) {
      return "미지정";
    }
    return time.format(context);
  }

  String displayTime(BuildContext context) {
    final String start = _formatTimeOfDay(startTime, context);
    final String end = _formatTimeOfDay(endTime, context);

    if (startTime == null && endTime == null) {
      return "시간 미지정";
    }
    return '$start - $end';
  }

  EventItem copyWith({
    String? backendEventId,
    String? title,
    DateTime? eventDate,
    ValueGetter<TimeOfDay?>? startTime,
    ValueGetter<TimeOfDay?>? endTime,
    DateTime? createdAt,
    int? displayOrder,
  }) {
    return EventItem(
      backendEventId: backendEventId ?? this.backendEventId,
      title: title ?? this.title,
      eventDate: eventDate ?? this.eventDate,
      startTime: startTime != null ? startTime() : this.startTime,
      endTime: endTime != null ? endTime() : this.endTime,
      createdAt: createdAt ?? this.createdAt,
      displayOrder: displayOrder ?? this.displayOrder,
    );
  }

  @override
  String toString() {
    String startTimeStr = startTime?.format(Get.context!) ?? "미지정";
    String endTimeStr = endTime?.format(Get.context!) ?? "미지정";
    return 'EventItem(backendEventId: $backendEventId, title: $title, eventDate: ${DateFormat('yyyy-MM-dd').format(eventDate)}, startTime: $startTimeStr, endTime: $endTimeStr, createdAt: $createdAt, displayOrder: $displayOrder)';
  }
}