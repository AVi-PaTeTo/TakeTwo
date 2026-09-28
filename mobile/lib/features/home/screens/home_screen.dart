import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/shared/widgets/post_card.dart';

import '../providers/home_provider.dart';
import '../widgets/comments_bottom_sheet.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final postsAsync = ref.watch(homePostsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Take Two')),
      body: postsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            Center(child: Text('Failed to load posts: $error')),
        data: (posts) {
          if (posts.isEmpty) {
            return const Center(child: Text('No posts yet.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];

              return PostCard(
                post: post,
                onTap: () {
                  context.push(
                    '/posts/${post.id}',
                    extra: post.toPostDetailData(),
                  );
                },
                onLikePressed: () {
                  ref.read(homePostsProvider.notifier).toggleLike(post);
                },
                onCommentPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) {
                      return CommentsBottomSheet(postId: post.id);
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
