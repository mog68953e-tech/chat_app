import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../cubit/auth_cubit.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../../../core/extensions/extensions.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  File? _profileImage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
    if (image != null) {
      setState(() => _profileImage = File(image.path));
    }
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    await context.read<AuthCubit>().signUpWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          displayName: _nameController.text.trim(),
          profileImage: _profileImage,
        );
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
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 30),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Back Button ───────────────────────────
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    ),
                    const SizedBox(height: 16),

                    // ── Title ─────────────────────────────────
                    Text(
                      'Create account ✨',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),
                    const SizedBox(height: 8),
                    Text(
                      'Join millions of people on ChatApp',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ).animate().fadeIn(delay: 100.ms),
                    const SizedBox(height: 36),

                    // ── Avatar Picker ─────────────────────────
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 52,
                              backgroundColor: AppColors.darkCard,
                              backgroundImage: _profileImage != null
                                  ? FileImage(_profileImage!)
                                  : null,
                              child: _profileImage == null
                                  ? const Icon(
                                      Icons.person_rounded,
                                      size: 52,
                                      color: AppColors.textSecondary,
                                    )
                                  : null,
                            ),
                            Positioned(
                              right: 2,
                              bottom: 2,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 150.ms).scale(),
                    ),
                    const SizedBox(height: 8),
                    const Center(
                      child: Text(
                        'Tap to add profile photo',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ── Name Field ────────────────────────────
                    AppTextField(
                      hint: 'Full name',
                      controller: _nameController,
                      prefixIcon: const Icon(Icons.person_outline,
                          color: AppColors.textSecondary),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Name is required';
                        }
                        if (v.trim().length < 2) return 'Name too short';
                        return null;
                      },
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                    const SizedBox(height: 16),

                    // ── Email Field ───────────────────────────
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
                    ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.1),
                    const SizedBox(height: 16),

                    // ── Password Field ────────────────────────
                    AppTextField(
                      hint: 'Password (min. 6 characters)',
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
                    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
                    const SizedBox(height: 36),

                    // ── Create Account Button ─────────────────
                    BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, state) {
                        final isLoading = state is AuthLoading;
                        return ElevatedButton(
                          onPressed: isLoading ? null : _signUp,
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
                              : const Text('Create Account'),
                        );
                      },
                    ).animate().fadeIn(delay: 350.ms),
                    const SizedBox(height: 24),

                    // ── Login Link ────────────────────────────
                    Center(
                      child: TextButton(
                        onPressed: () => context.pop(),
                        child: RichText(
                          text: const TextSpan(
                            text: 'Already have an account? ',
                            style: TextStyle(color: AppColors.textSecondary),
                            children: [
                              TextSpan(
                                text: 'Sign In',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 400.ms),
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
