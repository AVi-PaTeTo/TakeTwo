import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mobile/core/router/navigation_helpers.dart';

import 'package:mobile/core/util/time_ago.dart';
import 'package:mobile/shared/models/post_detail_data.dart';
import 'package:mobile/features/home/widgets/comments_bottom_sheet.dart';
import 'package:mobile/shared/providers/feed_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PostDetailScreen extends ConsumerStatefulWidget {
  final PostDetailData post;

  const PostDetailScreen({super.key, required this.post});

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  bool _isExpanded = false;

  // Local state variables to track likes dynamically on this screen
  late bool _isLiked;
  late int _likeCount;

  @override
  void initState() {
    super.initState();
    // Initialize local states from the passed widget post data
    _isLiked = widget.post.isLiked;
    _likeCount = widget.post.likeCount;
  }

  // TMDB Genre ID lookup map
  final Map<int, String> _genreNames = {
    28: 'Action',
    12: 'Adventure',
    16: 'Animation',
    35: 'Comedy',
    80: 'Crime',
    99: 'Documentary',
    18: 'Drama',
    10751: 'Family',
    14: 'Fantasy',
    36: 'History',
    27: 'Horror',
    10402: 'Music',
    9648: 'Mystery',
    10749: 'Romance',
    878: 'Sci-Fi',
    10770: 'TV Movie',
    53: 'Thriller',
    10752: 'War',
    37: 'Western',
  };

  @override
  Widget build(BuildContext context) {
    final overview = widget.post.movieOverview;
    final hasOverview = overview != null && overview.isNotEmpty;

    final genres = widget.post.genreIds
        .map((id) => _genreNames[id])
        .whereType<String>()
        .join(' · ');

    String? releaseYear;

    if (widget.post.releaseDate != null &&
        widget.post.releaseDate!.isNotEmpty) {
      releaseYear = widget.post.releaseDate!.substring(0, 4);
    }

    final metadataString = [
      if (releaseYear != null) releaseYear,
      if (genres.isNotEmpty) genres,
    ].join(' · ');

    debugPrint('BANNER URL: ${widget.post.bannerUrl}');
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -------------------------
            // BANNER
            // -------------------------
            if (widget.post.bannerUrl != null &&
                widget.post.bannerUrl!.isNotEmpty)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: CachedNetworkImage(
                  imageUrl: widget.post.bannerUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      const ColoredBox(color: Colors.black12),
                  errorWidget: (context, url, error) =>
                      const ColoredBox(color: Colors.black26),
                ),
              )
            else
              AspectRatio(
                aspectRatio: 16 / 9,
                child: ColoredBox(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
              ),

            // -------------------------
            // POST CONTENT
            // -------------------------
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // -------------------------
                  // USER + MOVIE INFO
                  // -------------------------
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () =>
                            openUserProfile(context, ref, widget.post.userId),
                        child: Container(
                          width: 80,
                          height: 80,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(100),
                              bottomLeft: Radius.circular(100),
                              bottomRight: Radius.circular(100),
                            ),
                          ),
                          child:
                              (widget.post.profilePictureUrl != null &&
                                  widget.post.profilePictureUrl!.isNotEmpty)
                              ? CachedNetworkImage(
                                  fit: BoxFit.cover,
                                  imageUrl: widget.post.profilePictureUrl!,
                                  placeholder: (context, url) =>
                                      const ColoredBox(
                                        color: Colors.black12,
                                        child: Center(
                                          child: SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        ),
                                      ),
                                  errorWidget: (context, url, error) =>
                                      ColoredBox(
                                        color: Colors.grey.shade300,
                                        child: Center(
                                          child: Text(
                                            widget.post.username.isNotEmpty
                                                ? widget.post.username[0]
                                                      .toUpperCase()
                                                : '?',
                                            style: const TextStyle(
                                              fontSize: 56,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ),
                                      ),
                                )
                              : ColoredBox(
                                  color: Colors.grey.shade300,
                                  child: Center(
                                    child: Text(
                                      widget.post.username.isNotEmpty
                                          ? widget.post.username[0]
                                                .toUpperCase()
                                          : '?',
                                      style: const TextStyle(
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () => openUserProfile(
                                context,
                                ref,
                                widget.post.userId,
                              ),
                              child: Text(
                                '@${widget.post.username}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.post.movieTitle,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (metadataString.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                metadataString,
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // -------------------------
                  // ABOUT MOVIE
                  // -------------------------
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: hasOverview
                          ? () {
                              setState(() {
                                _isExpanded = !_isExpanded;
                              });
                            }
                          : null,
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              size: 16,
                              color: Colors.white70,
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'About movie / tv show',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                            if (hasOverview) ...[
                              const SizedBox(width: 4),
                              Icon(
                                _isExpanded
                                    ? Icons.keyboard_arrow_up_rounded
                                    : Icons.keyboard_arrow_down_rounded,
                                size: 16,
                                color: Colors.white70,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),

                  // -------------------------
                  // MOVIE OVERVIEW
                  // -------------------------
                  if (_isExpanded && hasOverview) ...[
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        overview,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 10),

                  // -------------------------
                  // POST TITLE
                  // -------------------------
                  if (widget.post.createdAt != null &&
                      widget.post.createdAt!.isNotEmpty)
                    Text(
                      'Posted: ${TimeAgo.format(widget.post.createdAt!)}',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  const SizedBox(height: 10),
                  Text(
                    widget.post.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // -------------------------
                  // POST CONTENT
                  // -------------------------
                  Text(
                    widget.post.content,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),

                  const SizedBox(height: 24),

                  // -------------------------
                  // POST ACTIONS
                  // -------------------------
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildActionPill(
                        icon: _isLiked ? Icons.favorite : Icons.favorite_border,
                        label: _likeCount > 0 ? '$_likeCount' : '',
                        isLiked: _isLiked,
                        onTap: () {
                          setState(() {
                            _isLiked = !_isLiked;
                            _likeCount += _isLiked ? 1 : -1;
                          });

                          // Call provider to handle backend / global state update
                          ref
                              .read(homeFeedIdsProvider.notifier)
                              .toggleLike(widget.post.id);
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildActionPill(
                        icon: Icons.chat_bubble_outline,
                        label: widget.post.commentCount > 0
                            ? '${widget.post.commentCount}'
                            : '',
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            useSafeArea: true,
                            isScrollControlled: true,
                            builder: (_) {
                              return CommentsBottomSheet(
                                postId: widget.post.id,
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------
  // POST ACTION WIDGET HELPER
  // ------------------------------------
  Widget _buildActionPill({
    required IconData icon,
    required String label,
    bool isLiked = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.fromLTRB(0, 6, 12, 0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 28,
              color: isLiked ? Colors.redAccent : Colors.white,
            ),

            if (label.isNotEmpty) const SizedBox(width: 4),

            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
