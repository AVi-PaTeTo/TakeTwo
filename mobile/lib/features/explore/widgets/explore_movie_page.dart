import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/explore_provider.dart';
import '../../home/models/post.dart';
import 'explore_post.dart';

class ExploreMoviePage extends ConsumerStatefulWidget {
  final Post post;

  const ExploreMoviePage({super.key, required this.post});

  @override
  ConsumerState<ExploreMoviePage> createState() => _ExploreMoviePageState();
}

class _ExploreMoviePageState extends ConsumerState<ExploreMoviePage> {
  List<Post>? _moviePosts;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMoviePosts();
  }

  Future<void> _loadMoviePosts() async {
    try {
      final posts = await ref
          .read(explorePostsProvider.notifier)
          .getMoviePosts(widget.post.movie.id);

      if (!mounted) return;

      setState(() {
        _moviePosts = posts;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Text(
          'Failed to load posts:\n$_error',
          textAlign: TextAlign.center,
        ),
      );
    }

    final posts = _moviePosts ?? [widget.post];

    return PageView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: posts.length,
      itemBuilder: (context, index) {
        return ExplorePost(post: posts[index]);
      },
    );
  }
}
