import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/shared/models/post.dart';
import 'package:mobile/shared/providers/post_cache_provider.dart';

// Import the shared error view widget
import 'package:mobile/shared/widgets/app_error_view.dart';

import '../../../core/config/tmdb_image.dart';
import '../providers/explore_provider.dart';
import '../widgets/explore_movie_page.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final PageController _pageController = PageController();

  // Keeps us from repeatedly scheduling the same movie for preloading.
  final Set<int> _prefetchedMovieIds = {};

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String? _getPosterUrl(Post post) {
    if (post.customPosterUrl?.isNotEmpty == true) {
      return post.customPosterUrl;
    }

    if (post.movie.posterPath?.isNotEmpty == true) {
      return TmdbImage.poster(post.movie.posterPath);
    }

    return null;
  }

  void _precachePoster(Post post) {
    final posterUrl = _getPosterUrl(post);

    if (posterUrl == null) {
      return;
    }

    precacheImage(CachedNetworkImageProvider(posterUrl), context);
  }

  void _precacheMovie(Post representativePost, Map<int, Post> postCache) {
    final movieId = representativePost.movie.id;

    if (_prefetchedMovieIds.contains(movieId)) {
      return;
    }

    _prefetchedMovieIds.add(movieId);

    // Find all currently cached posts belonging to this movie.
    final moviePosts = postCache.values
        .where((post) => post.movie.id == movieId)
        .toList();

    if (moviePosts.isEmpty) {
      // At minimum, preload the representative post's poster.
      _precachePoster(representativePost);
      return;
    }

    // Preload the first two horizontal posts for this movie.
    for (final post in moviePosts.take(2)) {
      _precachePoster(post);
    }
  }

  void _precacheNearbyMovies(
    List<Post> movies,
    Map<int, Post> postCache,
    int currentIndex,
  ) {
    // Preload the next TWO vertical movie pages.
    for (int offset = 1; offset <= 2; offset++) {
      final nextIndex = currentIndex + offset;

      if (nextIndex >= movies.length) {
        break;
      }

      _precacheMovie(movies[nextIndex], postCache);
    }
  }

  void _precacheInitialMovies(List<Post> movies, Map<int, Post> postCache) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      // Current movie + next two movies.
      for (int index = 0; index < 3 && index < movies.length; index++) {
        _precacheMovie(movies[index], postCache);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final moviePostsAsync = ref.watch(exploreMoviePostsProvider);

    // Normalized post cache is our source of truth.
    final postCache = ref.watch(postCacheProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(explorePostsProvider.notifier).refresh();

          // Allow the newly loaded feed to be preloaded again.
          _prefetchedMovieIds.clear();
        },
        child: moviePostsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),

          // --- UNIFORM ERROR STATE USING APP ERROR VIEW ---
          error: (error, stack) => AppErrorView(
            error: error,
            onRetry: () => ref.read(explorePostsProvider.notifier).refresh(),
          ),

          data: (movies) {
            if (movies.isEmpty) {
              return const Center(child: Text('No posts to explore yet.'));
            }

            // Prepare the initial movie + next two movies.
            _precacheInitialMovies(movies, postCache);

            return PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              itemCount: movies.length,

              onPageChanged: (index) {
                // Prepare the next two vertical pages.
                _precacheNearbyMovies(movies, postCache, index);

                // Load more backend data near the end.
                if (index >= movies.length - 2) {
                  ref.read(explorePostsProvider.notifier).loadMore();
                }
              },

              itemBuilder: (context, index) {
                return ExploreMoviePage(post: movies[index]);
              },
            );
          },
        ),
      ),
    );
  }
}
