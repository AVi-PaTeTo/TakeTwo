import 'package:mobile/shared/models/post.dart';

import '../../../core/network/api_client.dart';

class ExploreService {
  final ApiClient apiClient;

  ExploreService({required this.apiClient});

  // Added an optional page parameter for pagination/prefetching
  Future<List<Post>> getPosts({int page = 1}) async {
    final response = await apiClient.dio.get(
      'posts/explore/',
      queryParameters: {'page': page},
    );

    // Handles both standard list responses and DRF paginated responses ({'results': [...]})
    final dynamic data = response.data;
    final List listData = data is Map ? (data['results'] ?? []) : data;

    return listData.map((json) => Post.fromJson(json)).toList();
  }

  Future<List<Post>> getMoviePosts(int movieId) async {
    final response = await apiClient.dio.get('posts/movies/$movieId/posts/');
    return (response.data as List).map((json) => Post.fromJson(json)).toList();
  }
}
