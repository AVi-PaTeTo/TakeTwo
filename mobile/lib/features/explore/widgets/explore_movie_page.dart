import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/shared/models/post.dart';
import 'package:mobile/shared/providers/post_cache_provider.dart';

import '../../../core/config/tmdb_image.dart';
import '../providers/explore_provider.dart';
import 'explore_post.dart';

class ExploreMoviePage extends ConsumerStatefulWidget {
  final Post post;

  const ExploreMoviePage({super.key, required this.post});

  @override
  ConsumerState<ExploreMoviePage> createState() => _ExploreMoviePageState();
}

class _ExploreMoviePageState extends ConsumerState<ExploreMoviePage> {
  List<Post> _posts = [];
  bool _isLoading = true;
  Object? _error;

  int _currentIndex = 0;
  int? _loadedMovieId;

  final Set<String> _prefetchedPosterUrls = {};

  @override
  void initState() {
    super.initState();
    _loadMoviePosts();
  }

  @override
  void didUpdateWidget(covariant ExploreMoviePage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.post.movie.id != widget.post.movie.id) {
      _posts = [];
      _currentIndex = 0;
      _loadedMovieId = null;
      _error = null;
      _isLoading = true;
      _prefetchedPosterUrls.clear();

      _loadMoviePosts();
    }
  }

  String? _getPosterUrl(Post post) {
    if (post.customPosterUrl?.isNotEmpty == true) {
      return post.customPosterUrl;
    }

    if (post.movie.posterPath.isNotEmpty == true) {
      return TmdbImage.poster(post.movie.posterPath);
    }

    return null;
  }

  void _precachePoster(Post post) {
    final url = _getPosterUrl(post);

    if (url == null || !_prefetchedPosterUrls.add(url)) {
      return;
    }

    precacheImage(CachedNetworkImageProvider(url), context);
  }

  void _precacheNearbyPosts(List<Post> posts, int index) {
    for (int offset = 1; offset <= 2; offset++) {
      final nextIndex = index + offset;

      if (nextIndex >= posts.length) break;

      _precachePoster(posts[nextIndex]);
    }
  }

  Future<void> _loadMoviePosts() async {
    final movieId = widget.post.movie.id;

    try {
      // Fetch ALL posts for this movie independently of the
      // paginated vertical Explore feed.
      final fetchedPosts = await ref
          .read(explorePostsProvider.notifier)
          .getMoviePosts(movieId);

      if (!mounted || widget.post.movie.id != movieId) return;

      // Ensure the original vertical-feed post is available even
      // if the endpoint unexpectedly omits it.
      final posts = <Post>[...fetchedPosts];

      if (!posts.any((post) => post.id == widget.post.id)) {
        posts.insert(0, widget.post);
      }

      setState(() {
        _posts = posts;
        _loadedMovieId = movieId;
        _isLoading = false;
        _error = null;
        _currentIndex = 0;
      });

      // Preload the current and next two horizontal posters.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || widget.post.movie.id != movieId) return;

        for (final post in posts.take(3)) {
          _precachePoster(post);
        }
      });
    } catch (error) {
      if (!mounted || widget.post.movie.id != movieId) return;

      // Keep Explore usable even if fetching all movie posts fails.
      setState(() {
        _posts = [widget.post];
        _loadedMovieId = movieId;
        _isLoading = false;
        _error = error;
        _currentIndex = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // final cachedPost = ref.watch(postProvider(widget.post.id)) ?? widget.post;

    final movieId = widget.post.movie.id;

    // Avoid briefly showing posts from a previous movie if this
    // widget is reused for a different vertical page.
    final posts = _loadedMovieId == movieId && _posts.isNotEmpty
        ? _posts
        : [widget.post];

    final safeIndex = _currentIndex.clamp(0, posts.length - 1);
    final currentPost = posts[safeIndex];

    final liveCurrentPost =
        ref.watch(postProvider(currentPost.id)) ?? currentPost;

    final posterUrl = _getPosterUrl(liveCurrentPost);

    return Stack(
      fit: StackFit.expand,
      children: [
        // Full-screen movie poster.
        if (posterUrl != null)
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: SizedBox.expand(
                key: ValueKey(posterUrl),
                child: CachedNetworkImage(
                  imageUrl: posterUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => const ColoredBox(color: Colors.black),
                  errorWidget: (_, __, ___) => const ColoredBox(
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
          )
        else
          const Positioned.fill(child: ColoredBox(color: Colors.black)),

        // Keep the existing background gradient.
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.35, 1.0],
                colors: [Colors.black38, Colors.black],
              ),
            ),
          ),
        ),

        if (posts.length > 1)
          Positioned(
            left: 0,
            right: 0,
            bottom: 10,
            child: IgnorePointer(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(posts.length, (index) {
                  final isActive = index == _currentIndex;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: isActive ? 32 : 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(
                        alpha: isActive ? 0.9 : 0.4,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  );
                }),
              ),
            ),
          ),

        // Horizontal navigation between posts about this movie.
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else
          PageView.builder(
            key: ValueKey('movie-${widget.post.movie.id}'),
            scrollDirection: Axis.horizontal,
            itemCount: posts.length,
            allowImplicitScrolling: true,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });

              _precacheNearbyPosts(posts, index);
            },
            itemBuilder: (context, index) {
              return ExplorePost(post: posts[index]);
            },
          ),

        // A failed secondary request shouldn't break vertical Explore.
        if (_error != null)
          Positioned(
            top: MediaQuery.paddingOf(context).top + 12,
            right: 12,
            child: IconButton(
              tooltip: 'Retry loading movie posts',
              onPressed: _loadMoviePosts,
              icon: const Icon(Icons.refresh, color: Colors.white),
            ),
          ),
      ],
    );
  }
}
