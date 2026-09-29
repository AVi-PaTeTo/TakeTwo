import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/shared/models/post.dart';
import 'package:mobile/shared/providers/post_cache_provider.dart';

import '../providers/explore_provider.dart';
import 'explore_post.dart';

class ExploreMoviePage extends ConsumerWidget {
  final Post post;

  const ExploreMoviePage({super.key, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allCachedPosts = ref.watch(postCacheProvider).values.toList();
    final moviePosts = allCachedPosts
        .where((p) => p.movie.id == post.movie.id)
        .toList();

    // Fallback to at least showing the current post if none others are cached yet
    final posts = moviePosts.isNotEmpty ? moviePosts : [post];

    return PageView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: posts.length,
      itemBuilder: (context, index) {
        return ExplorePost(post: posts[index]);
      },
    );
  }
}
