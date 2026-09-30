import 'package:mobile/shared/models/post.dart';

import '../../../core/network/api_client.dart';

class ExploreService {
  final ApiClient apiClient;

  ExploreService({required this.apiClient});

  // Added an optional page parameter for pagination/prefetching
  Future<({List<Post> posts, bool hasMore})> getPosts({int page = 1}) async {
    final response = await apiClient.dio.get(
      'posts/explore/',
      queryParameters: {'page': page},
    );

    // Handles both standard list responses and DRF paginated responses ({'results': [...]})
    final dynamic data = response.data;
    if (data is Map) {
      final List listData = data['results'] ?? [];
      final posts = listData.map((json) => Post.fromJson(json)).toList();

      final bool hasMore = data['next'] != null;

      return (posts: posts, hasMore: hasMore);
    }

    if (data is List) {
      final posts = data.map((json) => Post.fromJson(json)).toList();
      return (posts: posts, hasMore: false);
    }

    return (posts: <Post>[], hasMore: false);
  }

  Future<List<Post>> getMoviePosts(int movieId) async {
    final response = await apiClient.dio.get('posts/movies/$movieId/posts/');
    return (response.data as List).map((json) => Post.fromJson(json)).toList();
  }
}
