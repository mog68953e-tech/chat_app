import 'dart:async';
import 'dart:io';
import 'package:chat_app/features/chat/presentation/cubit/chat_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/repositories/i_chat_repository.dart';

/// Manages a single chat room: messages, typing, and media sending
class ChatCubit extends Cubit<ChatState> {
  final IChatRepository _chatRepository;
  StreamSubscription? _messagesSub;
  StreamSubscription? _typingSub;
  Timer? _typingTimer;

  ChatCubit(this._chatRepository) : super(ChatInitial());

  void initChat({
    required String conversationId,
    required String currentUid,
    required String otherUserId,
  }) {
    emit(ChatLoading());

    // Listen to messages stream
    _messagesSub = _chatRepository.getMessagesStream(conversationId).listen(
      (messages) {
        final currentState = state;
        final isTyping =
            currentState is ChatLoaded ? currentState.isOtherUserTyping : false;
        emit(ChatLoaded(messages: messages, isOtherUserTyping: isTyping));
        // Mark messages as read
        _chatRepository.markConversationAsRead(
          conversationId: conversationId,
          uid: currentUid,
        );
      },
      onError: (e) => emit(ChatError(e.toString())),
    );

    // Listen to typing status of the other user
    _typingSub = _chatRepository
        .getTypingStatusStream(
      conversationId: conversationId,
      otherUserId: otherUserId,
    )
        .listen((isTyping) {
      final currentState = state;
      if (currentState is ChatLoaded) {
        emit(currentState.copyWith(isOtherUserTyping: isTyping));
      }
    });
  }

  Future<void> sendTextMessage({
    required String conversationId,
    required String senderId,
    required String receiverId,
    required String content,
  }) async {
    final result = await _chatRepository.sendTextMessage(
      conversationId: conversationId,
      senderId: senderId,
      receiverId: receiverId,
      content: content,
    );
    result.fold(
      (failure) => emit(ChatError(failure.message)),
      (_) {},
    );
  }

  Future<void> sendImageMessage({
    required String conversationId,
    required String senderId,
    required String receiverId,
    required File imageFile,
  }) async {
    final result = await _chatRepository.sendImageMessage(
      conversationId: conversationId,
      senderId: senderId,
      receiverId: receiverId,
      imageFile: imageFile,
    );
    result.fold(
      (failure) => emit(ChatError(failure.message)),
      (_) {},
    );
  }

  Future<void> sendVoiceMessage({
    required String conversationId,
    required String senderId,
    required String receiverId,
    required File voiceFile,
    required int durationSeconds,
  }) async {
    final result = await _chatRepository.sendVoiceMessage(
      conversationId: conversationId,
      senderId: senderId,
      receiverId: receiverId,
      voiceFile: voiceFile,
      durationSeconds: durationSeconds,
    );
    result.fold(
      (failure) => emit(ChatError(failure.message)),
      (_) {},
    );
  }

  Future<void> onTypingChanged({
    required String conversationId,
    required String uid,
    required bool isTyping,
  }) async {
    _typingTimer?.cancel();
    await _chatRepository.updateTypingStatus(
      conversationId: conversationId,
      uid: uid,
      isTyping: isTyping,
    );
    if (isTyping) {
      _typingTimer = Timer(AppConstants.typingTimeout, () {
        _chatRepository.updateTypingStatus(
          conversationId: conversationId,
          uid: uid,
          isTyping: false,
        );
      });
    }
  }

  @override
  Future<void> close() {
    _messagesSub?.cancel();
    _typingSub?.cancel();
    _typingTimer?.cancel();
    return super.close();
  }
}
