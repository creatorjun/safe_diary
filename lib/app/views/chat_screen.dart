// lib/app/views/chat_screen.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:no_screenshot/no_screenshot.dart';
import 'package:safe_diary/app/routes/app_pages.dart';
import 'package:safe_diary/app/utils/app_strings.dart';

import '../controllers/chat_controller.dart';
import '../controllers/login_controller.dart';
import '../models/chat_models.dart';
import '../theme/app_theme.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final ChatController controller = Get.find<ChatController>();
  final NoScreenshot _noScreenshot = NoScreenshot.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _toggleScreenshotProtection(true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _toggleScreenshotProtection(false);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if (Get.currentRoute == Routes.chat) {
        Get.offAllNamed(Routes.home);
      }
    }
  }

  Future<void> _toggleScreenshotProtection(bool turnOff) async {
    try {
      if (turnOff) {
        await _noScreenshot.screenshotOff();
        if (kDebugMode) {
          print('[ChatScreen] Screenshot protection enabled.');
        }
      } else {
        await _noScreenshot.screenshotOn();
        if (kDebugMode) {
          print('[ChatScreen] Screenshot protection disabled.');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('[ChatScreen] Failed to toggle screenshot protection: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final LoginController loginController = Get.find<LoginController>();
    final String currentUserUid = loginController.user.id ?? "";
    final ThemeData theme = Theme.of(context);
    final AppTextStyles textStyles = theme.extension<AppTextStyles>()!;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.chatRoomTitle(controller.chatPartnerNickname),
            style: textStyles.bodyLarge),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: AppStrings.refreshMessages,
            onPressed: () {
              controller.fetchInitialMessages();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.messages.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.hasInitialLoadError.value) {
                return _buildErrorView(context);
              }

              if (controller.messages.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      AppStrings.noMessages,
                      style: textStyles.bodyMedium
                          .copyWith(color: theme.colorScheme.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              return ListView.builder(
                controller: controller.scrollController,
                reverse: true,
                padding: const EdgeInsets.all(8.0),
                itemCount: controller.messages.length +
                    (controller.isFetchingMore.value ? 1 : 0),
                itemBuilder: (context, index) {
                  if (controller.isFetchingMore.value &&
                      index == controller.messages.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2.0),
                      ),
                    );
                  }
                  final message = controller
                      .messages[controller.messages.length - 1 - index];
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

  Widget _buildErrorView(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppTextStyles textStyles = theme.extension<AppTextStyles>()!;
    final AppSpacing spacing = theme.extension<AppSpacing>()!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: theme.colorScheme.error, size: 48),
            SizedBox(height: spacing.medium),
            Text(
              AppStrings.messageLoadError,
              style: textStyles.bodyLarge.copyWith(color: theme.colorScheme.error),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(
      BuildContext context,
      ChatMessage message,
      bool isMe,
      ) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final AppTextStyles textStyles = theme.extension<AppTextStyles>()!;
    final AppSpacing spacing = theme.extension<AppSpacing>()!;

    final align = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
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

    return Column(
      crossAxisAlignment: align,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          padding:
          const EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0),
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
            style: textStyles.bodyMedium.copyWith(color: textColor, height: 1.4),
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
                SizedBox(width: spacing.small),
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

  Widget _buildMessageInputField(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppTextStyles textStyles = theme.extension<AppTextStyles>()!;
    final AppSpacing spacing = theme.extension<AppSpacing>()!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -1),
            blurRadius: 4,
            color: theme.shadowColor.withAlpha(50),
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
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(24.0),
                ),
                child: TextField(
                  controller: controller.messageInputController,
                  style: textStyles.bodyMedium,
                  decoration: InputDecoration(
                    hintText: AppStrings.messageInputHint,
                    hintStyle: textStyles.bodyMedium.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 1,
                  maxLines: 5,
                  onSubmitted: (value) => controller.sendMessage(),
                ),
              ),
            ),
            SizedBox(width: spacing.small),
            Material(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(24.0),
              child: InkWell(
                borderRadius: BorderRadius.circular(24.0),
                onTap: controller.sendMessage,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Icon(
                    Icons.send_rounded,
                    color: theme.colorScheme.onPrimary,
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