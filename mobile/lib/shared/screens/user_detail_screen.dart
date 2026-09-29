import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/shared/widgets/post_card.dart';
import 'package:flutter/foundation.dart';

// Import normalized providers
import 'package:mobile/shared/providers/post_cache_provider.dart';
import 'package:mobile/shared/providers/feed_providers.dart'; // For global actions like toggleLike if needed

import '../providers/user_detail_provider.dart';

class UserDetailScreen extends ConsumerWidget {
  final int userId;
  final bool isOwnProfile;

  const UserDetailScreen({
    super.key,
    required this.userId,
    this.isOwnProfile = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userDetailProvider(userId));
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),

        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48),
                const SizedBox(height: 12),
                const Text(
                  'Could not load profile.',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('$error', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    ref.invalidate(userDetailProvider(userId));
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),

        data: (user) {
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(userDetailProvider(userId));
              await ref.read(userDetailProvider(userId).future);
            },
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _ProfileHeader(
                    userId: userId,
                    username: user.username,
                    postCount: user.postCount,
                    followerCount: user.followerCount,
                    followingCount: user.followingCount,
                    isFollowing: user.isFollowing,
                  ),
                ),

                if (user.posts.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text(
                        'No posts yet.',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final rawPost = user.posts[index];

                        // --- NORMALIZED LOOKUP ---
                        // Watch the central cache using the post ID so updates sync globally
                        final post =
                            ref.watch(postProvider(rawPost.id)) ?? rawPost;

                        return PostCard(
                          post: post,
                          onTap: () {
                            context.push(
                              '/posts/${post.id}',
                              extra: post.toPostDetailData(),
                            );
                          },
                          onLikePressed: () {
                            // Trigger the global post action notifier to sync likes across Home & Profile
                            ref
                                .read(homeFeedIdsProvider.notifier)
                                .toggleLike(post.id);
                          },
                        );
                      }, childCount: user.posts.length),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final int value;
  final String label;

  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$value',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(label),
      ],
    );
  }
}

class _ProfileHeader extends ConsumerWidget {
  final int userId;
  final String username;
  final int postCount;
  final int followerCount;
  final int followingCount;
  final bool isFollowing;

  const _ProfileHeader({
    required this.userId,
    required this.username,
    required this.postCount,
    required this.followerCount,
    required this.followingCount,
    required this.isFollowing,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          CircleAvatar(
            radius: 42,
            child: Text(
              username.isNotEmpty ? username[0].toUpperCase() : '?',
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            '@$username',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _Stat(value: postCount, label: 'Posts'),
              _Stat(value: followerCount, label: 'Followers'),
              _Stat(value: followingCount, label: 'Following'),
            ],
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                ref.read(userDetailProvider(userId).notifier).toggleFollow();
              },
              child: Text(isFollowing ? 'Unfollow' : 'Follow'),
            ),
          ),
        ],
      ),
    );
  }
}
