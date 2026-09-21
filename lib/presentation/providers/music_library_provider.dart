import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/song.dart';
import '../../domain/models/artist.dart';
import '../../domain/models/album.dart';
import '../../domain/models/playlist.dart';
import '../../domain/repositories/music_repository.dart';
import '../../data/repositories/music_repository_impl.dart';
import '../../services/storage_service.dart';

/// Music Repository Provider
final musicRepositoryProvider = Provider<MusicRepository>((ref) {
  return MusicRepositoryImpl(StorageService.localStorage);
});

/// All Songs Provider
final allSongsProvider = FutureProvider<List<Song>>((ref) async {
  final repo = ref.watch(musicRepositoryProvider);
  return repo.getAllSongs();
});

/// Home Featured Songs
final featuredSongsProvider = FutureProvider<List<Song>>((ref) async {
  final repo = ref.watch(musicRepositoryProvider);
  return repo.getFeaturedSongs();
});

/// Home Trending Songs
final trendingSongsProvider = FutureProvider<List<Song>>((ref) async {
  final repo = ref.watch(musicRepositoryProvider);
  return repo.getTrendingSongs();
});

/// Home New Releases
final newReleasesProvider = FutureProvider<List<Song>>((ref) async {
  final repo = ref.watch(musicRepositoryProvider);
  return repo.getNewReleases();
});

/// Home Popular Artists
final popularArtistsProvider = FutureProvider<List<Artist>>((ref) async {
  final repo = ref.watch(musicRepositoryProvider);
  return repo.getPopularArtists();
});

/// Featured Albums
final featuredAlbumsProvider = FutureProvider<List<Album>>((ref) async {
  final repo = ref.watch(musicRepositoryProvider);
  return repo.getFeaturedAlbums();
});

/// Featured Curated Playlists
final featuredPlaylistsProvider = FutureProvider<List<Playlist>>((ref) async {
  final repo = ref.watch(musicRepositoryProvider);
  return repo.getFeaturedPlaylists();
});

/// Liked Songs Notifier managing favorite toggles & persistence
class LikedSongsNotifier extends Notifier<List<Song>> {
  @override
  List<Song> build() {
    _loadLikedSongs();
    return [];
  }

  Future<void> _loadLikedSongs() async {
    final repo = ref.read(musicRepositoryProvider);
    final likedIds = StorageService.localStorage.getLikedSongIds();
    final songs = await repo.getSongsByIds(likedIds);
    state = songs.map((s) => s.copyWith(isLiked: true)).toList();
  }

  Future<void> toggleLike(Song song) async {
    await StorageService.localStorage.toggleLikedSong(song.id);
    final exists = state.any((s) => s.id == song.id);
    if (exists) {
      state = state.where((s) => s.id != song.id).toList();
    } else {
      state = [song.copyWith(isLiked: true), ...state];
    }
  }

  bool isLiked(String songId) {
    return state.any((s) => s.id == songId);
  }
}

final likedSongsProvider =
    NotifierProvider<LikedSongsNotifier, List<Song>>(LikedSongsNotifier.new);

/// Recently Played Notifier managing history & persistence
class RecentlyPlayedNotifier extends Notifier<List<Song>> {
  @override
  List<Song> build() {
    _loadRecent();
    return [];
  }

  Future<void> _loadRecent() async {
    final repo = ref.read(musicRepositoryProvider);
    final recentIds = StorageService.localStorage.getRecentlyPlayedIds();
    final songs = await repo.getSongsByIds(recentIds);
    state = songs;
  }

  Future<void> addSong(Song song) async {
    await StorageService.localStorage.addRecentlyPlayed(song.id);
    final filtered = state.where((s) => s.id != song.id).toList();
    state = [song, ...filtered];
  }
}

final recentlyPlayedProvider =
    NotifierProvider<RecentlyPlayedNotifier, List<Song>>(RecentlyPlayedNotifier.new);
