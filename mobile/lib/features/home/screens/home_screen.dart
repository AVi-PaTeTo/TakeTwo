import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mobile/shared/widgets/post_card.dart';
import 'package:mobile/shared/providers/feed_providers.dart';
import 'package:mobile/shared/providers/post_cache_provider.dart';
import 'package:mobile/shared/widgets/app_error_view.dart';
import 'package:mobile/shared/widgets/follow_suggestion.dart';

import '../widgets/comments_bottom_sheet.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(homeFeedIdsProvider);

    return Scaffold(
      appBar: AppBar(toolbarHeight: 50, title: const Text('Take Two')),
      body: RefreshIndicator(
        onRefresh: () async {
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
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [UserSuggestions()],
              );
            }

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(6),
              itemCount: postIds.length,
              itemBuilder: (context, index) {
                // Load the next page when we're close to the end.
                if (index >= postIds.length - 2) {
                  ref.read(homeFeedIdsProvider.notifier).loadMore();
                }

                final postId = postIds[index];

                // Read the live post from normalized state.
                final post = ref.watch(postProvider(postId));

                if (post == null) {
                  return const SizedBox.shrink();
                }

                return PostCard(
                  post: post,
                  onTap: () {
                    context.push(
                      '/posts/${post.id}',
                      extra: post.toPostDetailData(),
                    );
                  },
                  onLikePressed: () {
                    ref.read(homeFeedIdsProvider.notifier).toggleLike(postId);
                  },
                  onCommentPressed: () {
                    showModalBottomSheet(
                      context: context,
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
