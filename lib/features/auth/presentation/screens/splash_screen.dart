import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../cubit/auth_cubit.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';

/// Animated splash screen that checks auth state and redirects
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;
    await context.read<AuthCubit>().checkAuthStatus();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go(AppRouter.home);
        } else if (state is AuthUnauthenticated) {
          context.go(AppRouter.login);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.darkBackground,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Icon with pulse animation
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.chat_rounded,
                  color: Colors.white,
                  size: 55,
                ),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(
                    begin: const Offset(1.0, 1.0),
                    end: const Offset(1.08, 1.08),
                    duration: 1200.ms,
                    curve: Curves.easeInOut,
                  )
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .slideY(begin: 0.2, end: 0),
              const SizedBox(height: 32),
              const Text(
                'ChatApp',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              )
                  .animate()
                  .fadeIn(delay: 300.ms, duration: 600.ms)
                  .slideY(begin: 0.2, end: 0),
              const SizedBox(height: 8),
              const Text(
                'Connect. Chat. Share.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                  letterSpacing: 0.5,
                ),
              ).animate().fadeIn(delay: 500.ms, duration: 600.ms),
              const SizedBox(height: 60),
              const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ).animate().fadeIn(delay: 800.ms),
            ],
          ),
        ),
      ),
    );
  }
}
