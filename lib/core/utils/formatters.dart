import 'package:intl/intl.dart';

/// Formatting helpers for durations, counts, and greetings
class Formatters {
  /// Converts a Duration into mm:ss or hh:mm:ss string
  static String formatDuration(Duration? duration) {
    if (duration == null) return '00:00';
    final hours = duration.inHours;
    final minutes = hours > 0 ? (duration.inMinutes % 60) : duration.inMinutes;
    final seconds = duration.inSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Compact number representation (e.g. 1.2M, 450K)
  static String formatNumber(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  /// Dynamic greeting based on current local hour
  static String getGreeting([DateTime? now]) {
    final hour = (now ?? DateTime.now()).hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  /// Format date for display (e.g. Sep 2026)
  static String formatDate(DateTime date) {
    return DateFormat.yMMMd().format(date);
  }
}
