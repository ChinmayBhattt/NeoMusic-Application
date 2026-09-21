import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/models/app_notification.dart';
import '../providers/notifications_provider.dart';
import '../providers/music_library_provider.dart';
import '../providers/audio_player_provider.dart';

/// Bottom sheet / modal dialog displaying notifications
class NotificationsSheet extends ConsumerWidget {
  const NotificationsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const NotificationsSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);
    final unreadCount = ref.watch(unreadNotificationsCountProvider);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: const BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: AppColors.surfaceGlassBorder, width: 1),
          left: BorderSide(color: AppColors.surfaceGlassBorder, width: 1),
          right: BorderSide(color: AppColors.surfaceGlassBorder, width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textMuted.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 16, 12),
            child: Row(
              children: [
                const Icon(
                  Icons.notifications_active_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Text(
                  'Notifications',
                  style: AppTypography.titleLarge,
                ),
                if (unreadCount > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      '$unreadCount new',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                if (notifications.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      ref.read(notificationsProvider.notifier).markAllAsRead();
                    },
                    child: Text(
                      'Mark all read',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.divider),

          // Content
          Flexible(
            child: notifications.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(48.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.done_all_rounded,
                            color: AppColors.primary,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "You're all caught up!",
                          style: AppTypography.titleMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'No new notifications right now.',
                          style: AppTypography.bodySmall,
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: notifications.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1, indent: 68, color: AppColors.divider),
                    itemBuilder: (context, index) {
                      final notif = notifications[index];
                      return _NotificationTile(
                        notification: notif,
                        onTap: () {
                          ref
                              .read(notificationsProvider.notifier)
                              .markAsRead(notif.id);
                          if (notif.songId != null) {
                            final allSongs =
                                ref.read(allSongsProvider).value ?? [];
                            final song = allSongs.firstWhere(
                              (s) => s.id == notif.songId,
                              orElse: () => allSongs.first,
                            );
                            ref
                                .read(playbackControllerProvider)
                                .playSong(song);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: AppColors.surfaceElevated,
                                content: Text(
                                  'Playing "${song.title}"',
                                  style: AppTypography.bodyMedium,
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        onDismiss: () {
                          ref
                              .read(notificationsProvider.notifier)
                              .dismiss(notif.id);
                        },
                      );
                    },
                  ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  IconData _getTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.newRelease:
        return Icons.album_rounded;
      case NotificationType.recommendation:
        return Icons.auto_awesome_rounded;
      case NotificationType.playlistUpdate:
        return Icons.queue_music_rounded;
      case NotificationType.system:
        return Icons.verified_rounded;
    }
  }

  Color _getTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.newRelease:
        return AppColors.accentPink;
      case NotificationType.recommendation:
        return AppColors.primary;
      case NotificationType.playlistUpdate:
        return AppColors.accentAmber;
      case NotificationType.system:
        return AppColors.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _getTypeColor(notification.type);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: notification.isRead
            ? Colors.transparent
            : AppColors.primary.withValues(alpha: 0.05),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail or Icon
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: notification.imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: notification.imageUrl!,
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => _buildFallbackIcon(typeColor),
                        )
                      : _buildFallbackIcon(typeColor),
                ),
                if (!notification.isRead)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.backgroundSecondary, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),

            // Text info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: AppTypography.titleSmall.copyWith(
                            fontWeight: notification.isRead
                                ? FontWeight.w500
                                : FontWeight.w700,
                            color: notification.isRead
                                ? AppColors.textPrimary
                                : AppColors.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        notification.timeAgo,
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    notification.message,
                    style: AppTypography.bodySmall.copyWith(
                      color: notification.isRead
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Dismiss Button
            IconButton(
              icon: const Icon(Icons.close, size: 18, color: AppColors.textMuted),
              tooltip: 'Dismiss',
              onPressed: onDismiss,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackIcon(Color color) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        _getTypeIcon(notification.type),
        color: color,
        size: 22,
      ),
    );
  }
}
