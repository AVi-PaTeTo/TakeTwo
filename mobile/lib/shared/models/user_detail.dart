import 'package:mobile/features/home/models/post.dart';

class UserDetail {
  final int id;
  final String username;
  final List<int> preferredGenres;
  final int postCount;
  final int followerCount;
  final int followingCount;
  final bool isFollowing;
  final List<Post> posts;

  UserDetail({
    required this.id,
    required this.username,
    required this.preferredGenres,
    required this.postCount,
    required this.followerCount,
    required this.followingCount,
    required this.isFollowing,
    required this.posts,
  });

  factory UserDetail.fromJson(Map<String, dynamic> json) {
    return UserDetail(
      id: json['id'],
      username: json['username'],
      preferredGenres: List<int>.from(json['preferred_genres'] ?? []),
      postCount: json['post_count'] ?? 0,
      followerCount: json['follower_count'] ?? 0,
      followingCount: json['following_count'] ?? 0,
      isFollowing: json['is_following'] ?? false,
      posts: (json['posts'] as List<dynamic>? ?? [])
          .map((post) => Post.fromJson(post))
          .toList(),
    );
  }

  UserDetail copyWith({bool? isFollowing, int? followerCount}) {
    return UserDetail(
      id: id,
      username: username,
      preferredGenres: preferredGenres,
      postCount: postCount,
      followerCount: followerCount ?? this.followerCount,
      followingCount: followingCount,
      isFollowing: isFollowing ?? this.isFollowing,
      posts: posts,
    );
  }
}
