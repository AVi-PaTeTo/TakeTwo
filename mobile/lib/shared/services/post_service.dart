import 'package:mobile/shared/models/post.dart';
import 'package:mobile/shared/models/comment.dart';

import '../../core/network/api_client.dart';

class PostService {
  final ApiClient apiClient;

  PostService({required this.apiClient});

  // --- Posts & Feeds ---
  Future<List<Post>> getHomeFeed() async {
    final response = await apiClient.dio.get('posts/');
    return (response.data as List).map((json) => Post.fromJson(json)).toList();
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
