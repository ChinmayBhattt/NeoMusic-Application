/// User Profile Domain Model
class UserProfile {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;
  final String membershipTier;
  final bool isSubscribed;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
    this.membershipTier = 'Neo Premium',
    this.isSubscribed = true,
  });

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    String? membershipTier,
    bool? isSubscribed,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      membershipTier: membershipTier ?? this.membershipTier,
      isSubscribed: isSubscribed ?? this.isSubscribed,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'avatarUrl': avatarUrl,
        'membershipTier': membershipTier,
        'isSubscribed': isSubscribed,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? 'Music Explorer',
        email: json['email'] as String? ?? 'explorer@neomusic.stream',
        avatarUrl: json['avatarUrl'] as String? ?? '',
        membershipTier: json['membershipTier'] as String? ?? 'Neo Premium',
        isSubscribed: json['isSubscribed'] as bool? ?? true,
      );
}
