import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/shared/widgets/post_card.dart';

import 'package:mobile/shared/providers/feed_providers.dart';
import 'package:mobile/shared/providers/post_cache_provider.dart';
import 'package:mobile/shared/widgets/app_error_view.dart';

import '../widgets/comments_bottom_sheet.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Watch the feed IDs instead of a list of full Post objects
    final feedAsync = ref.watch(homeFeedIdsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Take Two')),
      body: RefreshIndicator(
        onRefresh: () async {
          // Trigger the pull-to-refresh action on the notifier
          await ref.read(homeFeedIdsProvider.notifier).refresh();
        },
        child: feedAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => AppErrorView(
            error: error,
            onRetry: () => ref.read(homeFeedIdsProvider.notifier).refresh(),
          ),
          data: (postIds) {
            if (postIds.isEmpty) {
              // RefreshIndicator needs a scrollable widget even when empty
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: const Center(child: Text('No posts yet.')),
                  ),
                ],
              );
            }

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: postIds.length,
              itemBuilder: (context, index) {
                // --- INFINITE SCROLL / PAGINATION TRIGGER ---
                // If the user scrolls within 2 items of the end, fetch the next page
                if (index >= postIds.length - 2) {
                  ref.read(homeFeedIdsProvider.notifier).loadMore();
                }

                final postId = postIds[index];

                // 2. Fetch the individual post from the normalized cache by ID
                final post = ref.watch(postProvider(postId));

                if (post == null) return const SizedBox.shrink();

                return PostCard(
                  post: post,
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
      ),
    );
  }
}
