import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../cubit/profile_cubit.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../../../injection_container.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _statusController;
  File? _newAvatar;
  late final ProfileCubit _profileCubit;

  @override
  void initState() {
    super.initState();
    _profileCubit = sl<ProfileCubit>();
    final user = context.read<AuthCubit>().currentUser;
    _nameController = TextEditingController(text: user?.displayName ?? '');
    _statusController = TextEditingController(text: user?.status ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      imageQuality: 80,
    );
    if (image != null) {
      setState(() => _newAvatar = File(image.path));
    }
  }

  Future<void> _saveProfile() async {
    final user = context.read<AuthCubit>().currentUser;
    if (user == null) return;
    await _profileCubit.updateProfile(
      uid: user.uid,
      displayName: _nameController.text.trim(),
      status: _statusController.text.trim(),
      newAvatar: _newAvatar,
      currentPhotoUrl: user.photoUrl,
    );
  }

  Future<void> _signOut() async {
    await context.read<AuthCubit>().signOut();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthCubit>().currentUser;
    final isDark = context.watch<ThemeCubit>().isDarkMode;

    return BlocProvider.value(
      value: _profileCubit,
      child: BlocListener<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileUpdated) {
            AppSnackbar.show(context, 'Profile updated!');
          } else if (state is ProfileError) {
            AppSnackbar.show(context, state.message, isError: true);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Profile'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => context.pop(),
            ),
            actions: [
              BlocBuilder<ProfileCubit, ProfileState>(
                builder: (_, state) => TextButton(
                  onPressed: state is ProfileUpdating ? null : _saveProfile,
                  child: state is ProfileUpdating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Save',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // ── Avatar ───────────────────────────────
                Center(
                  child: GestureDetector(
                    onTap: _pickAvatar,
                    child: Stack(
                      children: [
                        _newAvatar != null
                            ? CircleAvatar(
                                radius: 56,
                                backgroundImage: FileImage(_newAvatar!),
                              )
                            : UserAvatarWidget(
                                photoUrl: user?.photoUrl,
                                name: user?.displayName ?? '?',
                                radius: 56,
                                isOnline: true,
                              ),
                        Positioned(
                          right: 2,
                          bottom: 2,
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.white,
                              size: 17,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(duration: 400.ms).scale(),
                const SizedBox(height: 8),
                Text(
                  user?.email ?? '',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 32),

                // ── Fields ────────────────────────────────
                AppTextField(
                  hint: 'Display Name',
                  controller: _nameController,
                  prefixIcon: const Icon(Icons.person_outline,
                      color: AppColors.textSecondary),
                ).animate().fadeIn(delay: 100.ms),
                const SizedBox(height: 16),
                AppTextField(
                  hint: 'Status',
                  controller: _statusController,
                  prefixIcon: const Icon(Icons.info_outline,
                      color: AppColors.textSecondary),
                ).animate().fadeIn(delay: 150.ms),
                const SizedBox(height: 32),

                // ── Dark Mode Toggle ──────────────────────
                Card(
                  child: ListTile(
                    leading: Icon(
                      isDark
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                      color: AppColors.primary,
                    ),
                    title: const Text('Dark Mode'),
                    trailing: Switch(
                      value: isDark,
                      onChanged: (_) =>
                          context.read<ThemeCubit>().toggleTheme(),
                      activeThumbColor: AppColors.primary,
                    ),
                  ),
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 12),

                // ── Sign Out Button ───────────────────────
                Card(
                  child: ListTile(
                    leading:
                        const Icon(Icons.logout_rounded, color: Colors.red),
                    title: const Text('Sign Out',
                        style: TextStyle(color: Colors.red)),
                    onTap: _signOut,
                  ),
                ).animate().fadeIn(delay: 250.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
