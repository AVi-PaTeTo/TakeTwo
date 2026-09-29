import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mobile/shared/models/post.dart';

import '../providers/explore_provider.dart';
import '../widgets/explore_movie_page.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _precacheNextPoster(List<Post> moviePosts, int currentIndex) {
    final nextIndex = currentIndex + 1;
    if (nextIndex < moviePosts.length) {
      final nextPost = moviePosts[nextIndex];
      final posterPath = nextPost.customPosterUrl?.isNotEmpty == true
          ? nextPost.customPosterUrl
          : nextPost.movie.posterPath != null
          ? 'https://image.tmdb.org/t/p/w500${nextPost.movie.posterPath}'
          : null;

      if (posterPath != null) {
        precacheImage(CachedNetworkImageProvider(posterPath), context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the clean derived provider instead of handling raw lists & loops here
    final moviePostsAsync = ref.watch(exploreMoviePostsProvider);

    return Scaffold(
      body: moviePostsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text(
            'Failed to load explore posts:\n$error',
            textAlign: TextAlign.center,
          ),
        ),
        data: (moviePosts) {
          if (moviePosts.isEmpty) {
            return const Center(child: Text('No posts to explore yet.'));
          }

          return PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: moviePosts.length,
            onPageChanged: (index) {
              _precacheNextPoster(moviePosts, index);

              if (index >= moviePosts.length - 2) {
                ref.read(explorePostsProvider.notifier).loadMore();
              }
            },
            itemBuilder: (context, index) {
              return ExploreMoviePage(post: moviePosts[index]);
            },
          );
        },
      ),
    );
  }
}
