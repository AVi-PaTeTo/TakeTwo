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
  int _currentIndex = 0;

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
    if (posterUrl == null) return;
    precacheImage(CachedNetworkImageProvider(posterUrl), context);
  }

  void _precacheNextPosts(List<Post> posts, int currentIndex) {
    for (int offset = 1; offset <= 2; offset++) {
      final nextIndex = currentIndex + offset;
      if (nextIndex >= posts.length) break;
      _precachePoster(posts[nextIndex]);
    }
  }

  void _precacheInitialPosts(List<Post> posts) {
    if (_initialPrefetchStarted) return;
    _initialPrefetchStarted = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
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

    // Get the current post and check cache for any live updates
    final currentPost = posts[_currentIndex.clamp(0, posts.length - 1)];
    final liveCurrentPost =
        ref.watch(postProvider(currentPost.id)) ?? currentPost;
    final posterUrl = _getPosterUrl(liveCurrentPost);

    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. STATIC BACKGROUND POSTER WITH SMOOTH FADE
        if (posterUrl != null)
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              // SizedBox.expand forces the image to take up the full screen width and height
              child: SizedBox.expand(
                key: ValueKey(
                  posterUrl,
                ), // Triggers fade if custom poster changes
                child: CachedNetworkImage(
                  imageUrl: posterUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      const ColoredBox(color: Colors.black),
                  errorWidget: (context, url, error) => const ColoredBox(
                    color: Colors.black,
                    child: Center(
                      child: Icon(
                        Icons.broken_image,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

        // 2. STATIC DARK GRADIENT OVERLAY
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.35, 1.0],
                colors: [Colors.black26, Colors.black],
              ),
            ),
          ),
        ),

        // 3. HORIZONTAL PAGE VIEW FOR CONTENT ONLY
        PageView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: posts.length,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
            _precacheNextPosts(posts, index);
          },
          itemBuilder: (context, index) {
            return ExplorePost(post: posts[index]);
          },
        ),
      ],
    );
  }
}
