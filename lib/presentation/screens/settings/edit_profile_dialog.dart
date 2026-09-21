import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/image_helper.dart';
import '../../../core/utils/image_picker_helper.dart';
import '../../../domain/models/user_profile.dart';
import '../../providers/auth_provider.dart';

class EditProfileDialog extends ConsumerStatefulWidget {
  final UserProfile? user;

  const EditProfileDialog({super.key, required this.user});

  static Future<void> show(BuildContext context, UserProfile? user) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => EditProfileDialog(user: user),
    );
  }

  @override
  ConsumerState<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends ConsumerState<EditProfileDialog> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  late String _currentAvatarUrl;
  late String _currentBannerUrl;
  bool _isSaving = false;

  static const List<String> _presetAvatars = [
    'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=400&q=80',
    'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=400&q=80',
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400&q=80',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&q=80',
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&q=80',
  ];

  static const List<String> _presetBanners = [
    'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=1200&q=80',
    'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=1200&q=80',
    'https://images.unsplash.com/photo-1508700115892-45ecd05ae2ad?w=1200&q=80',
    'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=1200&q=80',
  ];

  @override
  void initState() {
    super.initState();
    final user = widget.user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phoneNumber ?? '');
    _currentAvatarUrl = user?.avatarUrl ?? _presetAvatars.first;
    _currentBannerUrl = user?.bannerUrl ?? _presetBanners.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    try {
      final dataUrl = await ProfileImagePicker.pickImage(
        maxWidth: 400,
        maxHeight: 400,
        quality: 0.75,
      );
      if (dataUrl != null && mounted) {
        setState(() {
          _currentAvatarUrl = dataUrl;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text('Failed to select image: $e'),
          ),
        );
      }
    }
  }

  Future<void> _pickBanner() async {
    try {
      final dataUrl = await ProfileImagePicker.pickImage(
        maxWidth: 900,
        maxHeight: 350,
        quality: 0.75,
      );
      if (dataUrl != null && mounted) {
        setState(() {
          _currentBannerUrl = dataUrl;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text('Failed to select banner: $e'),
          ),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.warning,
          content: Text('Display name cannot be empty'),
        ),
      );
      return;
    }

    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.warning,
          content: Text('Please enter a valid email address'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final currentUser = widget.user ??
          const UserProfile(
            id: 'usr_neo_1',
            name: 'Neo Explorer',
            email: 'explorer@neomusic.stream',
            avatarUrl: '',
          );

      final updated = currentUser.copyWith(
        name: name,
        email: email,
        phoneNumber: phone,
        avatarUrl: _currentAvatarUrl,
        bannerUrl: _currentBannerUrl,
      );

      await ref.read(authProvider.notifier).updateProfile(updated);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.surfaceElevated,
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: AppColors.primary),
                const SizedBox(width: 10),
                Text('Profile updated successfully', style: AppTypography.bodyMedium),
              ],
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text('Failed to save profile: $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatarProvider = ImageHelper.getImageProvider(_currentAvatarUrl);
    final bannerProvider = ImageHelper.getImageProvider(_currentBannerUrl);

    return Dialog(
      backgroundColor: AppColors.backgroundSecondary,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppColors.surfaceGlassBorder, width: 1),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 16, 14),
                child: Row(
                  children: [
                    const Icon(Icons.manage_accounts_rounded, color: AppColors.primary, size: 24),
                    const SizedBox(width: 10),
                    Text('Edit Profile', style: AppTypography.titleLarge),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, color: AppColors.divider),

              // Banner & Avatar Preview / Upload Section
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('PROFILE BANNER', style: AppTypography.labelSmall),
                        Text(
                          'Tap below or pick preset',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Banner Card
                    Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.surfaceGlassBorder),
                        image: bannerProvider != null
                            ? DecorationImage(
                                image: bannerProvider,
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.6),
                            ],
                          ),
                        ),
                        alignment: Alignment.topRight,
                        padding: const EdgeInsets.all(8),
                        child: ElevatedButton.icon(
                          onPressed: _pickBanner,
                          icon: const Icon(Icons.upload_rounded, size: 16),
                          label: const Text('Upload Banner', style: TextStyle(fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black.withValues(alpha: 0.7),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: const BorderSide(color: AppColors.surfaceGlassBorder),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Preset Banners Row
                    SizedBox(
                      height: 36,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _presetBanners.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final bUrl = _presetBanners[index];
                          final isSelected = _currentBannerUrl == bUrl;
                          return InkWell(
                            onTap: () => setState(() => _currentBannerUrl = bUrl),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : AppColors.surfaceGlassBorder,
                                  width: isSelected ? 2 : 1,
                                ),
                                image: DecorationImage(
                                  image: NetworkImage(bUrl),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Avatar Row & Upload
                    Row(
                      children: [
                        Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.primary, width: 2),
                              ),
                              child: CircleAvatar(
                                radius: 34,
                                backgroundColor: AppColors.surfaceElevated,
                                backgroundImage: avatarProvider,
                                child: avatarProvider == null
                                    ? const Icon(Icons.person, size: 34, color: AppColors.textSecondary)
                                    : null,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: InkWell(
                                onTap: _pickAvatar,
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.backgroundSecondary,
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt_rounded,
                                    size: 14,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ElevatedButton.icon(
                                onPressed: _pickAvatar,
                                icon: const Icon(Icons.upload_rounded, size: 16),
                                label: const Text('Upload Photo', style: TextStyle(fontSize: 12)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.surfaceElevated,
                                  foregroundColor: AppColors.textPrimary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: const BorderSide(color: AppColors.surfaceGlassBorder),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              // Preset Avatars Row
                              SizedBox(
                                height: 32,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _presetAvatars.length,
                                  separatorBuilder: (context, index) => const SizedBox(width: 6),
                                  itemBuilder: (context, index) {
                                    final aUrl = _presetAvatars[index];
                                    final isSelected = _currentAvatarUrl == aUrl;
                                    return InkWell(
                                      onTap: () => setState(() => _currentAvatarUrl = aUrl),
                                      borderRadius: BorderRadius.circular(16),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isSelected ? AppColors.primary : Colors.transparent,
                                            width: 2,
                                          ),
                                        ),
                                        child: CircleAvatar(
                                          radius: 14,
                                          backgroundImage: NetworkImage(aUrl),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Form fields
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Name Field
                    TextField(
                      controller: _nameController,
                      style: AppTypography.bodyLarge,
                      decoration: InputDecoration(
                        labelText: 'Display Name',
                        prefixIcon: const Icon(Icons.person_rounded, color: AppColors.primary),
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Email Field
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: AppTypography.bodyLarge,
                      decoration: InputDecoration(
                        labelText: 'Email Address',
                        prefixIcon: const Icon(Icons.email_rounded, color: AppColors.primary),
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Phone Number Field
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: AppTypography.bodyLarge,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        hintText: '+1 (555) 000-0000',
                        prefixIcon: const Icon(Icons.phone_rounded, color: AppColors.primary),
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              const Divider(height: 1, color: AppColors.divider),

              // Action Buttons
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _isSaving ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                              ),
                            )
                          : const Text(
                              'Save Changes',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
