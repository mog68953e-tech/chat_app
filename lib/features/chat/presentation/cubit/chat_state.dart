import 'package:equatable/equatable.dart';
import '../../domain/entities/chat_entities.dart';

abstract class ChatState extends Equatable {
  const ChatState();
  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}
class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<MessageEntity> messages;
  final bool isOtherUserTyping;

  const ChatLoaded({
    required this.messages,
    this.isOtherUserTyping = false,
  });

  ChatLoaded copyWith({List<MessageEntity>? messages, bool? isOtherUserTyping}) {
    return ChatLoaded(
      messages: messages ?? this.messages,
      isOtherUserTyping: isOtherUserTyping ?? this.isOtherUserTyping,
    );
  }

  @override
  List<Object?> get props => [messages, isOtherUserTyping];
}

class ChatError extends ChatState {
  final String message;
  const ChatError(this.message);
  @override
  List<Object?> get props => [message];
}

