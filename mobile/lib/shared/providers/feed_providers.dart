import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/shared/providers/post_cache_provider.dart';
import 'package:mobile/shared/services/post_service.dart';

// Home Feed Provider (Stores just a List of Post IDs)
final homeFeedIdsProvider =
    AsyncNotifierProvider<HomeFeedIdsNotifier, List<int>>(() {
      return HomeFeedIdsNotifier();
    });

class HomeFeedIdsNotifier extends AsyncNotifier<List<int>> {
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isFetchingMore = false;

  PostService get _service => ref.read(postServiceProvider);

  @override
  Future<List<int>> build() async {
    return _fetchInitialPage();
  }

  Future<List<int>> _fetchInitialPage() async {
    _currentPage = 1;
    _hasMore = true;

    // Make sure your HomeFeed service method accepts an optional page parameter
    final result = await _service.getPosts(page: _currentPage);

    _hasMore = result.hasMore;
    // 1. Push raw posts into the central cache
    ref.read(postCacheProvider.notifier).cachePosts(result.posts);

    // 2. Return only the IDs for the home feed list
    return result.posts.map((p) => p.id).toList();
  }

  // --- PULL TO REFRESH ---
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchInitialPage());
  }

  // --- PAGINATION / PREFETCH ---
  Future<void> loadMore() async {
    if (_isFetchingMore || !_hasMore) return;
    _isFetchingMore = true;

    try {
      _currentPage++;
      final result = await _service.getPosts(page: _currentPage);

      _hasMore = result.hasMore;

      if (result.posts.isEmpty) {
        _isFetchingMore = false;
        return;
      }

      // 1. Cache the new posts globally
      ref.read(postCacheProvider.notifier).cachePosts(result.posts);

      // 2. Append their IDs to the existing home feed list
      final currentIds = state.value ?? [];
      final newIds = result.posts.map((p) => p.id).toList();

      state = AsyncData([...currentIds, ...newIds]);
    } catch (e) {
      _currentPage--; // Revert page index on error
    } finally {
      _isFetchingMore = false;
    }
  }

  // Global action: Toggling a like updates the central cache instantly visible everywhere
  Future<void> toggleLike(int postId) async {
    final cache = ref.read(postCacheProvider);
    final post = cache[postId];
    if (post == null) return;

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
        await _service.likePost(postId);
      } else {
        await _service.unlikePost(postId);
      }
    } catch (e) {
      // Revert cache on failure
      ref.read(postCacheProvider.notifier).updatePost(post);
    }
  }
}
