import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/song.dart';
import '../../domain/models/artist.dart';
import '../../domain/models/album.dart';
import '../../domain/models/playlist.dart';
import 'music_library_provider.dart';

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  void setQuery(String q) => state = q;
  void clear() => state = '';
}

final searchQueryProvider =
    NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);

class GenreFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void setGenre(String? g) => state = g;
}

final selectedGenreFilterProvider =
    NotifierProvider<GenreFilterNotifier, String?>(GenreFilterNotifier.new);

class SearchTabNotifier extends Notifier<int> {
  @override
  int build() => 0; // 0: All, 1: Songs, 2: Artists, 3: Albums, 4: Playlists
  void setTab(int t) => state = t;
}

final selectedSearchTabProvider =
    NotifierProvider<SearchTabNotifier, int>(SearchTabNotifier.new);

class SearchResultData {
  final List<Song> songs;
  final List<Artist> artists;
  final List<Album> albums;
  final List<Playlist> playlists;

  const SearchResultData({
    this.songs = const [],
    this.artists = const [],
    this.albums = const [],
    this.playlists = const [],
  });

  bool get isEmpty =>
      songs.isEmpty && artists.isEmpty && albums.isEmpty && playlists.isEmpty;
}

final searchResultsProvider = FutureProvider<SearchResultData>((ref) async {
  final query = ref.watch(searchQueryProvider);
  final genre = ref.watch(selectedGenreFilterProvider);
  final repo = ref.watch(musicRepositoryProvider);

  final songs = await repo.searchSongs(query, genre: genre);
  final artists = await repo.searchArtists(query);
  final albums = await repo.searchAlbums(query);
  final playlists = await repo.searchPlaylists(query);

  return SearchResultData(
    songs: songs,
    artists: artists,
    albums: albums,
    playlists: playlists,
  );
});
