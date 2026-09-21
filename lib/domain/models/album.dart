/// Album Domain Model
class Album {
  final String id;
  final String title;
  final String artist;
  final String artistId;
  final String coverUrl;
  final int releaseYear;
  final List<String> songIds;
  final String genre;

  const Album({
    required this.id,
    required this.title,
    required this.artist,
    required this.artistId,
    required this.coverUrl,
    required this.releaseYear,
    this.songIds = const [],
    this.genre = 'Electronic',
  });

  Album copyWith({
    String? id,
    String? title,
    String? artist,
    String? artistId,
    String? coverUrl,
    int? releaseYear,
    List<String>? songIds,
    String? genre,
  }) {
    return Album(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      artistId: artistId ?? this.artistId,
      coverUrl: coverUrl ?? this.coverUrl,
      releaseYear: releaseYear ?? this.releaseYear,
      songIds: songIds ?? this.songIds,
      genre: genre ?? this.genre,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'artist': artist,
        'artistId': artistId,
        'coverUrl': coverUrl,
        'releaseYear': releaseYear,
        'songIds': songIds,
        'genre': genre,
      };

  factory Album.fromJson(Map<String, dynamic> json) => Album(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        artist: json['artist'] as String? ?? '',
        artistId: json['artistId'] as String? ?? '',
        coverUrl: json['coverUrl'] as String? ?? '',
        releaseYear: json['releaseYear'] as int? ?? 2026,
        songIds: (json['songIds'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        genre: json['genre'] as String? ?? 'Electronic',
      );
}
