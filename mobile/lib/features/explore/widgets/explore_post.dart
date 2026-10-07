import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/shared/models/post.dart';
import 'package:mobile/shared/providers/post_cache_provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:mobile/shared/providers/feed_providers.dart';
import 'package:mobile/features/home/widgets/comments_bottom_sheet.dart';
import 'package:mobile/core/router/navigation_helpers.dart';
import 'package:mobile/core/util/time_ago.dart';

import '../utils/genre_names.dart';

class ExplorePost extends ConsumerStatefulWidget {
  final Post post;

  const ExplorePost({super.key, required this.post});

  @override
  ConsumerState<ExplorePost> createState() => _ExplorePostState();
}

class _ExplorePostState extends ConsumerState<ExplorePost>
    with SingleTickerProviderStateMixin {
  late final AnimationController _expandController;
  late final Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();

    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    if (_expandController.isCompleted) {
      _expandController.reverse();
    } else {
      _expandController.forward();
    }
  }

  void _openInAppTrailer(String trailerUrl) {
    final videoId = YoutubePlayerController.convertUrlToId(trailerUrl);

    if (videoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not load trailer video')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: _TrailerPlayerView(videoId: videoId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final post = ref.watch(postProvider(widget.post.id)) ?? widget.post;

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          left: 8,
          right: 12,
          bottom: 10,
          child: GestureDetector(
            onTap: _toggleExpanded,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.80,
              ),
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

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ------------------------------------------------------------
          // HEADER
          // ------------------------------------------------------------

          Column(
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
                maxLines: _expandController.isCompleted ? null : 2,
                overflow: _expandController.isCompleted
                    ? TextOverflow.visible
                    : TextOverflow.ellipsis,
              ),

              const SizedBox(height: 8),

              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      openUserProfile(context, ref, post.user.id);
                    },
                    child: Text(
                      '@${post.user.username}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Spacer(),
                  if (post.createdAt != null && post.createdAt!.isNotEmpty)
                    Text(
                      TimeAgo.format(post.createdAt!),
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          // ------------------------------------------------------
          // TRAILER + LIKE + COMMENT
          // ------------------------------------------------------
          Row(
            children: [
              // Watch Trailer
              if (post.movie.trailerUrl.isNotEmpty) ...[
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _openInAppTrailer(post.movie.trailerUrl),
                    icon: const Icon(Icons.play_arrow),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color.fromARGB(193, 211, 47, 47),
                    ),
                    label: const Text('Watch Trailer'),
                  ),
                ),

                const SizedBox(width: 20),
              ],

              // Like
              _ActionButton(
                icon: post.isLiked ? Icons.favorite : Icons.favorite_border,
                label: '${post.likeCount}',
                iconColor: post.isLiked ? Colors.red : Colors.white,
                onPressed: () {
                  ref.read(homeFeedIdsProvider.notifier).toggleLike(post.id);
                },
              ),

              const SizedBox(width: 8),

              // Comments
              _ActionButton(
                icon: Icons.chat_bubble_outline_rounded,
                label: '${post.commentCount}',
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    // isScrollControlled: true,
                    builder: (_) {
                      return CommentsBottomSheet(postId: post.id);
                    },
                  );
                },
              ),
            ],
          ),

          // ------------------------------------------------------------
          // EXPANDED CONTENT
          // ------------------------------------------------------------
          SizeTransition(
            sizeFactor: _expandAnimation,
            axisAlignment: -1.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                // ------------------------------------------------------
                // SCROLLABLE CONTENT
                // ------------------------------------------------------
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.sizeOf(context).height * 0.35,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),

                        const SizedBox(height: 12),

                        if (releaseYear != null)
                          Text(
                            releaseYear,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),

                        if (genres.isNotEmpty)
                          Text(
                            genres,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),

                        const SizedBox(height: 12),

                        Text(
                          post.content,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            height: 1.4,
                          ),
                        ),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ======================================================================
// LIKE / COMMENT BUTTON
// ======================================================================

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 26),

            const SizedBox(height: 2),

            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================================
// IN-APP YOUTUBE PLAYER
// ======================================================================

class _TrailerPlayerView extends StatefulWidget {
  final String videoId;

  const _TrailerPlayerView({required this.videoId});

  @override
  State<_TrailerPlayerView> createState() => _TrailerPlayerViewState();
}

class _TrailerPlayerViewState extends State<_TrailerPlayerView> {
  late final YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();

    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.videoId,
      autoPlay: true,
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(child: YoutubePlayer(controller: _controller)),

        Positioned(
          top: 40,
          right: 20,
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 30),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ],
    );
  }
}
