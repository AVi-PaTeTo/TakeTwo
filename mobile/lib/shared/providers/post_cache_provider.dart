import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/shared/models/post.dart';
import 'package:mobile/shared/services/post_service.dart';

import '../../core/network/providers.dart';

// 1. Service provider
final postServiceProvider = Provider<PostService>((ref) {
  return PostService(apiClient: ref.read(apiClientProvider));
});

// 2. Central Entity Cache (Map of Post ID -> Post Object)
final postCacheProvider = NotifierProvider<PostCacheNotifier, Map<int, Post>>(
  () {
    return PostCacheNotifier();
  },
);

class PostCacheNotifier extends Notifier<Map<int, Post>> {
  @override
  Map<int, Post> build() => {};

  // Bulk add/update posts into cache whenever an API call fetches them
  void cachePosts(List<Post> posts) {
    state = {...state, for (var post in posts) post.id: post};
  }

  // Update a single post (e.g. optimistic like toggle)
  void updatePost(Post updatedPost) {
    if (state.containsKey(updatedPost.id)) {
      state = {...state, updatedPost.id: updatedPost};
    }
  }
}

// 3. Family provider: Widgets can watch a specific post ID from anywhere
final postProvider = Provider.family<Post?, int>((ref, postId) {
  final cache = ref.watch(postCacheProvider);
  return cache[postId];
});
