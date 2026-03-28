import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_theme.dart';
import '../extensions/extensions.dart';

// ──────────────────────────────────────────────────────────────
// User Avatar Widget
// ──────────────────────────────────────────────────────────────
class UserAvatarWidget extends StatelessWidget {
  final String? photoUrl;
  final String name;
  final double radius;
  final bool isOnline;

  const UserAvatarWidget({
    super.key,
    this.photoUrl,
    required this.name,
    this.radius = 24,
    this.isOnline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: AppColors.primary,
          child: photoUrl != null && photoUrl!.isNotEmpty
              ? ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: photoUrl!,
                    width: radius * 2,
                    height: radius * 2,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => _buildPlaceholder(),
                    errorWidget: (_, __, ___) => _buildInitials(),
                  ),
                )
              : _buildInitials(),
        ),
        if (isOnline)
          Positioned(
            right: 1,
            bottom: 1,
            child: Container(
              width: radius * 0.4,
              height: radius * 0.4,
              decoration: BoxDecoration(
                color: AppColors.online,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInitials() => Text(
        name.initials,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.7,
        ),
      );

  Widget _buildPlaceholder() => Shimmer.fromColors(
        baseColor: AppColors.darkCard,
        highlightColor: AppColors.darkSurface,
        child: Container(color: AppColors.darkCard),
      );
}

// ──────────────────────────────────────────────────────────────
// Loading Overlay Widget
// ──────────────────────────────────────────────────────────────
class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black45,
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Custom Text Field
// ──────────────────────────────────────────────────────────────
class AppTextField extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;

  const AppTextField({
    super.key,
    required this.hint,
    required this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      validator: validator,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Custom Snackbar
// ──────────────────────────────────────────────────────────────
class AppSnackbar {
  static void show(
    BuildContext context,
    String message, {
    bool isError = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor:
            isError ? AppColors.error : AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: duration,
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Gradient Background Widget
// ──────────────────────────────────────────────────────────────
class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppColors.darkBackground,
                  const Color(0xFF0A1628),
                ]
              : [
                  AppColors.lightBackground,
                  const Color(0xFFE8EBF5),
                ],
        ),
      ),
      child: child,
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Empty State Widget
// ──────────────────────────────────────────────────────────────
class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = Icons.chat_bubble_outline_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: AppColors.textSecondary.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.textHint),
          ),
        ],
      ),
    );
  }
}
