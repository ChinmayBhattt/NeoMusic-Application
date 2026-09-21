enum NotificationType {
  newRelease,
  recommendation,
  system,
  playlistUpdate,
}

class AppNotification {
  final String id;
  final String title;
  final String message;
  final String timeAgo;
  final bool isRead;
  final NotificationType type;
  final String? imageUrl;
  final String? songId;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timeAgo,
    this.isRead = false,
    this.type = NotificationType.system,
    this.imageUrl,
    this.songId,
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    String? timeAgo,
    bool? isRead,
    NotificationType? type,
    String? imageUrl,
    String? songId,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timeAgo: timeAgo ?? this.timeAgo,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      songId: songId ?? this.songId,
    );
  }
}
