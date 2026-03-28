import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/i_chat_repository.dart';
import 'chat_list_state.dart';
/// Manages the list of all active conversations for the home screen
class ChatListCubit extends Cubit<ChatListState> {
  final IChatRepository _chatRepository;
  StreamSubscription? _conversationsSub;

  ChatListCubit(this._chatRepository) : super(ChatListInitial());

  void loadConversations(String uid) {
    emit(ChatListLoading());
    _conversationsSub = _chatRepository
        .getConversationsStream(uid)
        .listen(
      (conversations) => emit(ChatListLoaded(conversations)),
      onError: (e) => emit(ChatListError(e.toString())),
    );
  }

  @override
  Future<void> close() {
    _conversationsSub?.cancel();
    return super.close();
  }
}
