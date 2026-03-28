import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/chat/presentation/screens/chat_list_screen.dart';
import '../../features/chat/presentation/screens/chat_screen.dart';
import '../../features/users/presentation/screens/users_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String chat = '/chat';
  static const String users = '/users';
  static const String profile = '/profile';

  static GoRouter router(AuthCubit authCubit) => GoRouter(
        initialLocation: splash,
        refreshListenable: GoRouterRefreshStream(authCubit.stream),
        redirect: (context, state) {
          final authState = authCubit.state;
          final isAuth = authState is AuthAuthenticated;
          final isOnAuthPage = state.matchedLocation == login ||
              state.matchedLocation == signup ||
              state.matchedLocation == splash;

          if (!isAuth && !isOnAuthPage) return login;
          if (isAuth && isOnAuthPage) return home;
          return null;
        },
        routes: [
          GoRoute(
            path: splash,
            builder: (_, __) => const SplashScreen(),
          ),
          GoRoute(
            path: login,
            builder: (_, __) => const LoginScreen(),
          ),
          GoRoute(
            path: signup,
            builder: (_, __) => const SignupScreen(),
          ),
          GoRoute(
            path: home,
            builder: (_, __) => const ChatListScreen(),
          ),
          GoRoute(
            path: '$chat/:conversationId',
            builder: (_, state) => ChatScreen(
              conversationId: state.pathParameters['conversationId']!,
              receiverUid: state.uri.queryParameters['receiverUid']!,
              receiverName: state.uri.queryParameters['receiverName']!,
              receiverPhoto: state.uri.queryParameters['receiverPhoto'] ?? '',
            ),
          ),
          GoRoute(
            path: users,
            builder: (_, __) => const UsersScreen(),
          ),
          GoRoute(
            path: profile,
            builder: (_, __) => const ProfileScreen(),
          ),
        ],
        errorBuilder: (_, state) => Scaffold(
          body: Center(child: Text('Route not found: ${state.error}')),
        ),
      );
}

/// Makes GoRouter reactive to BlocStream
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final dynamic _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
