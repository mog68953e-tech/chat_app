import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/services/firebase_services.dart';
import '../../domain/entities/chat_entities.dart';
import '../../domain/repositories/i_chat_repository.dart';
import '../models/chat_models.dart';

/// Firestore implementation of IChatRepository
class ChatRepositoryImpl implements IChatRepository {
  final FirestoreService _firestoreService;
  final StorageService _storageService;
  final Uuid _uuid;

  ChatRepositoryImpl({
    required FirestoreService firestoreService,
    required StorageService storageService,
    required Uuid uuid,
  })  : _firestoreService = firestoreService,
        _storageService = storageService,
        _uuid = uuid;

  @override
  Stream<List<MessageEntity>> getMessagesStream(String conversationId) {
    return _firestoreService.instance
        .collection(AppConstants.conversationsCollection)
        .doc(conversationId)
        .collection(AppConstants.messagesCollection)
        .orderBy('timestamp', descending: false)
        .limitToLast(AppConstants.messagesPerPage)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => MessageModel.fromFirestore(d)).toList());
  }

  @override
  Stream<List<ConversationEntity>> getConversationsStream(String uid) {
    return _firestoreService.instance
        .collection(AppConstants.conversationsCollection)
        .where('participants', arrayContains: uid)
        .snapshots()
        .map((snap) {
      final list = snap.docs.map((d) => ConversationModel.fromFirestore(d)).toList();
      list.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
      return list;
    });
  }

  @override
  Future<Either<Failure, void>> sendTextMessage({
    required String conversationId,
    required String senderId,
    required String receiverId,
    required String content,
  }) async {
    try {
      await _sendMessage(
        conversationId: conversationId,
        senderId: senderId,
        receiverId: receiverId,
        content: content,
        type: MessageType.text,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendImageMessage({
    required String conversationId,
    required String senderId,
    required String receiverId,
    required File imageFile,
  }) async {
    try {
      final url =
          await _storageService.uploadChatImage(imageFile, conversationId);
      await _sendMessage(
        conversationId: conversationId,
        senderId: senderId,
        receiverId: receiverId,
        content: '📷 Photo',
        type: MessageType.image,
        mediaUrl: url,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendVoiceMessage({
    required String conversationId,
    required String senderId,
    required String receiverId,
    required File voiceFile,
    required int durationSeconds,
  }) async {
    try {
      final url =
          await _storageService.uploadVoiceMessage(voiceFile, conversationId);
      await _sendMessage(
        conversationId: conversationId,
        senderId: senderId,
        receiverId: receiverId,
        content: '🎤 Voice message',
        type: MessageType.voice,
        mediaUrl: url,
        voiceDuration: durationSeconds,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateMessageStatus({
    required String conversationId,
    required String messageId,
    required MessageStatus status,
  }) async {
    try {
      await _firestoreService.updateDocument(
        path:
            '${AppConstants.conversationsCollection}/$conversationId/${AppConstants.messagesCollection}/$messageId',
        data: {'status': status.name},
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markConversationAsRead({
    required String conversationId,
    required String uid,
  }) async {
    try {
      await _firestoreService.updateDocument(
        path: '${AppConstants.conversationsCollection}/$conversationId',
        data: {'unreadCount.$uid': 0},
      );

      // Batch update unread messages to 'read'
      final messagesSnap = await _firestoreService.instance
          .collection(AppConstants.conversationsCollection)
          .doc(conversationId)
          .collection(AppConstants.messagesCollection)
          .where('senderId', isNotEqualTo: uid)
          .where('status', isEqualTo: 'delivered')
          .get();

      final batch = _firestoreService.instance.batch();
      for (final doc in messagesSnap.docs) {
        batch.update(doc.reference, {'status': MessageStatus.read.name});
      }
      await batch.commit();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateTypingStatus({
    required String conversationId,
    required String uid,
    required bool isTyping,
  }) async {
    try {
      await _firestoreService.updateDocument(
        path: '${AppConstants.conversationsCollection}/$conversationId',
        data: {'typing.$uid': isTyping},
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<bool> getTypingStatusStream({
    required String conversationId,
    required String otherUserId,
  }) {
    return _firestoreService
        .documentStream(
            '${AppConstants.conversationsCollection}/$conversationId')
        .map((doc) {
      if (!doc.exists) return false;
      final data = doc.data();
      final typing = data?['typing'] as Map<String, dynamic>? ?? {};
      return typing[otherUserId] as bool? ?? false;
    });
  }

  @override
  Future<Either<Failure, String>> getOrCreateConversation({
    required String currentUid,
    required String otherUid,
  }) async {
    try {
      // Check if conversation already exists
      final existing = await _firestoreService.instance
          .collection(AppConstants.conversationsCollection)
          .where('participants', arrayContains: currentUid)
          .get();

      for (final doc in existing.docs) {
        final participants =
            List<String>.from(doc.data()['participants'] as List? ?? []);
        if (participants.contains(otherUid)) {
          return Right(doc.id);
        }
      }

      // Create new conversation
      final conversationId = _uuid.v4();
      await _firestoreService.setDocument(
        path: '${AppConstants.conversationsCollection}/$conversationId',
        data: {
          'participants': [currentUid, otherUid],
          'lastMessage': {
            'content': '',
            'senderId': '',
            'type': 'text',
            'timestamp': FieldValue.serverTimestamp(),
          },
          'unreadCount': {currentUid: 0, otherUid: 0},
          'typing': {currentUid: false, otherUid: false},
          'updatedAt': FieldValue.serverTimestamp(),
        },
        merge: false,
      );

      return Right(conversationId);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteMessage({
    required String conversationId,
    required String messageId,
  }) async {
    try {
      await _firestoreService.deleteDocument(
        '${AppConstants.conversationsCollection}/$conversationId/${AppConstants.messagesCollection}/$messageId',
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // ── Private helpers ──────────────────────────────────────────

  Future<void> _sendMessage({
    required String conversationId,
    required String senderId,
    required String receiverId,
    required String content,
    required MessageType type,
    String? mediaUrl,
    int? voiceDuration,
  }) async {
    final messageId = _uuid.v4();
    final messageData = {
      'conversationId': conversationId,
      'senderId': senderId,
      'content': content,
      'type': type.name,
      'status': MessageStatus.sending.name,
      'timestamp': FieldValue.serverTimestamp(),
      if (mediaUrl != null) 'mediaUrl': mediaUrl,
      if (voiceDuration != null) 'voiceDuration': voiceDuration,
    };

    // Add message to subcollection
    await _firestoreService.instance
        .collection(AppConstants.conversationsCollection)
        .doc(conversationId)
        .collection(AppConstants.messagesCollection)
        .doc(messageId)
        .set(messageData);

    // Update conversation last message & unread count
    await _firestoreService.updateDocument(
      path: '${AppConstants.conversationsCollection}/$conversationId',
      data: {
        'lastMessage': {
          'content': content,
          'senderId': senderId,
          'type': type.name,
          'timestamp': FieldValue.serverTimestamp(),
        },
        'unreadCount.$receiverId': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    );

    // Update status to 'sent'
    await _firestoreService.updateDocument(
      path:
          '${AppConstants.conversationsCollection}/$conversationId/${AppConstants.messagesCollection}/$messageId',
      data: {'status': MessageStatus.sent.name},
    );
  }
}
