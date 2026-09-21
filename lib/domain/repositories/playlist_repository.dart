import '../models/playlist.dart';

/// Abstract Playlist Repository Contract
abstract class PlaylistRepository {
  Future<List<Playlist>> getUserPlaylists();
  Future<Playlist> createPlaylist(String name, String description);
  Future<void> updatePlaylist(Playlist playlist);
  Future<void> deletePlaylist(String playlistId);
  Future<void> addSongToPlaylist(String playlistId, String songId);
  Future<void> removeSongFromPlaylist(String playlistId, String songId);
}
