import 'package:equatable/equatable.dart';

/// Message type enum
enum MessageType { text, image, voice }

/// Message delivery status
enum MessageStatus { sending, sent, delivered, read }

/// Message entity for the domain layer
class MessageEntity extends Equatable {
  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final MessageType type;
  final MessageStatus status;
  final DateTime timestamp;
  final String? mediaUrl;
  final int? voiceDuration; // in seconds

  const MessageEntity({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.type,
    required this.status,
    required this.timestamp,
    this.mediaUrl,
    this.voiceDuration,
  });

  @override
  List<Object?> get props => [id, senderId, content, status, timestamp];
}

/// Conversation entity for the domain layer
class ConversationEntity extends Equatable {
  final String id;
  final List<String> participants;
  final String lastMessageContent;
  final String lastMessageSenderId;
  final MessageType lastMessageType;
  final DateTime lastMessageTime;
  final Map<String, int> unreadCount;

  const ConversationEntity({
    required this.id,
    required this.participants,
    required this.lastMessageContent,
    required this.lastMessageSenderId,
    required this.lastMessageType,
    required this.lastMessageTime,
    required this.unreadCount,
  });

  @override
  List<Object?> get props => [id, participants, lastMessageTime];
}
