import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../cubit/users_cubit.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../chat/domain/repositories/i_chat_repository.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../../../injection_container.dart';

/// Searchable list of all registered users to start a new conversation
class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final uid = context.read<AuthCubit>().currentUser?.uid ?? '';
    context.read<UsersCubit>().loadUsers(uid);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _startChat(UserEntity user) async {
    final currentUid =
        context.read<AuthCubit>().currentUser?.uid ?? '';
    final result = await sl<IChatRepository>().getOrCreateConversation(
      currentUid: currentUid,
      otherUid: user.uid,
    );
    if (!mounted) return;
    result.fold(
      (f) => AppSnackbar.show(context, f.message, isError: true),
      (conversationId) => context.pushReplacement(
        '${AppRouter.chat}/$conversationId?receiverUid=${user.uid}&receiverName=${Uri.encodeComponent(user.displayName)}&receiverPhoto=${Uri.encodeComponent(user.photoUrl)}',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Chat'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // ── Search Bar ─────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (q) =>
                  context.read<UsersCubit>().search(q),
              decoration: InputDecoration(
                hintText: 'Search by name or email...',
                prefixIcon: const Icon(Icons.search_rounded,
                    color: AppColors.textSecondary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          context.read<UsersCubit>().search('');
                        },
                      )
                    : null,
              ),
            ),
          ),

          // ── User List ──────────────────────────────────
          Expanded(
            child: BlocBuilder<UsersCubit, UsersState>(
              builder: (context, state) {
                if (state is UsersLoading) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primary));
                } else if (state is UsersError) {
                  return EmptyStateWidget(
                    title: 'Error loading users',
                    subtitle: state.message,
                    icon: Icons.error_outline_rounded,
                  );
                } else if (state is UsersLoaded) {
                  if (state.users.isEmpty) {
                    return const EmptyStateWidget(
                      title: 'No users found',
                      subtitle: 'Try a different search term',
                      icon: Icons.person_search_rounded,
                    );
                  }
                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: state.users.length,
                    itemBuilder: (context, index) {
                      final user = state.users[index];
                      return _UserTile(
                        user: user,
                        onTap: () => _startChat(user),
                      ).animate().fadeIn(delay: (index * 40).ms).slideX(begin: 0.05);
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  final UserEntity user;
  final VoidCallback onTap;

  const _UserTile({required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: UserAvatarWidget(
        photoUrl: user.photoUrl,
        name: user.displayName,
        radius: 26,
        isOnline: user.isOnline,
      ),
      title: Text(
        user.displayName,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: Text(
        user.isOnline ? 'Online' : user.status,
        style: TextStyle(
          color: user.isOnline ? AppColors.online : AppColors.textSecondary,
          fontSize: 13,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.chat_rounded,
          color: AppColors.primary, size: 20),
      onTap: onTap,
    );
  }
}
