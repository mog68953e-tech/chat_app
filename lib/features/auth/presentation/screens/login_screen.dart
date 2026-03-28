import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../cubit/auth_cubit.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../../../core/extensions/extensions.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    await context.read<AuthCubit>().signInWithEmail(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
  }

  Future<void> _signInWithGoogle() async {
    await context.read<AuthCubit>().signInWithGoogle();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go(AppRouter.home);
        } else if (state is AuthError) {
          AppSnackbar.show(context, state.message, isError: true);
        }
      },
      child: Scaffold(
        body: GradientBackground(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Logo ─────────────────────────────────
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.35),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.chat_rounded,
                            color: Colors.white, size: 42),
                      ).animate().fadeIn(duration: 500.ms).scale(),
                    ),
                    const SizedBox(height: 40),

                    // ── Title ────────────────────────────────
                    Text(
                      'Welcome back 👋',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to continue chatting',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ).animate().fadeIn(delay: 150.ms),
                    const SizedBox(height: 40),

                    // ── Email ────────────────────────────────
                    AppTextField(
                      hint: 'Email address',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.email_outlined,
                          color: AppColors.textSecondary),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Email is required';
                        if (!v.isValidEmail) return 'Enter a valid email';
                        return null;
                      },
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                    const SizedBox(height: 16),

                    // ── Password ─────────────────────────────
                    AppTextField(
                      hint: 'Password',
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      prefixIcon: const Icon(Icons.lock_outline,
                          color: AppColors.textSecondary),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Password is required';
                        }
                        if (v.length < 6) return 'Minimum 6 characters';
                        return null;
                      },
                    ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.1),
                    const SizedBox(height: 32),

                    // ── Sign In Button ────────────────────────
                    BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, state) {
                        final isLoading = state is AuthLoading;
                        return ElevatedButton(
                          onPressed: isLoading ? null : _signIn,
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : const Text('Sign In'),
                        );
                      },
                    ).animate().fadeIn(delay: 300.ms),
                    const SizedBox(height: 20),

                    // ── Divider ───────────────────────────────
                    const Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'OR',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ).animate().fadeIn(delay: 350.ms),
                    const SizedBox(height: 20),

                    // ── Google Sign-In Button ─────────────────
                    OutlinedButton.icon(
                      onPressed: _signInWithGoogle,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        side: const BorderSide(color: AppColors.darkBorder),
                      ),
                      icon: Image.network(
                        'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                        height: 22,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.g_mobiledata, size: 22),
                      ),
                      label: const Text('Continue with Google'),
                    ).animate().fadeIn(delay: 400.ms),
                    const SizedBox(height: 40),

                    // ── Sign Up Link ──────────────────────────
                    Center(
                      child: TextButton(
                        onPressed: () => context.push(AppRouter.signup),
                        child: RichText(
                          text: const TextSpan(
                            text: "Don't have an account? ",
                            style: TextStyle(color: AppColors.textSecondary),
                            children: [
                              TextSpan(
                                text: 'Sign Up',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 450.ms),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
