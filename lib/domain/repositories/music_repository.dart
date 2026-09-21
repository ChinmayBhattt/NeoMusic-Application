import '../models/song.dart';
import '../models/artist.dart';
import '../models/album.dart';
import '../models/playlist.dart';

/// Abstract Music Repository Contract
/// Ensures clean separation so external REST / GraphQL / Firebase / Spotify APIs
/// can be seamlessly plugged in without modifying UI or business logic.
abstract class MusicRepository {
  Future<List<Song>> getAllSongs();
  Future<List<Song>> getFeaturedSongs();
  Future<List<Song>> getTrendingSongs();
  Future<List<Song>> getNewReleases();
  Future<List<Artist>> getPopularArtists();
  Future<List<Album>> getFeaturedAlbums();
  Future<List<Playlist>> getFeaturedPlaylists();
  Future<Song?> getSongById(String id);
  Future<Artist?> getArtistById(String id);
  Future<Album?> getAlbumById(String id);
  Future<List<Song>> getSongsByArtist(String artistId);
  Future<List<Song>> getSongsByAlbum(String albumId);
  Future<List<Song>> getSongsByIds(List<String> ids);
  Future<List<Song>> searchSongs(String query, {String? genre});
  Future<List<Artist>> searchArtists(String query);
  Future<List<Album>> searchAlbums(String query);
  Future<List<Playlist>> searchPlaylists(String query);
}
