class SearchUser {
  final int id;
  final String username;
  final String? profilePictureUrl;

  const SearchUser({
    required this.id,
    required this.username,
    this.profilePictureUrl,
  });

  factory SearchUser.fromJson(Map<String, dynamic> json) {
    return SearchUser(
      id: json['id'],
      username: json['username'] ?? '',
      profilePictureUrl: json['profile_picture_url'] ?? '',
    );
  }
}
