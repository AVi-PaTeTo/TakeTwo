class UserSuggestion {
  final int id;
  final String username;
  final String? profilePictureUrl;
  final int sharedGenres;

  const UserSuggestion({
    required this.id,
    required this.username,
    this.profilePictureUrl,
    required this.sharedGenres,
  });

  factory UserSuggestion.fromJson(Map<String, dynamic> json) {
    return UserSuggestion(
      id: json['id'],
      username: json['username'] ?? '',
      profilePictureUrl: json['profile_picture_url'],
      sharedGenres: json['shared_genres'] ?? 0,
    );
  }
}
