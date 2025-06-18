// lib/app/views/widgets/chat_message_bubble.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:safe_diary/app/models/chat_models.dart';
import 'package:safe_diary/app/theme/app_theme.dart';
import 'package:safe_diary/app/utils/app_strings.dart';

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;

  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppTextStyles textStyles = theme.extension<AppTextStyles>()!;
    final ColorScheme colorScheme = theme.colorScheme;
    final align = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    return Column(
      crossAxisAlignment: align,
      children: [
        _buildBubbleContent(context),
        Padding(
          padding: isMe
              ? const EdgeInsets.only(right: 10.0, bottom: 6.0)
              : const EdgeInsets.only(left: 10.0, bottom: 6.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (isMe &&
                  message.id != null &&
                  !(message.id!.startsWith('temp_')) &&
                  !message.isRead) ...[
                Text(
                  AppStrings.unread,
                  style: textStyles.bodyMedium.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 4.0),
              ],
              Text(
                DateFormat('HH:mm').format(message.dateTime.toLocal()),
                style: textStyles.bodyMedium.copyWith(
                  fontSize: 11,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBubbleContent(BuildContext context) {
    switch (message.type) {
      case MessageType.date:
        return _buildDateBubble(context);
      case MessageType.schedule:
        return _buildScheduleBubble(context);
      case MessageType.chat:
      default:
        return _buildTextBubble(context);
    }
  }

  Widget _buildTextBubble(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final AppTextStyles textStyles = theme.extension<AppTextStyles>()!;

    final bubbleColor =
    isMe ? colorScheme.primary : colorScheme.surfaceContainerHighest;
    final textColor =
    isMe ? colorScheme.onPrimary : colorScheme.onSurfaceVariant;
    final radius = isMe
        ? const BorderRadius.only(
      topLeft: Radius.circular(16),
      bottomLeft: Radius.circular(16),
      bottomRight: Radius.circular(16),
    )
        : const BorderRadius.only(
      topRight: Radius.circular(16),
      bottomLeft: Radius.circular(16),
      bottomRight: Radius.circular(16),
    );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.65,
      ),
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withAlpha(50),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        message.content ?? '',
        style: textStyles.bodyMedium.copyWith(
          color: textColor,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildDateBubble(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppTextStyles textStyles = theme.extension<AppTextStyles>()!;
    final ColorScheme colorScheme = theme.colorScheme;
    String formattedDate = '';
    try {
      final date = DateTime.parse(message.content!);
      formattedDate = DateFormat('yyyy년 MM월 dd일 (E)', 'ko_KR').format(date);
    } catch (e) {
      formattedDate = '잘못된 날짜 형식';
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      color: isMe
          ? colorScheme.primaryContainer
          : colorScheme.secondaryContainer.withAlpha(150),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        child: IntrinsicWidth(
          child: Column(
            crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.sharedADate,
                style: textStyles.bodyMedium.copyWith(
                    color: isMe
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_month_outlined,
                    size: 20,
                    color: isMe
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSecondaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      formattedDate,
                      style: textStyles.bodyLarge.copyWith(
                        color: isMe
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleBubble(BuildContext context) {
    if (message.eventDetails == null) return const SizedBox.shrink();

    final ThemeData theme = Theme.of(context);
    final AppTextStyles textStyles = theme.extension<AppTextStyles>()!;
    final ColorScheme colorScheme = theme.colorScheme;
    final details = message.eventDetails!;

    String scheduleDate = '';
    if (details.eventDate != null) {
      try {
        final date = DateTime.parse(details.eventDate!);
        scheduleDate = DateFormat('yy.MM.dd (E)', 'ko_KR').format(date);
      } catch (e) {
        //
      }
    }

    String scheduleTime = '시간 미지정';
    if (details.startTime != null) {
      scheduleTime =
      '${details.startTime}${details.endTime != null ? ' ~ ${details.endTime}' : ''}';
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      color: isMe
          ? colorScheme.primaryContainer
          : colorScheme.secondaryContainer.withAlpha(150),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        child: IntrinsicWidth(
          child: Column(
            crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.sharedASchedule,
                style: textStyles.bodyMedium.copyWith(
                  fontSize: 12,
                  color: (isMe
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSecondaryContainer)
                      .withAlpha(200),
                ),
              ),
              const Divider(height: 12),
              Text(
                details.text,
                style: textStyles.bodyLarge.copyWith(
                  color: isMe
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSecondaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              if (scheduleDate.isNotEmpty)
                Text(
                  scheduleDate,
                  style: textStyles.bodyMedium.copyWith(
                    color: (isMe
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSecondaryContainer)
                        .withAlpha(200),
                  ),
                ),
              const SizedBox(height: 2),
              Text(
                scheduleTime,
                style: textStyles.bodyMedium.copyWith(
                  color: (isMe
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSecondaryContainer)
                      .withAlpha(200),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}