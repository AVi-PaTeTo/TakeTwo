import 'package:mobile/features/search/models/search_user.dart';
import 'package:mobile/shared/models/post.dart';

class SearchPage<T> {
  final int count;
  final int? next;
  final int? previous;
  final List<T> results;

  const SearchPage({
    this.count = 0,
    this.next,
    this.previous,
    this.results = const [],
  });
}

class SearchResponse {
  final SearchPage<SearchUser> users;
  final SearchPage<Post> posts;

  const SearchResponse({
    this.users = const SearchPage<SearchUser>(),
    this.posts = const SearchPage<Post>(),
  });

  factory SearchResponse.fromJson(Map<String, dynamic> json) {
    final usersJson = json['users'] as Map<String, dynamic>? ?? {};

    final postsJson = json['posts'] as Map<String, dynamic>? ?? {};

    return SearchResponse(
      users: SearchPage<SearchUser>(
        count: usersJson['count'] ?? 0,
        next: usersJson['next'],
        previous: usersJson['previous'],
        results: (usersJson['results'] as List<dynamic>? ?? [])
            .map((user) => SearchUser.fromJson(user as Map<String, dynamic>))
            .toList(),
      ),

      posts: SearchPage<Post>(
        count: postsJson['count'] ?? 0,
        next: postsJson['next'],
        previous: postsJson['previous'],
        results: (postsJson['results'] as List<dynamic>? ?? [])
            .map((post) => Post.fromJson(post as Map<String, dynamic>))
            .toList(),
      ),
    );
  }
}
