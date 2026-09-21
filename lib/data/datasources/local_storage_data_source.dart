import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/models/playlist.dart';
import '../../domain/models/user_profile.dart';

/// Local Storage Data Source utilizing SharedPreferences
class LocalStorageDataSource {
  final SharedPreferences _prefs;

  LocalStorageDataSource(this._prefs);

  // -------------------- Liked Songs --------------------

  List<String> getLikedSongIds() {
    return _prefs.getStringList(AppConstants.keyLikedSongs) ?? ['song_1', 'song_3'];
  }

  Future<void> setLikedSongIds(List<String> songIds) async {
    await _prefs.setStringList(AppConstants.keyLikedSongs, songIds);
  }

  Future<void> toggleLikedSong(String songId) async {
    final list = getLikedSongIds().toList();
    if (list.contains(songId)) {
      list.remove(songId);
    } else {
      list.insert(0, songId);
    }
    await setLikedSongIds(list);
  }

  // -------------------- Recently Played --------------------

  List<String> getRecentlyPlayedIds() {
    return _prefs.getStringList(AppConstants.keyRecentlyPlayed) ??
        ['song_1', 'song_2', 'song_3', 'song_4'];
  }

  Future<void> addRecentlyPlayed(String songId) async {
    final list = getRecentlyPlayedIds().toList();
    list.remove(songId);
    list.insert(0, songId);
    // Keep maximum 30 recent tracks
    if (list.length > 30) {
      list.removeLast();
    }
    await _prefs.setStringList(AppConstants.keyRecentlyPlayed, list);
  }

  // -------------------- Custom Playlists --------------------

  List<Playlist> getCustomPlaylists() {
    final raw = _prefs.getString(AppConstants.keyCustomPlaylists);
    if (raw == null || raw.isEmpty) {
      return [
        Playlist(
          id: 'user_pl_favs',
          name: 'My Late Night Vibes',
          description: 'Personal handpicked favorites for nocturnal coding & chill.',
          coverUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=500&q=80',
          songIds: ['song_1', 'song_3', 'song_7'],
          isCustom: true,
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
      ];
    }
    try {
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) => Playlist.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveCustomPlaylists(List<Playlist> playlists) async {
    final raw = jsonEncode(playlists.map((p) => p.toJson()).toList());
    await _prefs.setString(AppConstants.keyCustomPlaylists, raw);
  }

  // -------------------- User Profile & Auth --------------------

  UserProfile getUserProfile() {
    final raw = _prefs.getString(AppConstants.keyUserProfile);
    if (raw == null || raw.isEmpty) {
      return const UserProfile(
        id: 'usr_neo_1',
        name: 'Neo Explorer',
        email: 'explorer@neomusic.stream',
        avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=400&q=80',
        membershipTier: 'Neo Premium Hi-Fi',
        isSubscribed: true,
      );
    }
    try {
      return UserProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const UserProfile(
        id: 'usr_neo_1',
        name: 'Neo Explorer',
        email: 'explorer@neomusic.stream',
        avatarUrl: '',
      );
    }
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    try {
      await _prefs.setString(AppConstants.keyUserProfile, jsonEncode(profile.toJson()));
    } catch (e) {
      // Storage quota or serialization issue, logged gracefully
    }
  }

  bool isLoggedIn() {
    return _prefs.getBool(AppConstants.keyIsLoggedIn) ?? true;
  }

  Future<void> setLoggedIn(bool loggedIn) async {
    await _prefs.setBool(AppConstants.keyIsLoggedIn, loggedIn);
  }

  // -------------------- Settings --------------------

  Map<String, dynamic> getSettings() {
    final raw = _prefs.getString(AppConstants.keySettings);
    if (raw == null || raw.isEmpty) {
      return {
        'audioQuality': AppConstants.qualityHigh,
        'equalizer': 'Cyber Electronic',
        'offlineMode': false,
        'cellularStreaming': true,
        'themeStyle': 'Dark Modern',
      };
    }
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return {
        'audioQuality': AppConstants.qualityHigh,
        'equalizer': 'Cyber Electronic',
        'offlineMode': false,
        'cellularStreaming': true,
        'themeStyle': 'Dark Modern',
      };
    }
  }

  Future<void> saveSettings(Map<String, dynamic> settings) async {
    await _prefs.setString(AppConstants.keySettings, jsonEncode(settings));
  }
}
