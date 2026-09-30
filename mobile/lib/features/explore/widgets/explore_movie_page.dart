import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/shared/models/post.dart';
import 'package:mobile/shared/providers/post_cache_provider.dart';

import '../../../core/config/tmdb_image.dart';
import 'explore_post.dart';

class ExploreMoviePage extends ConsumerStatefulWidget {
  final Post post;

  const ExploreMoviePage({super.key, required this.post});

  @override
  ConsumerState<ExploreMoviePage> createState() => _ExploreMoviePageState();
}

class _ExploreMoviePageState extends ConsumerState<ExploreMoviePage> {
  bool _initialPrefetchStarted = false;

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

  void _precacheNextPosts(List<Post> posts, int currentIndex) {
    for (int offset = 1; offset <= 2; offset++) {
      final nextIndex = currentIndex + offset;

      if (nextIndex >= posts.length) {
        break;
      }

      _precachePoster(posts[nextIndex]);
    }
  }

  void _precacheInitialPosts(List<Post> posts) {
    if (_initialPrefetchStarted) {
      return;
    }

    _initialPrefetchStarted = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      for (int index = 0; index < 2 && index < posts.length; index++) {
        _precachePoster(posts[index]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final allCachedPosts = ref.watch(postCacheProvider).values.toList();

    final moviePosts = allCachedPosts
        .where((post) => post.movie.id == widget.post.movie.id)
        .toList();

    final posts = moviePosts.isNotEmpty ? moviePosts : [widget.post];

    _precacheInitialPosts(posts);

    return PageView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: posts.length,

      onPageChanged: (index) {
        _precacheNextPosts(posts, index);
      },

      itemBuilder: (context, index) {
        return ExplorePost(post: posts[index]);
      },
    );
  }
}
