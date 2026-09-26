import '../../../core/network/api_client.dart';
import '../../home/models/post.dart';

class ExploreService {
  final ApiClient apiClient;

  ExploreService({required this.apiClient});

  Future<List<Post>> getPosts() async {
    final response = await apiClient.dio.get('posts/explore/');

    return (response.data as List).map((json) => Post.fromJson(json)).toList();
  }

  Future<List<Post>> getMoviePosts(int movieId) async {
    final response = await apiClient.dio.get('posts/movies/$movieId/posts/');

    return (response.data as List).map((json) => Post.fromJson(json)).toList();
  }
}
