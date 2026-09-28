import 'package:flutter/material.dart';
import 'package:mobile/shared/models/post_detail_data.dart';

// import '../../features/home/models/post.dart';
import '../../features/home/widgets/comments_bottom_sheet.dart';

class PostDetailScreen extends StatelessWidget {
  final PostDetailData post;

  const PostDetailScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '@${post.username}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Text(
              post.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            Text(
              post.movieTitle,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              post.content,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Icon(post.isLiked ? Icons.favorite : Icons.favorite_border),

                const SizedBox(width: 6),

                Text('${post.likeCount}'),

                const SizedBox(width: 20),

                IconButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) {
                        return CommentsBottomSheet(postId: post.id);
                      },
                    );
                  },
                  icon: const Icon(Icons.comment_outlined),
                ),

                Text('${post.commentCount}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
