import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'post_cache_provider.dart';

// Home Feed Provider (Stores just a List of Post IDs)
final homeFeedIdsProvider =
    AsyncNotifierProvider<HomeFeedIdsNotifier, List<int>>(() {
      return HomeFeedIdsNotifier();
    });

class HomeFeedIdsNotifier extends AsyncNotifier<List<int>> {
  @override
  Future<List<int>> build() async {
    final service = ref.read(postServiceProvider);
    final posts = await service.getHomeFeed();

    // 1. Push raw posts into the central cache
    ref.read(postCacheProvider.notifier).cachePosts(posts);

    // 2. Return only the IDs for the home feed list
    return posts.map((p) => p.id).toList();
  }

  // Global action: Toggling a like updates the central cache instantly visible everywhere
  Future<void> toggleLike(int postId) async {
    final cache = ref.read(postCacheProvider);
    final post = cache[postId];
    if (post == null) return;

    final service = ref.read(postServiceProvider);
    final newLikedState = !post.isLiked;
    final newLikeCount = post.likeCount + (newLikedState ? 1 : -1);

    // Optimistic update in cache
    final updatedPost = post.copyWith(
      isLiked: newLikedState,
      likeCount: newLikeCount,
    );
    ref.read(postCacheProvider.notifier).updatePost(updatedPost);

    try {
      if (newLikedState) {
        await service.likePost(postId);
      } else {
        await service.unlikePost(postId);
      }
    } catch (e) {
      // Revert cache on failure
      ref.read(postCacheProvider.notifier).updatePost(post);
    }
  }
}
