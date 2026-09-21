import 'package:uuid/uuid.dart';
import '../../domain/models/playlist.dart';
import '../../domain/repositories/playlist_repository.dart';
import '../datasources/local_storage_data_source.dart';

/// PlaylistRepository Implementation managing user-created playlists
class PlaylistRepositoryImpl implements PlaylistRepository {
  final LocalStorageDataSource _localStorage;
  final Uuid _uuid = const Uuid();

  PlaylistRepositoryImpl(this._localStorage);

  @override
  Future<List<Playlist>> getUserPlaylists() async {
    return _localStorage.getCustomPlaylists();
  }

  @override
  Future<Playlist> createPlaylist(String name, String description) async {
    final playlists = _localStorage.getCustomPlaylists();
    final newPlaylist = Playlist(
      id: 'custom_pl_${_uuid.v4().substring(0, 8)}',
      name: name.trim().isEmpty ? 'My Playlist #${playlists.length + 1}' : name.trim(),
      description: description.trim(),
      coverUrl: 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=500&q=80',
      songIds: [],
      isCustom: true,
      createdAt: DateTime.now(),
    );

    playlists.insert(0, newPlaylist);
    await _localStorage.saveCustomPlaylists(playlists);
    return newPlaylist;
  }

  @override
  Future<void> updatePlaylist(Playlist playlist) async {
    final playlists = _localStorage.getCustomPlaylists();
    final index = playlists.indexWhere((p) => p.id == playlist.id);
    if (index != -1) {
      playlists[index] = playlist;
      await _localStorage.saveCustomPlaylists(playlists);
    }
  }

  @override
  Future<void> deletePlaylist(String playlistId) async {
    final playlists = _localStorage.getCustomPlaylists();
    playlists.removeWhere((p) => p.id == playlistId);
    await _localStorage.saveCustomPlaylists(playlists);
  }

  @override
  Future<void> addSongToPlaylist(String playlistId, String songId) async {
    final playlists = _localStorage.getCustomPlaylists();
    final index = playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      final current = playlists[index];
      if (!current.songIds.contains(songId)) {
        final updated = current.copyWith(
          songIds: [...current.songIds, songId],
        );
        playlists[index] = updated;
        await _localStorage.saveCustomPlaylists(playlists);
      }
    }
  }

  @override
  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    final playlists = _localStorage.getCustomPlaylists();
    final index = playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      final current = playlists[index];
      final updated = current.copyWith(
        songIds: current.songIds.where((id) => id != songId).toList(),
      );
      playlists[index] = updated;
      await _localStorage.saveCustomPlaylists(playlists);
    }
  }
}
