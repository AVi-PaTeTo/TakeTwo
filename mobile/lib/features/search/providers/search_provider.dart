import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/providers.dart';

import '../models/search_user.dart';
import '../services/search_service.dart';

import 'package:mobile/shared/models/post.dart';
import 'package:mobile/shared/providers/post_cache_provider.dart';

final searchServiceProvider = Provider<SearchService>((ref) {
  return SearchService(ref.read(apiClientProvider));
});

final searchProvider = NotifierProvider<SearchNotifier, SearchState>(
  SearchNotifier.new,
);

class SearchState {
  final List<SearchUser> users;
  final List<Post> posts;

  final int userCount;
  final int postCount;

  final int nextUserPage;
  final int nextPostPage;

  final bool isLoading;
  final bool isLoadingMoreUsers;
  final bool isLoadingMorePosts;

  final String? error;

  final String query;

  const SearchState({
    this.users = const [],
    this.posts = const [],

    this.userCount = 0,
    this.postCount = 0,

    this.nextUserPage = 0,
    this.nextPostPage = 0,

    this.isLoading = false,
    this.isLoadingMoreUsers = false,
    this.isLoadingMorePosts = false,

    this.error,

    this.query = '',
  });

  bool get hasMoreUsers => nextUserPage > 0;

  bool get hasMorePosts => nextPostPage > 0;

  SearchState copyWith({
    List<SearchUser>? users,
    List<Post>? posts,

    int? userCount,
    int? postCount,

    int? nextUserPage,
    int? nextPostPage,

    bool? isLoading,
    bool? isLoadingMoreUsers,
    bool? isLoadingMorePosts,

    String? error,

    String? query,
  }) {
    return SearchState(
      users: users ?? this.users,
      posts: posts ?? this.posts,

      userCount: userCount ?? this.userCount,
      postCount: postCount ?? this.postCount,

      nextUserPage: nextUserPage ?? this.nextUserPage,
      nextPostPage: nextPostPage ?? this.nextPostPage,

      isLoading: isLoading ?? this.isLoading,
      isLoadingMoreUsers: isLoadingMoreUsers ?? this.isLoadingMoreUsers,
      isLoadingMorePosts: isLoadingMorePosts ?? this.isLoadingMorePosts,

      error: error,
      query: query ?? this.query,
    );
  }
}

class SearchNotifier extends Notifier<SearchState> {
  Timer? _debounce;

  SearchService get _service {
    return ref.read(searchServiceProvider);
  }

  @override
  SearchState build() {
    ref.onDispose(() {
      _debounce?.cancel();
    });

    return const SearchState();
  }

  // --------------------------------------------------
  // NEW SEARCH
  // --------------------------------------------------

  void search(String query) {
    _debounce?.cancel();

    final trimmedQuery = query.trim();

    if (trimmedQuery.isEmpty) {
      state = const SearchState();
      return;
    }

    state = SearchState(query: trimmedQuery, isLoading: true);

    _debounce = Timer(
      const Duration(milliseconds: 400),
      () => _performSearch(trimmedQuery),
    );
  }

  Future<void> _performSearch(String query) async {
    try {
      final results = await _service.search(query, userPage: 1, postPage: 1);

      final posts = results.posts.results;

      // Add search posts to the global normalized cache.
      if (posts.isNotEmpty) {
        ref.read(postCacheProvider.notifier).cachePosts(posts);
      }

      state = SearchState(
        query: query,

        users: results.users.results,
        posts: posts,

        userCount: results.users.count,
        postCount: results.posts.count,

        nextUserPage: results.users.next ?? 0,
        nextPostPage: results.posts.next ?? 0,

        isLoading: false,
      );
    } catch (e) {
      state = SearchState(
        query: query,
        isLoading: false,
        error: 'Something went wrong. Please try again.',
      );
    }
  }

  // --------------------------------------------------
  // LOAD MORE USERS
  // --------------------------------------------------

  Future<void> loadMoreUsers() async {
    if (state.isLoadingMoreUsers) {
      return;
    }

    if (!state.hasMoreUsers) {
      return;
    }

    if (state.query.isEmpty) {
      return;
    }

    final page = state.nextUserPage;

    state = state.copyWith(isLoadingMoreUsers: true);

    try {
      final results = await _service.search(state.query, userPage: page);

      state = state.copyWith(
        users: [...state.users, ...results.users.results],
        nextUserPage: results.users.next ?? 0,
        isLoadingMoreUsers: false,
      );
    } catch (_) {
      state = state.copyWith(isLoadingMoreUsers: false);
    }
  }

  // --------------------------------------------------
  // LOAD MORE POSTS
  // --------------------------------------------------

  Future<void> loadMorePosts() async {
    if (state.isLoadingMorePosts) {
      return;
    }

    if (!state.hasMorePosts) {
      return;
    }

    if (state.query.isEmpty) {
      return;
    }

    final page = state.nextPostPage;

    state = state.copyWith(isLoadingMorePosts: true);

    try {
      final results = await _service.search(state.query, postPage: page);

      final newPosts = results.posts.results;

      if (newPosts.isNotEmpty) {
        ref.read(postCacheProvider.notifier).cachePosts(newPosts);
      }

      state = state.copyWith(
        posts: [...state.posts, ...newPosts],
        nextPostPage: results.posts.next ?? 0,
        isLoadingMorePosts: false,
      );
    } catch (_) {
      state = state.copyWith(isLoadingMorePosts: false);
    }
  }

  // --------------------------------------------------
  // CLEAR
  // --------------------------------------------------

  void clear() {
    _debounce?.cancel();

    state = const SearchState();
  }
}
