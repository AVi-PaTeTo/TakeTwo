import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/shared/models/post.dart';
import 'package:mobile/shared/providers/post_cache_provider.dart';

import '../../../core/network/providers.dart';
import '../services/explore_service.dart';

final exploreServiceProvider = Provider<ExploreService>((ref) {
  return ExploreService(apiClient: ref.read(apiClientProvider));
});

final explorePostsProvider =
    AsyncNotifierProvider.autoDispose<ExplorePostsNotifier, List<int>>(
      ExplorePostsNotifier.new,
    );

final exploreMoviePostsProvider = Provider.autoDispose<AsyncValue<List<Post>>>((
  ref,
) {
  final postIdsAsync = ref.watch(explorePostsProvider);
  final cache = ref.watch(postCacheProvider);

  return postIdsAsync.whenData((ids) {
    // Look up posts from the global cache reactively
    final posts = ids.map((id) => cache[id]).whereType<Post>().toList();

    // Deduplicate by movie ID
    final movies = <int, Post>{};
    for (final post in posts) {
      movies.putIfAbsent(post.movie.id, () => post);
    }
    return movies.values.toList();
  });
});

class ExplorePostsNotifier extends AsyncNotifier<List<int>> {
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isFetchingMore = false;

  ExploreService get _service => ref.read(exploreServiceProvider);

  @override
  Future<List<int>> build() async {
    return _fetchInitialPage();
  }

  Future<List<int>> _fetchInitialPage() async {
    _currentPage = 1;
    _hasMore = true;

    final result = await _service.getPosts(page: _currentPage);
    _hasMore = result.hasMore;

    ref.read(postCacheProvider.notifier).cachePosts(result.posts);

    return result.posts.map((p) => p.id).toList();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchInitialPage());
  }

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

      ref.read(postCacheProvider.notifier).cachePosts(result.posts);

      final currentIds = state.value ?? [];
      final newIds = result.posts.map((p) => p.id).toList();

      state = AsyncData([...currentIds, ...newIds]);
    } catch (e) {
      _currentPage--;
    } finally {
      _isFetchingMore = false;
    }
  }

  Future<List<Post>> getMoviePosts(int movieId) async {
    final posts = await _service.getMoviePosts(movieId);
    ref.read(postCacheProvider.notifier).cachePosts(posts);
    return posts;
  }
}
