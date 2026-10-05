import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/widget_previews.dart';

import 'package:mobile/core/router/navigation_helpers.dart';
import 'package:mobile/core/util/time_ago.dart';
import 'package:mobile/shared/models/post.dart';

class PostCard extends ConsumerWidget {
  final Post post;
  final VoidCallback onTap;
  final VoidCallback? onLikePressed;
  final VoidCallback? onCommentPressed;

  const PostCard({
    super.key,
    required this.post,
    required this.onTap,
    this.onLikePressed,
    this.onCommentPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 9),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ============================================================
          // MAIN CARD
          // ============================================================

          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: const Color(0xFF212530),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ==================================================
                    // BANNER
                    // ==================================================

                    AspectRatio(aspectRatio: 16 / 9, child: _buildBanner()),

                    // ==================================================
                    // CONTENT
                    // ==================================================
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(12, 13, 12, 5),
                      decoration: const BoxDecoration(color: Color(0xFFF0F0F0)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ------------------------------------------------
                          // POST TITLE
                          // ------------------------------------------------

                          Text(
                            post.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF111111),
                              fontSize: 20,
                              height: 1.2,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                          ),

                          const SizedBox(height: 5),

                          // ------------------------------------------------
                          // POST CONTENT
                          // ------------------------------------------------
                          Text(
                            post.content,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),

                          const SizedBox(height: 9),

                          // ------------------------------------------------
                          // ACTIONS + TIME
                          // ------------------------------------------------
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _buildActionPill(
                                icon: post.isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                label: post.likeCount > 0
                                    ? '${post.likeCount}'
                                    : '',
                                isLiked: post.isLiked,
                                onTap: onLikePressed,
                                semanticLabel: post.isLiked
                                    ? 'Unlike post'
                                    : 'Like post',
                              ),

                              _buildActionPill(
                                icon: Icons.chat_bubble_outline,
                                label: post.commentCount > 0
                                    ? '${post.commentCount}'
                                    : '',
                                onTap: onCommentPressed,
                                semanticLabel: 'Comments',
                              ),

                              const Spacer(),

                              if (post.createdAt != null &&
                                  post.createdAt!.isNotEmpty)
                                Text(
                                  TimeAgo.format(post.createdAt!),
                                  style: const TextStyle(
                                    color: Colors.black38,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ============================================================
          // USER / MOVIE HEADER
          // ============================================================
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ------------------------------------------------------
                  // AVATAR
                  // ------------------------------------------------------

                  GestureDetector(
                    onTap: () => openUserProfile(context, ref, post.user.id),
                    child: Container(
                      width: 60,
                      height: 60,
                      clipBehavior: Clip.antiAlias,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(100),
                          bottomLeft: Radius.circular(100),
                          bottomRight: Radius.circular(100),
                        ),
                      ),
                      child: _buildAvatar(),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // ------------------------------------------------------
                  // USERNAME + MOVIE
                  // ------------------------------------------------------
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () =>
                                openUserProfile(context, ref, post.user.id),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                '@${post.user.username}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black54,
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 5),

                          // Movie badge
                          Container(
                            constraints: const BoxConstraints(maxWidth: 190),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD32F2F),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              post.movie.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // BANNER
  // ================================================================

  Widget _buildBanner() {
    final bannerUrl = post.bannerUrl;

    if (bannerUrl == null || bannerUrl.isEmpty) {
      return const ColoredBox(
        color: Color.fromARGB(255, 29, 0, 0),
        child: Center(
          child: Icon(Icons.movie_outlined, color: Colors.white38, size: 42),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: bannerUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) {
        return const ColoredBox(
          color: Colors.black,
          child: Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white38,
              ),
            ),
          ),
        );
      },
      errorWidget: (context, url, error) {
        return const ColoredBox(
          color: Colors.black,
          child: Center(
            child: Icon(
              Icons.broken_image_outlined,
              color: Colors.white38,
              size: 42,
            ),
          ),
        );
      },
    );
  }

  // ================================================================
  // AVATAR
  // ================================================================

  Widget _buildAvatar() {
    final profileUrl = post.user.profilePictureUrl;

    if (profileUrl == null || profileUrl.isEmpty) {
      return _buildAvatarFallback();
    }

    return CachedNetworkImage(
      imageUrl: profileUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) {
        return const ColoredBox(
          color: Colors.black12,
          child: Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      },
      errorWidget: (context, url, error) {
        return _buildAvatarFallback();
      },
    );
  }

  Widget _buildAvatarFallback() {
    final username = post.user.username;

    return ColoredBox(
      color: Colors.grey.shade300,
      child: Center(
        child: Text(
          username.isNotEmpty ? username[0].toUpperCase() : '?',
          style: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
      ),
    );
  }

  // ================================================================
  // ACTION
  // ================================================================

  Widget _buildActionPill({
    required IconData icon,
    required String label,
    required String semanticLabel,
    bool isLiked = false,
    VoidCallback? onTap,
  }) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: SizedBox(
            height: 40,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 27,
                  color: isLiked ? Colors.redAccent : Colors.black87,
                ),

                if (label.isNotEmpty) ...[
                  const SizedBox(width: 3),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
