class SearchUser {
  final int id;
  final String username;

  const SearchUser({required this.id, required this.username});

  factory SearchUser.fromJson(Map<String, dynamic> json) {
    return SearchUser(id: json['id'], username: json['username'] ?? '');
  }
}
