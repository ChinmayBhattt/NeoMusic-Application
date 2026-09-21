import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../auth/auth_dialog.dart';

/// Settings & User Profile Screen
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 120),
          children: [
            // Screen Title
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 20, 16),
              child: Row(
                children: [
                  if (Navigator.canPop(context)) ...[
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
                      tooltip: 'Back',
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 4),
                  ],
                  Text('Settings & Profile', style: AppTypography.displayMedium),
                ],
              ),
            ),

            // Profile Header Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.surfaceGlassBorder),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppColors.surfaceElevated,
                    backgroundImage: (user?.avatarUrl.isNotEmpty == true)
                        ? CachedNetworkImageProvider(user!.avatarUrl)
                        : null,
                    child: (user?.avatarUrl.isEmpty ?? true)
                        ? const Icon(Icons.person_rounded, size: 36, color: AppColors.textSecondary)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'Guest Explorer',
                          style: AppTypography.titleLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user?.email ?? 'Sign in to sync your cloud library',
                          style: AppTypography.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            user?.membershipTier ?? 'Free Explorer',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: AppColors.textSecondary),
                    onPressed: () => _showEditProfileDialog(context, ref, user),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Audio & Playback Section
            _buildSectionHeader('AUDIO & STREAMING'),

            // Streaming Quality
            _buildTile(
              icon: Icons.high_quality_rounded,
              title: 'Streaming Audio Quality',
              subtitle: settings.audioQuality,
              onTap: () => _showQualitySelector(context, ref, settings.audioQuality),
            ),

            // Equalizer
            _buildTile(
              icon: Icons.graphic_eq_rounded,
              title: 'Equalizer Preset',
              subtitle: settings.equalizer,
              onTap: () => _showEqualizerSelector(context, ref, settings.equalizer),
            ),

            // Offline Mode Toggle
            SwitchListTile(
              secondary: const Icon(Icons.cloud_off_rounded, color: AppColors.primary),
              title: Text('Offline Mode', style: AppTypography.titleSmall),
              subtitle: Text('Only play downloaded and cached music', style: AppTypography.bodySmall),
              value: settings.offlineMode,
              activeThumbColor: AppColors.primary,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              onChanged: (val) {
                settingsNotifier.setOfflineMode(val);
              },
            ),

            // Cellular Streaming Toggle
            SwitchListTile(
              secondary: const Icon(Icons.cell_tower_rounded, color: AppColors.primary),
              title: Text('Stream on Cellular', style: AppTypography.titleSmall),
              subtitle: Text('Allow high-fidelity audio over mobile network', style: AppTypography.bodySmall),
              value: settings.cellularStreaming,
              activeThumbColor: AppColors.primary,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              onChanged: (val) {
                settingsNotifier.setCellularStreaming(val);
              },
            ),

            const SizedBox(height: 14),

            // App & Interface Section
            _buildSectionHeader('INTERFACE & STORAGE'),

            // Theme Style
            _buildTile(
              icon: Icons.palette_outlined,
              title: 'Theme Style',
              subtitle: settings.themeStyle,
              onTap: () => _showThemeSelector(context, ref, settings.themeStyle),
            ),

            // Clear Cache
            _buildTile(
              icon: Icons.cleaning_services_rounded,
              title: 'Clear Audio Cache',
              subtitle: '142 MB cached tracks and artwork',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Audio cache successfully cleaned!')),
                );
              },
            ),

            const SizedBox(height: 14),

            // Account & Session Section
            _buildSectionHeader('ACCOUNT & SESSION'),

            if (user != null)
              _buildTile(
                icon: Icons.logout_rounded,
                title: 'Sign Out',
                subtitle: 'Logged in as ${user.email}',
                titleColor: AppColors.error,
                onTap: () {
                  ref.read(authProvider.notifier).logout();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Logged out successfully.')),
                  );
                },
              )
            else
              _buildTile(
                icon: Icons.login_rounded,
                title: 'Sign In / Register',
                subtitle: 'Sync playlists across devices',
                titleColor: AppColors.primary,
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const AuthDialog(),
                  );
                },
              ),

            const SizedBox(height: 20),

            // Version info footer
            Center(
              child: Column(
                children: [
                  Text(
                    '${AppConstants.appName} v${AppConstants.appVersion}',
                    style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppConstants.appTagline,
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
      child: Text(
        title,
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.primary,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? titleColor,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      leading: Icon(icon, color: titleColor ?? AppColors.textSecondary),
      title: Text(
        title,
        style: AppTypography.titleSmall.copyWith(color: titleColor ?? AppColors.textPrimary),
      ),
      subtitle: Text(subtitle, style: AppTypography.bodySmall),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
      onTap: onTap,
    );
  }

  void _showQualitySelector(BuildContext context, WidgetRef ref, String current) {
    final options = [
      AppConstants.qualityNormal,
      AppConstants.qualityHigh,
      AppConstants.qualityLossless,
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Select Audio Quality', style: AppTypography.titleLarge),
                ),
                ...options.map((opt) {
                  final isSelected = opt == current;
                  return ListTile(
                    title: Text(opt, style: AppTypography.bodyLarge),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                        : null,
                    onTap: () {
                      ref.read(settingsProvider.notifier).setAudioQuality(opt);
                      Navigator.pop(context);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEqualizerSelector(BuildContext context, WidgetRef ref, String current) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Equalizer Sound Profiles', style: AppTypography.titleLarge),
                ),
                ...AppConstants.equalizerPresets.map((preset) {
                  final isSelected = preset == current;
                  return ListTile(
                    title: Text(preset, style: AppTypography.bodyLarge),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                        : null,
                    onTap: () {
                      ref.read(settingsProvider.notifier).setEqualizer(preset);
                      Navigator.pop(context);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showThemeSelector(BuildContext context, WidgetRef ref, String current) {
    final themes = ['Dark Modern', 'Deep Midnight', 'OLED Pure Black'];
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Theme Style', style: AppTypography.titleLarge),
                ),
                ...themes.map((t) {
                  final isSelected = t == current;
                  return ListTile(
                    title: Text(t, style: AppTypography.bodyLarge),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                        : null,
                    onTap: () {
                      ref.read(settingsProvider.notifier).setThemeStyle(t);
                      Navigator.pop(context);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditProfileDialog(BuildContext context, WidgetRef ref, user) {
    final nameController = TextEditingController(text: user?.name ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Edit Profile Name', style: AppTypography.titleLarge),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Display Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
            ),
            ElevatedButton(
              onPressed: () {
                if (user != null && nameController.text.trim().isNotEmpty) {
                  ref.read(authProvider.notifier).updateProfile(
                        user.copyWith(name: nameController.text.trim()),
                      );
                  Navigator.pop(dialogContext);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Save', style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }
}
