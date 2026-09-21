import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/playlist.dart';
import '../../domain/repositories/playlist_repository.dart';
import '../../data/repositories/playlist_repository_impl.dart';
import '../../services/storage_service.dart';

final playlistRepositoryProvider = Provider<PlaylistRepository>((ref) {
  return PlaylistRepositoryImpl(StorageService.localStorage);
});

class UserPlaylistsNotifier extends Notifier<List<Playlist>> {
  @override
  List<Playlist> build() {
    _loadPlaylists();
    return [];
  }

  Future<void> _loadPlaylists() async {
    final repo = ref.read(playlistRepositoryProvider);
    final playlists = await repo.getUserPlaylists();
    state = playlists;
  }

  Future<Playlist> createPlaylist(String name, String description) async {
    final repo = ref.read(playlistRepositoryProvider);
    final playlist = await repo.createPlaylist(name, description);
    state = [playlist, ...state];
    return playlist;
  }

  Future<void> deletePlaylist(String playlistId) async {
    final repo = ref.read(playlistRepositoryProvider);
    await repo.deletePlaylist(playlistId);
    state = state.where((p) => p.id != playlistId).toList();
  }

  Future<void> addSongToPlaylist(String playlistId, String songId) async {
    final repo = ref.read(playlistRepositoryProvider);
    await repo.addSongToPlaylist(playlistId, songId);
    state = state.map((p) {
      if (p.id == playlistId && !p.songIds.contains(songId)) {
        return p.copyWith(songIds: [...p.songIds, songId]);
      }
      return p;
    }).toList();
  }

  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    final repo = ref.read(playlistRepositoryProvider);
    await repo.removeSongFromPlaylist(playlistId, songId);
    state = state.map((p) {
      if (p.id == playlistId) {
        return p.copyWith(songIds: p.songIds.where((id) => id != songId).toList());
      }
      return p;
    }).toList();
  }
}

final userPlaylistsProvider =
    NotifierProvider<UserPlaylistsNotifier, List<Playlist>>(UserPlaylistsNotifier.new);
