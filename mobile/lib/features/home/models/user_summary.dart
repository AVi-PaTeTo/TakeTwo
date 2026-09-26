class UserSummary {
  final int id;
  final String username;

  const UserSummary({required this.id, required this.username});

  factory UserSummary.fromJson(Map<String, dynamic> json) {
    return UserSummary(id: json['id'], username: json['username']);
  }
}
