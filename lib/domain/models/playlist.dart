/// Playlist Domain Model
class Playlist {
  final String id;
  final String name;
  final String description;
  final String coverUrl;
  final List<String> songIds;
  final bool isCustom;
  final DateTime createdAt;

  const Playlist({
    required this.id,
    required this.name,
    required this.description,
    required this.coverUrl,
    required this.songIds,
    this.isCustom = false,
    required this.createdAt,
  });

  Playlist copyWith({
    String? id,
    String? name,
    String? description,
    String? coverUrl,
    List<String>? songIds,
    bool? isCustom,
    DateTime? createdAt,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      coverUrl: coverUrl ?? this.coverUrl,
      songIds: songIds ?? this.songIds,
      isCustom: isCustom ?? this.isCustom,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'coverUrl': coverUrl,
        'songIds': songIds,
        'isCustom': isCustom,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Playlist.fromJson(Map<String, dynamic> json) => Playlist(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        description: json['description'] as String? ?? '',
        coverUrl: json['coverUrl'] as String? ?? '',
        songIds: (json['songIds'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        isCustom: json['isCustom'] as bool? ?? false,
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
            : DateTime.now(),
      );
}
