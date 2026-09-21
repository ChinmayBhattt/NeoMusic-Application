/// Artist Domain Model
class Artist {
  final String id;
  final String name;
  final String avatarUrl;
  final String bio;
  final int monthlyListeners;
  final bool isFollowed;
  final List<String> topSongIds;
  final List<String> albumIds;

  const Artist({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.bio,
    this.monthlyListeners = 0,
    this.isFollowed = false,
    this.topSongIds = const [],
    this.albumIds = const [],
  });

  Artist copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    String? bio,
    int? monthlyListeners,
    bool? isFollowed,
    List<String>? topSongIds,
    List<String>? albumIds,
  }) {
    return Artist(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      monthlyListeners: monthlyListeners ?? this.monthlyListeners,
      isFollowed: isFollowed ?? this.isFollowed,
      topSongIds: topSongIds ?? this.topSongIds,
      albumIds: albumIds ?? this.albumIds,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'avatarUrl': avatarUrl,
        'bio': bio,
        'monthlyListeners': monthlyListeners,
        'isFollowed': isFollowed,
        'topSongIds': topSongIds,
        'albumIds': albumIds,
      };

  factory Artist.fromJson(Map<String, dynamic> json) => Artist(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        avatarUrl: json['avatarUrl'] as String? ?? '',
        bio: json['bio'] as String? ?? '',
        monthlyListeners: json['monthlyListeners'] as int? ?? 0,
        isFollowed: json['isFollowed'] as bool? ?? false,
        topSongIds: (json['topSongIds'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        albumIds: (json['albumIds'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
      );
}
