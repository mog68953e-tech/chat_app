import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/chat_entities.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/extensions/extensions.dart';

/// Message bubble for both sender and receiver
class MessageBubble extends StatelessWidget {
  final MessageEntity message;
  final bool isSender;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isSender,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bubbleColor = isSender
        ? (isDark ? AppColors.darkBubbleSend : AppColors.lightBubbleSend)
        : (isDark ? AppColors.darkBubbleReceive : AppColors.lightBubbleReceive);

    final textColor = isSender
        ? (isDark ? Colors.white : AppColors.textPrimaryLight)
        : (isDark ? Colors.white : AppColors.textPrimaryLight);

    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        margin: EdgeInsets.only(
          top: 2,
          bottom: 2,
          left: isSender ? 48 : 8,
          right: isSender ? 8 : 48,
        ),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isSender ? 18 : 4),
            bottomRight: Radius.circular(isSender ? 4 : 18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: _buildContent(context, textColor),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Color textColor) {
    switch (message.type) {
      case MessageType.text:
        return _buildTextContent(textColor);
      case MessageType.image:
        return _buildImageContent(context);
      case MessageType.voice:
        return _buildVoiceContent(textColor);
    }
  }

  Widget _buildTextContent(Color textColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
      child: Column(
        crossAxisAlignment:
            isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message.content,
            style: TextStyle(color: textColor, fontSize: 15, height: 1.4),
          ),
          const SizedBox(height: 4),
          _buildTimestampRow(textColor),
        ],
      ),
    );
  }

  Widget _buildImageContent(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: const Radius.circular(18),
        topRight: const Radius.circular(18),
        bottomLeft: Radius.circular(isSender ? 18 : 4),
        bottomRight: Radius.circular(isSender ? 4 : 18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (message.mediaUrl != null)
            CachedNetworkImage(
              imageUrl: message.mediaUrl!,
              width: 240,
              height: 200,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                width: 240,
                height: 200,
                color: AppColors.darkCard,
                child: const Center(
                    child: CircularProgressIndicator(color: AppColors.primary)),
              ),
              errorWidget: (_, __, ___) =>
                  const Icon(Icons.broken_image_rounded),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 4, 10, 7),
            child: _buildTimestampRow(Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceContent(Color textColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.play_circle_fill_rounded,
              color: AppColors.primary, size: 36),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 3,
                  width: 120,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message.voiceDuration != null
                      ? _formatDuration(message.voiceDuration!)
                      : '0:00',
                  style: TextStyle(
                      color: textColor.withValues(alpha: 0.7), fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _buildTimestampRow(textColor, compact: true),
        ],
      ),
    );
  }

  Widget _buildTimestampRow(Color textColor, {bool compact = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          message.timestamp.toTimeString(),
          style: TextStyle(
            color: textColor.withValues(alpha: 0.55),
            fontSize: 11,
          ),
        ),
        if (isSender) ...[
          const SizedBox(width: 4),
          _buildStatusIcon(),
        ],
      ],
    );
  }

  Widget _buildStatusIcon() {
    switch (message.status) {
      case MessageStatus.sending:
        return const Icon(Icons.access_time_rounded,
            size: 13, color: AppColors.textSecondary);
      case MessageStatus.sent:
        return const Icon(Icons.done_rounded,
            size: 13, color: AppColors.textSecondary);
      case MessageStatus.delivered:
        return const Icon(Icons.done_all_rounded,
            size: 13, color: AppColors.textSecondary);
      case MessageStatus.read:
        return const Icon(Icons.done_all_rounded,
            size: 13, color: AppColors.primary);
    }
  }

  String _formatDuration(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '$mins:${secs.toString().padLeft(2, '0')}';
  }
}
