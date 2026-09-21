import 'lyric_line.dart';

/// Song Domain Model
class Song {
  final String id;
  final String title;
  final String artist;
  final String artistId;
  final String album;
  final String albumId;
  final Duration duration;
  final String audioUrl;
  final String artworkUrl;
  final List<LyricLine> lyrics;
  final bool isLiked;
  final int plays;
  final String genre;
  final String? releaseDate;

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.artistId,
    required this.album,
    required this.albumId,
    required this.duration,
    required this.audioUrl,
    required this.artworkUrl,
    this.lyrics = const [],
    this.isLiked = false,
    this.plays = 0,
    this.genre = 'Electronic',
    this.releaseDate,
  });

  Song copyWith({
    String? id,
    String? title,
    String? artist,
    String? artistId,
    String? album,
    String? albumId,
    Duration? duration,
    String? audioUrl,
    String? artworkUrl,
    List<LyricLine>? lyrics,
    bool? isLiked,
    int? plays,
    String? genre,
    String? releaseDate,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      artistId: artistId ?? this.artistId,
      album: album ?? this.album,
      albumId: albumId ?? this.albumId,
      duration: duration ?? this.duration,
      audioUrl: audioUrl ?? this.audioUrl,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      lyrics: lyrics ?? this.lyrics,
      isLiked: isLiked ?? this.isLiked,
      plays: plays ?? this.plays,
      genre: genre ?? this.genre,
      releaseDate: releaseDate ?? this.releaseDate,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'artist': artist,
        'artistId': artistId,
        'album': album,
        'albumId': albumId,
        'durationMs': duration.inMilliseconds,
        'audioUrl': audioUrl,
        'artworkUrl': artworkUrl,
        'lyrics': lyrics.map((l) => l.toJson()).toList(),
        'isLiked': isLiked,
        'plays': plays,
        'genre': genre,
        'releaseDate': releaseDate,
      };

  factory Song.fromJson(Map<String, dynamic> json) => Song(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? 'Unknown Title',
        artist: json['artist'] as String? ?? 'Unknown Artist',
        artistId: json['artistId'] as String? ?? '',
        album: json['album'] as String? ?? 'Single',
        albumId: json['albumId'] as String? ?? '',
        duration: Duration(milliseconds: json['durationMs'] as int? ?? 180000),
        audioUrl: json['audioUrl'] as String? ?? '',
        artworkUrl: json['artworkUrl'] as String? ?? '',
        lyrics: (json['lyrics'] as List<dynamic>?)
                ?.map((l) => LyricLine.fromJson(l as Map<String, dynamic>))
                .toList() ??
            [],
        isLiked: json['isLiked'] as bool? ?? false,
        plays: json['plays'] as int? ?? 0,
        genre: json['genre'] as String? ?? 'Electronic',
        releaseDate: json['releaseDate'] as String?,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Song && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
