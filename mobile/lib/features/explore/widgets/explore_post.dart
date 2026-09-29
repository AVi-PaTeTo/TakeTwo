import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mobile/shared/models/post.dart';
// Import the global post provider for normalized live-syncing
import 'package:mobile/shared/providers/post_cache_provider.dart';

import '../../../core/config/tmdb_image.dart';
import '../utils/genre_names.dart';

class ExplorePost extends ConsumerStatefulWidget {
  final Post post;

  const ExplorePost({super.key, required this.post});

  @override
  ConsumerState<ExplorePost> createState() => _ExplorePostState();
}

class _ExplorePostState extends ConsumerState<ExplorePost> {
  bool _isExpanded = false;

  Future<void> _openTrailer() async {
    final url = Uri.tryParse(widget.post.movie.trailerUrl);

    if (url == null) {
      return;
    }

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not open trailer')));
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- NORMALIZED SYNC ---
    // Watch the global cache so likes/comments update instantly across the app
    final post = ref.watch(postProvider(widget.post.id)) ?? widget.post;

    // Handle both custom uploaded posters and standard TMDB movie posters
    final posterPath = post.customPosterUrl?.isNotEmpty == true
        ? post.customPosterUrl!
        : TmdbImage.poster(post.movie.posterPath);

    debugPrint('BUILD IMAGE: $posterPath');
    return Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          key: ValueKey(posterPath),
          imageUrl: posterPath,
          fit: BoxFit.cover,
          placeholder: (context, url) {
            return const Center(child: CircularProgressIndicator());
          },
          errorWidget: (context, url, error) {
            return const Center(
              child: Icon(Icons.broken_image, color: Colors.white, size: 48),
            );
          },
        ),

        // Dark overlay.
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.45, 1.0],
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.9),
                ],
              ),
            ),
          ),
        ),

        Positioned(
          left: 20,
          right: 20,
          bottom: 32,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: _buildInfo(post),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfo(Post post) {
    final genres = post.movie.genreIds
        .map((id) => genreNames[id])
        .whereType<String>()
        .join(' · ');

    String? releaseYear;

    if (post.movie.releaseDate != null && post.movie.releaseDate!.isNotEmpty) {
      releaseYear = post.movie.releaseDate!.substring(0, 4);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          post.movie.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          post.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 8),

        Text(
          '@${post.user.username}',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 14,
          ),
        ),

        const SizedBox(height: 12),

        if (_isExpanded) ...[
          Text(
            post.content,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            'About the movie',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            post.movie.overview,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 14,
              height: 1.4,
            ),
          ),

          if (post.movie.trailerUrl.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: FilledButton.icon(
                onPressed: _openTrailer,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Watch Trailer'),
              ),
            ),

          const SizedBox(height: 12),

          if (releaseYear != null)
            Text(
              releaseYear,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),

          if (genres.isNotEmpty)
            Text(
              genres,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),

          const SizedBox(height: 16),
        ],

        Row(
          children: [
            const Icon(Icons.favorite_border, color: Colors.white, size: 22),
            const SizedBox(width: 6),
            Text(
              '${post.likeCount}',
              style: const TextStyle(color: Colors.white),
            ),

            const SizedBox(width: 20),

            const Icon(Icons.comment_outlined, color: Colors.white, size: 22),
            const SizedBox(width: 6),
            Text(
              '${post.commentCount}',
              style: const TextStyle(color: Colors.white),
            ),

            const Spacer(),

            Icon(
              _isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
              color: Colors.white,
            ),
          ],
        ),
      ],
    );
  }
}
