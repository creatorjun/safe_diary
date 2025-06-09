// lib/app/views/chat_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/chat_controller.dart';
import '../controllers/login_controller.dart';
import '../models/chat_models.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';

class ChatScreen extends GetView<ChatController> {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginController loginController = Get.find<LoginController>();
    final String currentUserUid = loginController.user.id ?? "";

    return Scaffold(
      appBar: AppBar(
        title: Text(
          controller.chatPartnerNickname,
          style: textStyleMedium,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "메시지 새로고침",
            onPressed: () {
              controller.fetchInitialMessages();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Obx(() {
            if (controller.errorMessage.value.isNotEmpty && controller.messages.isEmpty) {
              return Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                        verticalSpaceMedium,
                        Text(
                          "메시지를 불러오는 중 오류 발생",
                          style: textStyleMedium.copyWith(color: Colors.redAccent),
                          textAlign: TextAlign.center,
                        ),
                        verticalSpaceSmall,
                        Text(
                          controller.errorMessage.value,
                          style: textStyleSmall.copyWith(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.messages.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.messages.isEmpty && !controller.isLoading.value) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "아직 메시지가 없습니다.\n첫 메시지를 보내보세요!",
                      style: textStyleSmall.copyWith(color: Colors.grey.shade600),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              return ListView.builder(
                controller: controller.scrollController,
                reverse: true,
                padding: const EdgeInsets.all(8.0),
                itemCount: controller.messages.length + (controller.isFetchingMore.value ? 1 : 0),
                itemBuilder: (context, index) {
                  if (controller.isFetchingMore.value && index == controller.messages.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2.0)),
                    );
                  }
                  final message = controller.messages[controller.messages.length - 1 - index];
                  final bool isMe = message.senderUid == currentUserUid;
                  return _buildMessageBubble(context, message, isMe);
                },
              );
            }),
          ),
          _buildMessageInputField(context),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, ChatMessage message, bool isMe) {
    final align = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bubbleColor = isMe ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surfaceContainerHighest;
    final textColor = isMe ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurfaceVariant;
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

    return Column(
      crossAxisAlignment: align,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
          decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: radius,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(95),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                )
              ]
          ),
          child: Text(
            message.content ?? '',
            style: textStyleSmall.copyWith(color: textColor, height: 1.4),
          ),
        ),
        Padding(
          padding: isMe
              ? const EdgeInsets.only(right: 10.0, bottom: 6.0)
              : const EdgeInsets.only(left: 10.0, bottom: 6.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ✅ [최종 수정됨] 내가 보낸 메시지에 대해서만 '읽음'/'안읽음' 상태 표시
              if (isMe && message.id != null && !(message.id!.startsWith('temp_'))) ...[
                Text(
                  message.isRead ? '읽음' : '안 읽음',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: message.isRead ? Colors.blueAccent : Colors.grey.shade500,
                  ),
                ),
                horizontalSpaceSmall,
              ],
              Text(
                DateFormat('HH:mm').format(message.dateTime.toLocal()),
                style: textStyleSmall.copyWith(
                    fontSize: 11, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageInputField(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -1),
            blurRadius: 4,
            color: Colors.black.withAlpha(95),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(24.0),
                ),
                child: TextField(
                  controller: controller.messageInputController,
                  style: textStyleSmall,
                  decoration: InputDecoration(
                    hintText: "메시지를 입력하세요...",
                    hintStyle: textStyleSmall.copyWith(color: Colors.grey.shade500),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 1,
                  maxLines: 5,
                  onSubmitted: (value) => controller.sendMessage(),
                ),
              ),
            ),
            horizontalSpaceSmall,
            Material(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(24.0),
              child: InkWell(
                borderRadius: BorderRadius.circular(24.0),
                onTap: controller.sendMessage,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Icon(
                    Icons.send_rounded,
                    color: Theme.of(context).colorScheme.onPrimary,
                    size: 22,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}