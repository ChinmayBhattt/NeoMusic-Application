import '../../domain/models/song.dart';
import '../../domain/models/artist.dart';
import '../../domain/models/album.dart';
import '../../domain/models/playlist.dart';
import '../../domain/repositories/music_repository.dart';
import '../datasources/mock_music_data.dart';
import '../datasources/local_storage_data_source.dart';

/// Concrete MusicRepository implementation
/// Reads curated data source and overlays user favorite states.
/// Can be replaced with an API client (e.g. Spotify Web API, custom backend) effortlessly.
class MusicRepositoryImpl implements MusicRepository {
  final LocalStorageDataSource _localStorage;

  MusicRepositoryImpl(this._localStorage);

  @override
  Future<List<Song>> getAllSongs() async {
    final likedIds = _localStorage.getLikedSongIds().toSet();
    return MockMusicData.songs.map((song) {
      return song.copyWith(isLiked: likedIds.contains(song.id));
    }).toList();
  }

  @override
  Future<List<Song>> getFeaturedSongs() async {
    final all = await getAllSongs();
    return all.take(5).toList();
  }

  @override
  Future<List<Song>> getTrendingSongs() async {
    final all = await getAllSongs();
    final sorted = List<Song>.from(all)..sort((a, b) => b.plays.compareTo(a.plays));
    return sorted;
  }

  @override
  Future<List<Song>> getNewReleases() async {
    final all = await getAllSongs();
    return all.reversed.take(6).toList();
  }

  @override
  Future<List<Artist>> getPopularArtists() async {
    return MockMusicData.artists;
  }

  @override
  Future<List<Album>> getFeaturedAlbums() async {
    return MockMusicData.albums;
  }

  @override
  Future<List<Playlist>> getFeaturedPlaylists() async {
    return MockMusicData.featuredPlaylists;
  }

  @override
  Future<Song?> getSongById(String id) async {
    final all = await getAllSongs();
    try {
      return all.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Artist?> getArtistById(String id) async {
    try {
      return MockMusicData.artists.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Album?> getAlbumById(String id) async {
    try {
      return MockMusicData.albums.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Song>> getSongsByArtist(String artistId) async {
    final all = await getAllSongs();
    return all.where((s) => s.artistId == artistId).toList();
  }

  @override
  Future<List<Song>> getSongsByAlbum(String albumId) async {
    final all = await getAllSongs();
    return all.where((s) => s.albumId == albumId).toList();
  }

  @override
  Future<List<Song>> getSongsByIds(List<String> ids) async {
    final all = await getAllSongs();
    final idMap = {for (var s in all) s.id: s};
    final List<Song> result = [];
    for (final id in ids) {
      if (idMap.containsKey(id)) {
        result.add(idMap[id]!);
      }
    }
    return result;
  }

  @override
  Future<List<Song>> searchSongs(String query, {String? genre}) async {
    final all = await getAllSongs();
    final lower = query.trim().toLowerCase();
    return all.where((song) {
      final matchesGenre = genre == null ||
          genre.isEmpty ||
          song.genre.toLowerCase() == genre.toLowerCase();
      if (!matchesGenre) return false;
      if (lower.isEmpty) return true;
      return song.title.toLowerCase().contains(lower) ||
          song.artist.toLowerCase().contains(lower) ||
          song.album.toLowerCase().contains(lower);
    }).toList();
  }

  @override
  Future<List<Artist>> searchArtists(String query) async {
    final lower = query.trim().toLowerCase();
    if (lower.isEmpty) return MockMusicData.artists;
    return MockMusicData.artists.where((artist) {
      return artist.name.toLowerCase().contains(lower) ||
          artist.bio.toLowerCase().contains(lower);
    }).toList();
  }

  @override
  Future<List<Album>> searchAlbums(String query) async {
    final lower = query.trim().toLowerCase();
    if (lower.isEmpty) return MockMusicData.albums;
    return MockMusicData.albums.where((album) {
      return album.title.toLowerCase().contains(lower) ||
          album.artist.toLowerCase().contains(lower) ||
          album.genre.toLowerCase().contains(lower);
    }).toList();
  }

  @override
  Future<List<Playlist>> searchPlaylists(String query) async {
    final lower = query.trim().toLowerCase();
    final all = [...MockMusicData.featuredPlaylists, ..._localStorage.getCustomPlaylists()];
    if (lower.isEmpty) return all;
    return all.where((p) {
      return p.name.toLowerCase().contains(lower) ||
          p.description.toLowerCase().contains(lower);
    }).toList();
  }
}
