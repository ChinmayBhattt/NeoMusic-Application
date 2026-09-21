import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/app_notification.dart';

final initialNotifications = <AppNotification>[
  const AppNotification(
    id: 'notif_1',
    title: 'New Release: Daft Punk',
    message: 'Random Access Memories (10th Anniversary Deluxe) is now streaming in 24-bit Lossless.',
    timeAgo: '15m ago',
    type: NotificationType.newRelease,
    imageUrl: 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=300&q=80',
    songId: 'song_1',
  ),
  const AppNotification(
    id: 'notif_2',
    title: 'Curated For You',
    message: 'Cyberpunk & Synthwave Mix updated with 20 newly curated tracks based on your taste.',
    timeAgo: '2h ago',
    type: NotificationType.recommendation,
    imageUrl: 'https://images.unsplash.com/photo-1508700115892-45ecd05ae2ad?w=300&q=80',
    songId: 'song_2',
  ),
  const AppNotification(
    id: 'notif_3',
    title: 'Hi-Fi Audio Enabled',
    message: 'Spatial Audio and Ultra HD 96kHz/24-bit streaming have been activated.',
    timeAgo: '1d ago',
    type: NotificationType.system,
  ),
  const AppNotification(
    id: 'notif_4',
    title: 'Top Chart Trending',
    message: 'The Weeknd is trending #1 on NeoMusic Global Electro Charts.',
    timeAgo: '2d ago',
    type: NotificationType.playlistUpdate,
    imageUrl: 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=300&q=80',
    songId: 'song_3',
  ),
];

class NotificationsNotifier extends Notifier<List<AppNotification>> {
  @override
  List<AppNotification> build() {
    return initialNotifications;
  }

  void markAsRead(String id) {
    state = state.map((n) {
      if (n.id == id) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();
  }

  void markAllAsRead() {
    state = state.map((n) => n.copyWith(isRead: true)).toList();
  }

  void dismiss(String id) {
    state = state.where((n) => n.id != id).toList();
  }

  void clearAll() {
    state = [];
  }
}

final notificationsProvider =
    NotifierProvider<NotificationsNotifier, List<AppNotification>>(
  NotificationsNotifier.new,
);

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final list = ref.watch(notificationsProvider);
  return list.where((n) => !n.isRead).length;
});
