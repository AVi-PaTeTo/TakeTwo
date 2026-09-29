import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/shared/widgets/post_card.dart';

import 'package:mobile/shared/providers/feed_providers.dart';
import 'package:mobile/shared/providers/post_cache_provider.dart';

import '../widgets/comments_bottom_sheet.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    // 1. Watch the feed IDs instead of a list of full Post objects
    final feedAsync = ref.watch(homeFeedIdsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Take Two')),
      body: feedAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            Center(child: Text('Failed to load posts: $error')),
        data: (postIds) {
          if (postIds.isEmpty) {
            return const Center(child: Text('No posts yet.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: postIds.length,
            itemBuilder: (context, index) {
              final postId = postIds[index];

              // 2. Fetch the individual post from the normalized cache by ID
              // (Alternatively, you can pass just `postId` to PostCard if you refactor it)
              final post = ref.watch(postProvider(postId));

              if (post == null) return const SizedBox.shrink();

              return PostCard(
                post: post, // PostCard still takes a Post object if it expects one
                onTap: () {
                  context.push(
                    '/posts/${post.id}',
                    extra: post.toPostDetailData(),
                  );
                },
                onLikePressed: () {
                  // 3. Call toggleLike on the normalized feed notifier
                  ref.read(homeFeedIdsProvider.notifier).toggleLike(postId);
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
