import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../providers/explore_provider.dart';
// import '../../../core/config/tmdb_image.dart';
// import '../widgets/explore_post.dart';
import '../widgets/explore_movie_page.dart';
import '../../home/models/post.dart';

class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(explorePostsProvider);

    return Scaffold(
      body: postsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text(
            'Failed to load explore posts:\n$error',
            textAlign: TextAlign.center,
          ),
        ),
        data: (posts) {
          if (posts.isEmpty) {
            return const Center(child: Text('No posts to explore yet.'));
          }

          final movies = <int, Post>{};

          for (final post in posts) {
            movies[post.movie.id] = post;
          }

          final moviePosts = movies.values.toList();

          return PageView.builder(
            scrollDirection: Axis.vertical,
            itemCount: moviePosts.length,
            itemBuilder: (context, index) {
              return ExploreMoviePage(post: moviePosts[index]);
            },
          );
        },
      ),
    );
  }
}
