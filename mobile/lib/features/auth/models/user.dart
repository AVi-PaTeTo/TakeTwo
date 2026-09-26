class User {
  final int id;
  final String username;
  final String email;
  final List<int> preferredGenres;

  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.preferredGenres,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      preferredGenres: List<int>.from(json['preferred_genres'] ?? []),
    );
  }
}
