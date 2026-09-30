import 'package:mobile/shared/models/post.dart';
import 'package:mobile/shared/models/comment.dart';

import '../../core/network/api_client.dart';

class PostService {
  final ApiClient apiClient;

  PostService({required this.apiClient});

  // --- Posts & Feeds ---
  Future<({List<Post> posts, bool hasMore})> getPosts({int page = 1}) async {
    final response = await apiClient.dio.get(
      'posts/',
      queryParameters: {'page': page},
    );

    final dynamic data = response.data;

    if (data is Map) {
      final List listData = data['results'] ?? [];
      final posts = listData.map((json) => Post.fromJson(json)).toList();

      // DRF provides 'next' as a String URL or null when it's the last page
      final bool hasMore = data['next'] != null;

      return (posts: posts, hasMore: hasMore);
    }

    // Fallback for unpaginated lists
    if (data is List) {
      final posts = data.map((json) => Post.fromJson(json)).toList();
      return (posts: posts, hasMore: false);
    }

    return (posts: <Post>[], hasMore: false);
  }

  Future<List<Post>> searchPosts(String query) async {
    final response = await apiClient.dio.get(
      'posts/search/',
      queryParameters: {'q': query},
    );
    return (response.data as List).map((json) => Post.fromJson(json)).toList();
  }

  Future<void> likePost(int postId) async {
    await apiClient.dio.post('posts/$postId/like/');
  }

  Future<void> unlikePost(int postId) async {
    await apiClient.dio.delete('posts/$postId/like/');
  }

  // --- Comments & Replies ---
  Future<List<Comment>> getComments(int postId) async {
    final response = await apiClient.dio.get('posts/$postId/comments/');
    return (response.data as List)
        .map((json) => Comment.fromJson(json))
        .toList();
  }

  Future<void> addComment(int postId, String content) async {
    await apiClient.dio.post(
      'posts/$postId/comments/',
      data: {'content': content},
    );
  }

  Future<void> replyToComment(
    int commentId,
    String content,
    int replyToUserId,
  ) async {
    await apiClient.dio.post(
      'posts/comments/$commentId/replies/',
      data: {'reply_to': replyToUserId, 'content': content},
    );
  }

  Future<void> likeComment(int commentId) async {
    await apiClient.dio.post('posts/comments/$commentId/like/');
  }

  Future<void> unlikeComment(int commentId) async {
    await apiClient.dio.delete('posts/comments/$commentId/like/');
  }
}
