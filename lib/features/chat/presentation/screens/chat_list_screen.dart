import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../cubit/chat_list_cubit.dart';
import '../cubit/chat_list_state.dart';
import '../../domain/entities/chat_entities.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../users/data/datasources/users_remote_datasource.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../injection_container.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    final uid = context.read<AuthCubit>().currentUser?.uid ?? '';
    context.read<ChatListCubit>().loadConversations(uid);
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthCubit>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ChatApp'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => context.push(AppRouter.users),
          ),
          GestureDetector(
            onTap: () => context.push(AppRouter.profile),
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: UserAvatarWidget(
                photoUrl: currentUser?.photoUrl,
                name: currentUser?.displayName ?? '?',
                radius: 18,
                isOnline: true,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRouter.users),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.chat_rounded, color: Colors.white),
      ).animate().scale(delay: 300.ms),
      body: BlocBuilder<ChatListCubit, ChatListState>(
        builder: (context, state) {
          if (state is ChatListLoading) {
            return _buildShimmer();
          } else if (state is ChatListError) {
            return EmptyStateWidget(
              title: 'Something went wrong',
              subtitle: state.message,
              icon: Icons.error_outline_rounded,
            );
          } else if (state is ChatListLoaded) {
            if (state.conversations.isEmpty) {
              return const EmptyStateWidget(
                title: 'No conversations yet',
                subtitle:
                    'Tap the chat button below to start a new conversation',
                icon: Icons.chat_bubble_outline_rounded,
              );
            }
            return _buildConversationList(state.conversations, currentUser?.uid ?? '');
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildConversationList(
      List<ConversationEntity> conversations, String currentUid) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: conversations.length,
      separatorBuilder: (_, __) => const Divider(height: 1, indent: 76),
      itemBuilder: (context, index) {
        final conv = conversations[index];
        final otherUid = conv.participants.firstWhere(
          (id) => id != currentUid,
          orElse: () => '',
        );
        final unread = conv.unreadCount[currentUid] ?? 0;

        return FutureBuilder(
          future: sl<UsersRemoteDatasource>().getUserById(otherUid),
          builder: (context, snapshot) {
            final user = snapshot.data;
            final name = user?.displayName ?? 'Loading...';
            final photo = user?.photoUrl ?? '';
            final isOnline = user?.isOnline ?? false;

            return _ConversationTile(
              conversationId: conv.id,
              receiverUid: otherUid,
              receiverName: name,
              receiverPhoto: photo,
              isOnline: isOnline,
              lastMessage: _formatLastMessage(conv),
              timestamp: conv.lastMessageTime.toChatDateString(),
              unreadCount: unread,
              onTap: () => context.push(
                '${AppRouter.chat}/${conv.id}?receiverUid=$otherUid&receiverName=${Uri.encodeComponent(name)}&receiverPhoto=${Uri.encodeComponent(photo)}',
              ),
            ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.05);
          },
        );
      },
    );
  }

  String _formatLastMessage(ConversationEntity conv) {
    switch (conv.lastMessageType) {
      case MessageType.image:
        return '📷 Photo';
      case MessageType.voice:
        return '🎤 Voice message';
      case MessageType.text:
        return conv.lastMessageContent;
    }
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.surface,
      highlightColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
      child: ListView.builder(
        itemCount: 8,
        itemBuilder: (_, __) => ListTile(
          leading: const CircleAvatar(radius: 28),
          title: Container(height: 14, color: Colors.white),
          subtitle: Container(height: 12, color: Colors.white),
        ),
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final String conversationId;
  final String receiverUid;
  final String receiverName;
  final String receiverPhoto;
  final bool isOnline;
  final String lastMessage;
  final String timestamp;
  final int unreadCount;
  final VoidCallback onTap;

  const _ConversationTile({
    required this.conversationId,
    required this.receiverUid,
    required this.receiverName,
    required this.receiverPhoto,
    required this.isOnline,
    required this.lastMessage,
    required this.timestamp,
    required this.unreadCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            UserAvatarWidget(
              photoUrl: receiverPhoto,
              name: receiverName,
              radius: 28,
              isOnline: isOnline,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          receiverName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: unreadCount > 0
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        timestamp,
                        style: TextStyle(
                          fontSize: 12,
                          color: unreadCount > 0
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          fontWeight: unreadCount > 0
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lastMessage.isEmpty ? 'Say hello 👋' : lastMessage,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: unreadCount > 0
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (unreadCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          child: Text(
                            unreadCount > 99 ? '99+' : '$unreadCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
