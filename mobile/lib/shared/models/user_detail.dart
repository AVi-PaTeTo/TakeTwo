import 'post.dart';

class UserDetail {
  final int id;
  final String username;
  final List<int> preferredGenres;
  final int postCount;
  final int followerCount;
  final int followingCount;
  final bool isFollowing;
  final List<Post> posts;
  final bool hasMorePosts;

  UserDetail({
    required this.id,
    required this.username,
    required this.preferredGenres,
    required this.postCount,
    required this.followerCount,
    required this.followingCount,
    required this.isFollowing,
    required this.posts,
    required this.hasMorePosts,
  });

  factory UserDetail.fromJson(Map<String, dynamic> json) {
    final postsData = json['posts'];
    List<Post> parsedPosts = [];
    bool hasMore = false;

    if (postsData is Map<String, dynamic>) {
      final results = postsData['results'] as List<dynamic>? ?? [];
      parsedPosts = results.map((post) => Post.fromJson(post)).toList();
      hasMore = postsData['next'] != null;
    } else if (postsData is List<dynamic>) {
      parsedPosts = postsData.map((post) => Post.fromJson(post)).toList();
    }

    return UserDetail(
      id: json['id'],
      username: json['username'],
      preferredGenres: List<int>.from(json['preferred_genres'] ?? []),
      postCount: json['post_count'] ?? 0,
      followerCount: json['follower_count'] ?? 0,
      followingCount: json['following_count'] ?? 0,
      isFollowing: json['is_following'] ?? false,
      posts: parsedPosts,
      hasMorePosts: hasMore,
    );
  }

  UserDetail copyWith({
    bool? isFollowing,
    int? followerCount,
    List<Post>? posts,
    bool? hasMorePosts,
  }) {
    return UserDetail(
      id: id,
      username: username,
      preferredGenres: preferredGenres,
      postCount: postCount,
      followerCount: followerCount ?? this.followerCount,
      followingCount: followingCount,
      isFollowing: isFollowing ?? this.isFollowing,
      posts: posts ?? this.posts,
      hasMorePosts: hasMorePosts ?? this.hasMorePosts,
    );
  }
}
