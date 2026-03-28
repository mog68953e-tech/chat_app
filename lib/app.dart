import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/chat/presentation/cubit/chat_list_cubit.dart';
import 'features/users/presentation/cubit/users_cubit.dart';
import 'injection_container.dart';

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(
          create: (_) => sl<ThemeCubit>(),
        ),
        BlocProvider<AuthCubit>(
          create: (_) => sl<AuthCubit>(),
        ),
        BlocProvider<ChatListCubit>(
          create: (_) => sl<ChatListCubit>(),
        ),
        BlocProvider<UsersCubit>(
          create: (_) => sl<UsersCubit>(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, bool>(
        builder: (context, isDark) {
          final authCubit = context.read<AuthCubit>();
          final router = AppRouter.router(authCubit);

          return MaterialApp.router(
            title: 'ChatApp',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
