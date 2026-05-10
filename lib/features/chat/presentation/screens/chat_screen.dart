import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../cubit/chat_cubit.dart';
import '../cubit/chat_state.dart';
import '../widgets/message_bubble.dart';
import '../widgets/typing_indicator.dart';
import '../widgets/chat_input_bar.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/router/app_router.dart';
import '../../../../injection_container.dart';

class ChatScreen extends StatefulWidget {
  final String conversationId;
  final String receiverUid;
  final String receiverName;
  final String receiverPhoto;

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.receiverUid,
    required this.receiverName,
    required this.receiverPhoto,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final ChatCubit _chatCubit;
  late final String _currentUid;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _currentUid = context.read<AuthCubit>().currentUser?.uid ?? '';
    _chatCubit = sl<ChatCubit>();
    _chatCubit.initChat(
      conversationId: widget.conversationId,
      currentUid: _currentUid,
      otherUserId: widget.receiverUid,
    );
  }

  @override
  void dispose() {
    _chatCubit.close();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendText(String text) async {
    if (text.trim().isEmpty) return;
    await _chatCubit.sendTextMessage(
      conversationId: widget.conversationId,
      senderId: _currentUid,
      receiverId: widget.receiverUid,
      content: text.trim(),
    );
    _scrollToBottom();
  }

  Future<void> _sendImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1080,
      imageQuality: 80,
    );
    if (image == null || !mounted) return;
    await _chatCubit.sendImageMessage(
      conversationId: widget.conversationId,
      senderId: _currentUid,
      receiverId: widget.receiverUid,
      imageFile: File(image.path),
    );
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _chatCubit,
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: Column(
          children: [
            // ── Messages List ─────────────────────────────
            Expanded(
              child: BlocBuilder<ChatCubit, ChatState>(
                bloc: _chatCubit,
                builder: (context, state) {
                  if (state is ChatLoading) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primary));
                  } else if (state is ChatLoaded) {
                    if (state.messages.isEmpty) {
                      return const EmptyStateWidget(
                        title: 'No messages yet',
                        subtitle: 'Say hello! 👋',
                        icon: Icons.waving_hand_rounded,
                      );
                    }
                    _scrollToBottom();
                    return _buildMessageList(state);
                  } else if (state is ChatError) {
                    return Center(child: Text(state.message));
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),

            // ── Typing indicator ──────────────────────────
            BlocBuilder<ChatCubit, ChatState>(
              bloc: _chatCubit,
              builder: (context, state) {
                final isTyping = state is ChatLoaded && state.isOtherUserTyping;
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: isTyping
                      ? TypingIndicator(
                          name: widget.receiverName,
                          photoUrl: widget.receiverPhoto,
                        )
                      : const SizedBox.shrink(),
                );
              },
            ),

            // ── Input Bar ─────────────────────────────────
            ChatInputBar(
              onSendText: _sendText,
              onSendImage: _sendImage,
              onTypingChanged: (isTyping) => _chatCubit.onTypingChanged(
                conversationId: widget.conversationId,
                uid: _currentUid,
                isTyping: isTyping,
              ),
              conversationId: widget.conversationId,
              senderId: _currentUid,
              receiverId: widget.receiverUid,
              chatCubit: _chatCubit,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList(ChatLoaded state) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      physics: const BouncingScrollPhysics(),
      itemCount: state.messages.length,
      itemBuilder: (context, index) {
        final message = state.messages[index];
        final isSender = message.senderId == _currentUid;

        // Date section header
        final showDateHeader = index == 0 ||
            !_isSameDay(
              state.messages[index - 1].timestamp,
              message.timestamp,
            );

        return Column(
          children: [
            if (showDateHeader) _buildDateHeader(message.timestamp),
            MessageBubble(
              message: message,
              isSender: isSender,
            ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.1),
          ],
        );
      },
    );
  }

  Widget _buildDateHeader(DateTime date) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            date.toSectionHeader(),
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: () => context.go(AppRouter.home),
      ),
      title: Row(
        children: [
          UserAvatarWidget(
            photoUrl: widget.receiverPhoto,
            name: widget.receiverName,
            radius: 18,
            isOnline: true,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.receiverName,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
                BlocBuilder<ChatCubit, ChatState>(
                  bloc: _chatCubit,
                  builder: (context, state) {
                    final isTyping =
                        state is ChatLoaded && state.isOtherUserTyping;
                    return Text(
                      isTyping ? 'typing...' : 'online',
                      style: TextStyle(
                        fontSize: 12,
                        color: isTyping ? AppColors.primary : AppColors.online,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.videocam_rounded),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.call_rounded),
          onPressed: () {},
        ),
      ],
    );
  }
}
