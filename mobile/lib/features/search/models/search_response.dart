import 'package:mobile/features/search/models/search_user.dart';
import 'package:mobile/features/search/models/search_post.dart';

class SearchResponse {
  final List<SearchUser> users;
  final List<SearchPost> posts;

  const SearchResponse({this.users = const [], this.posts = const []});

  factory SearchResponse.fromJson(Map<String, dynamic> json) {
    return SearchResponse(
      users: (json['users'] as List<dynamic>? ?? [])
          .map((user) => SearchUser.fromJson(user as Map<String, dynamic>))
          .toList(),
      posts: (json['posts'] as List<dynamic>? ?? [])
          .map((post) => SearchPost.fromJson(post as Map<String, dynamic>))
          .toList(),
    );
  }
}
