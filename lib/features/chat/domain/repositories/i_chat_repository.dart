import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/chat_entities.dart';

/// Chat repository contract
abstract class IChatRepository {
  /// Stream of messages for a conversation
  Stream<List<MessageEntity>> getMessagesStream(String conversationId);

  /// Stream of all conversations for the current user
  Stream<List<ConversationEntity>> getConversationsStream(String uid);

  /// Send a text message
  Future<Either<Failure, void>> sendTextMessage({
    required String conversationId,
    required String senderId,
    required String receiverId,
    required String content,
  });

  /// Send an image message
  Future<Either<Failure, void>> sendImageMessage({
    required String conversationId,
    required String senderId,
    required String receiverId,
    required File imageFile,
  });

  /// Send a voice message
  Future<Either<Failure, void>> sendVoiceMessage({
    required String conversationId,
    required String senderId,
    required String receiverId,
    required File voiceFile,
    required int durationSeconds,
  });

  /// Update message status (sent→delivered→read)
  Future<Either<Failure, void>> updateMessageStatus({
    required String conversationId,
    required String messageId,
    required MessageStatus status,
  });

  /// Mark all messages in a conversation as read for a user
  Future<Either<Failure, void>> markConversationAsRead({
    required String conversationId,
    required String uid,
  });

  /// Update typing status
  Future<Either<Failure, void>> updateTypingStatus({
    required String conversationId,
    required String uid,
    required bool isTyping,
  });

  /// Stream of typing status for the other user
  Stream<bool> getTypingStatusStream({
    required String conversationId,
    required String otherUserId,
  });

  /// Get or create a conversation between two users
  Future<Either<Failure, String>> getOrCreateConversation({
    required String currentUid,
    required String otherUid,
  });

  /// Delete a message
  Future<Either<Failure, void>> deleteMessage({
    required String conversationId,
    required String messageId,
  });
}
