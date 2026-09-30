import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/providers.dart';
import '../models/user_detail.dart';

// Import the shared post cache provider
import 'package:mobile/shared/providers/post_cache_provider.dart';

final userDetailProvider =
    AsyncNotifierProvider.family<UserDetailNotifier, UserDetail, int>(
      UserDetailNotifier.new,
    );

class UserDetailNotifier extends AsyncNotifier<UserDetail> {
  UserDetailNotifier(this.userId);
  late int userId;

  int _currentPage = 1;
  bool _isFetchingMore = false;

  @override
  Future<UserDetail> build() async {
    return _fetchUserDetail(page: 1);
  }

  Future<UserDetail> _fetchUserDetail({int page = 1}) async {
    _currentPage = page;
    final api = ref.read(apiClientProvider);

    final response = await api.dio.get(
      '/auth/users/$userId/',
      queryParameters: {'page': page},
    );
    final userDetail = UserDetail.fromJson(response.data);

    if (userDetail.posts.isNotEmpty) {
      ref.read(postCacheProvider.notifier).cachePosts(userDetail.posts);
    }

    return userDetail;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchUserDetail(page: 1));
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || _isFetchingMore || !current.hasMorePosts) return;

    _isFetchingMore = true;
    final targetPage = _currentPage + 1;

    try {
      final api = ref.read(apiClientProvider);
      final response = await api.dio.get(
        '/auth/users/$userId/',
        queryParameters: {'page': targetPage},
      );

      final nextPageDetail = UserDetail.fromJson(response.data);

      if (nextPageDetail.posts.isNotEmpty) {
        ref.read(postCacheProvider.notifier).cachePosts(nextPageDetail.posts);
      }
      _currentPage = targetPage;
      state = AsyncData(
        current.copyWith(
          posts: [...current.posts, ...nextPageDetail.posts],
          hasMorePosts: nextPageDetail.hasMorePosts,
        ),
      );
    } finally {
      _isFetchingMore = false;
    }
  }

  Future<void> toggleFollow() async {
    final current = state.value;
    if (current == null) return;

    final api = ref.read(apiClientProvider);
    final wasFollowing = current.isFollowing;

    // Optimistic UI update
    state = AsyncData(
      current.copyWith(
        isFollowing: !wasFollowing,
        followerCount: wasFollowing
            ? current.followerCount - 1
            : current.followerCount + 1,
      ),
    );

    try {
      if (wasFollowing) {
        await api.dio.delete('/users/$userId/follow/');
      } else {
        await api.dio.post('/users/$userId/follow/');
      }
    } catch (e) {
      // Roll back if the request failed.
      state = AsyncData(current);
    }
  }
}
