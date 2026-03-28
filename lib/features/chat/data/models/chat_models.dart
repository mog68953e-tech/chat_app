import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/chat_entities.dart';

/// Firestore data model for MessageEntity
class MessageModel extends MessageEntity {
  const MessageModel({
    required super.id,
    required super.conversationId,
    required super.senderId,
    required super.content,
    required super.type,
    required super.status,
    required super.timestamp,
    super.mediaUrl,
    super.voiceDuration,
  });

  factory MessageModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return MessageModel(
      id: doc.id,
      conversationId: data['conversationId'] as String? ?? '',
      senderId: data['senderId'] as String? ?? '',
      content: data['content'] as String? ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.name == (data['type'] as String? ?? 'text'),
        orElse: () => MessageType.text,
      ),
      status: MessageStatus.values.firstWhere(
        (e) => e.name == (data['status'] as String? ?? 'sent'),
        orElse: () => MessageStatus.sent,
      ),
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      mediaUrl: data['mediaUrl'] as String?,
      voiceDuration: data['voiceDuration'] as int?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'conversationId': conversationId,
      'senderId': senderId,
      'content': content,
      'type': type.name,
      'status': status.name,
      'timestamp': FieldValue.serverTimestamp(),
      'mediaUrl': mediaUrl,
      'voiceDuration': voiceDuration,
    };
  }
}

/// Firestore data model for ConversationEntity
class ConversationModel extends ConversationEntity {
  const ConversationModel({
    required super.id,
    required super.participants,
    required super.lastMessageContent,
    required super.lastMessageSenderId,
    required super.lastMessageType,
    required super.lastMessageTime,
    required super.unreadCount,
  });

  factory ConversationModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final lastMsg = data['lastMessage'] as Map<String, dynamic>? ?? {};
    return ConversationModel(
      id: doc.id,
      participants: List<String>.from(data['participants'] as List? ?? []),
      lastMessageContent: lastMsg['content'] as String? ?? '',
      lastMessageSenderId: lastMsg['senderId'] as String? ?? '',
      lastMessageType: MessageType.values.firstWhere(
        (e) => e.name == (lastMsg['type'] as String? ?? 'text'),
        orElse: () => MessageType.text,
      ),
      lastMessageTime:
          (lastMsg['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      unreadCount: Map<String, int>.from(
          (data['unreadCount'] as Map<String, dynamic>? ?? {})
              .map((k, v) => MapEntry(k, (v as num).toInt()))),
    );
  }

  Map<String, dynamic> toFirestore({
    required Map<String, dynamic> lastMessage,
    required List<String> participants,
    required Map<String, int> unreadCount,
  }) {
    return {
      'participants': participants,
      'lastMessage': lastMessage,
      'unreadCount': unreadCount,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
