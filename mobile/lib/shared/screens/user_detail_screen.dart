import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/shared/widgets/post_card.dart';
import 'package:mobile/features/auth/providers/auth_provider.dart';

// Import normalized providers
import 'package:mobile/shared/providers/post_cache_provider.dart';
import 'package:mobile/shared/providers/feed_providers.dart'; // For global actions like toggleLike if needed

import '../providers/user_detail_provider.dart';
import '../widgets/app_error_view.dart';

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
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          // Show logout button only on the user's own profile view
          if (isOwnProfile)
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: () async {
                // Optional confirmation dialog
                final shouldLogout = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to log out?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(
                          'Logout',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );

                if (shouldLogout == true) {
                  // Call logout on your auth notifier
                  // (Ensure this matches your actual auth provider method name, e.g., signOut or logout)
                  await ref.read(authProvider.notifier).logout();

                  // GoRouter will automatically handle redirecting to /login based on auth state change
                }
              },
            ),
        ],
      ),
      body: userAsync.when(
        // ... rest of your code remains the same
        loading: () => const Center(child: CircularProgressIndicator()),

        error: (error, stackTrace) => AppErrorView(
          error: error,
          onRetry: () =>
              ref.read(userDetailProvider(userId).notifier).refresh(),
        ),

        data: (user) {
          return RefreshIndicator(
            onRefresh: () async {
              // Call the explicit refresh method on our notifier
              await ref.read(userDetailProvider(userId).notifier).refresh();
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _ProfileHeader(
                    userId: userId,
                    username: user.username,
                    postCount: user.postCount,
                    followerCount: user.followerCount,
                    followingCount: user.followingCount,
                    isFollowing: user.isFollowing,
                    isOwnProfile: isOwnProfile,
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
                        // --- INFINITE SCROLL / PAGINATION TRIGGER ---
                        // If we are within 2 items of the end, trigger loadMore
                        if (index >= user.posts.length - 2) {
                          ref
                              .read(userDetailProvider(userId).notifier)
                              .loadMore();
                        }

                        final rawPost = user.posts[index];

                        // --- NORMALIZED LOOKUP ---
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
  final bool isOwnProfile;

  const _ProfileHeader({
    required this.userId,
    required this.username,
    required this.postCount,
    required this.followerCount,
    required this.followingCount,
    required this.isFollowing,
    required this.isOwnProfile,
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
            username,
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
            child: isOwnProfile
                ? OutlinedButton(
                    onPressed: () {
                      // Navigate to your edit profile route
                      // context.push('');
                    },
                    child: const Text('Edit Profile'),
                  )
                : OutlinedButton(
                    onPressed: () {
                      ref
                          .read(userDetailProvider(userId).notifier)
                          .toggleFollow();
                    },
                    child: Text(isFollowing ? 'Unfollow' : 'Follow'),
                  ),
          ),
        ],
      ),
    );
  }
}
