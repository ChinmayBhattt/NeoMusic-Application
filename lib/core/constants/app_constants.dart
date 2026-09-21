/// Core application constants and storage keys
class AppConstants {
  static const String appName = 'NeoMusic';
  static const String appTagline = 'Stream the Future of Sound';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String keyLikedSongs = 'neomusic_liked_songs';
  static const String keyRecentlyPlayed = 'neomusic_recently_played';
  static const String keyCustomPlaylists = 'neomusic_custom_playlists';
  static const String keyUserProfile = 'neomusic_user_profile';
  static const String keySettings = 'neomusic_settings';
  static const String keyIsLoggedIn = 'neomusic_is_logged_in';

  // Audio Quality Options
  static const String qualityNormal = 'Normal (160 kbps)';
  static const String qualityHigh = 'High (320 kbps)';
  static const String qualityLossless = 'Hi-Res Lossless (FLAC 24-bit)';

  // Equalizer Presets
  static const List<String> equalizerPresets = [
    'Flat',
    'Bass Boost',
    'Cyber Electronic',
    'Acoustic Warmth',
    'Vocal Clarity',
    'Rock Energy',
  ];

  // Music Genres for browsing
  static const List<String> browseGenres = [
    'Cyberwave',
    'Synthpop',
    'Lo-Fi Beats',
    'Deep House',
    'Indie Rock',
    'Ambient Chill',
    'Neo Soul',
    'Hip-Hop',
  ];
}
