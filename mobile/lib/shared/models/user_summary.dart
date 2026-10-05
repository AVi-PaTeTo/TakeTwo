class UserSummary {
  final int id;
  final String username;
  final String? profilePictureUrl;

  const UserSummary({
    required this.id,
    required this.username,
    this.profilePictureUrl,
  });

  factory UserSummary.fromJson(Map<String, dynamic> json) {
    return UserSummary(
      id: json['id'],
      username: json['username'] ?? '',
      profilePictureUrl: json['profile_picture_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'profile_picture_url': profilePictureUrl,
    };
  }
}
