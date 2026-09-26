import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/providers.dart';
import '../services/explore_service.dart';
import '../../home/models/post.dart';

final exploreServiceProvider = Provider<ExploreService>((ref) {
  return ExploreService(apiClient: ref.read(apiClientProvider));
});

final explorePostsProvider =
    AsyncNotifierProvider<ExplorePostsNotifier, List<Post>>(
      ExplorePostsNotifier.new,
    );

class ExplorePostsNotifier extends AsyncNotifier<List<Post>> {
  final Map<int, List<Post>> _moviePostsCache = {};

  @override
  Future<List<Post>> build() async {
    return ref.read(exploreServiceProvider).getPosts();
  }

  Future<List<Post>> getMoviePosts(int movieId) async {
    final cached = _moviePostsCache[movieId];

    if (cached != null) {
      return cached;
    }

    final posts = await ref.read(exploreServiceProvider).getMoviePosts(movieId);

    _moviePostsCache[movieId] = posts;

    return posts;
  }
}
