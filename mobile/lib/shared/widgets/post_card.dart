import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/router/navigation_helpers.dart';

import 'package:flutter/material.dart';

class PostCard extends ConsumerWidget {
  final dynamic post;
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
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Username
              GestureDetector(
                onTap: () {
                  openUserProfile(context, ref, post.user.id);
                },
                child: Text(
                  '@${post.user.username}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 8),

              // Post Title
              Text(
                post.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              // Movie Title
              Text(
                post.movie.title,
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),

              const SizedBox(height: 12),

              // Content (with optional text clipping for search/profile lists)
              Text(post.content, maxLines: 3, overflow: TextOverflow.ellipsis),

              const SizedBox(height: 16),

              // Actions Row (Likes & Comments)
              Row(
                children: [
                  IconButton(
                    onPressed: onLikePressed,
                    icon: Icon(
                      post.isLiked ? Icons.favorite : Icons.favorite_border,
                      color: post.isLiked ? Colors.red : null,
                    ),
                  ),
                  Text('${post.likeCount}'),

                  const SizedBox(width: 12),

                  IconButton(
                    onPressed: onCommentPressed,
                    icon: const Icon(Icons.comment_outlined),
                  ),
                  Text('${post.commentCount}'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
