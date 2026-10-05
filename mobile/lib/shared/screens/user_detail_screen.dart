import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/shared/widgets/post_card.dart';
import 'package:mobile/features/auth/providers/auth_provider.dart';
import 'package:mobile/features/profile/screens/edit_profile_screen.dart';

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
        title: Text(
          userAsync.maybeWhen(
            data: (user) => user.username,
            orElse: () => 'Profile',
          ),
        ),
        actions: [
          // Show logout button only on the user's own profile view
          if (isOwnProfile)
            IconButton(
              color: Colors.white,
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
                  await ref.read(authProvider.notifier).logout();

                  // GoRouter will automatically handle redirecting to /login based on auth state change
                }
              },
            ),
        ],
      ),
      body: userAsync.when(
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
                    profileBannerUrl: user.profileBannerUrl,
                    profilePictureUrl: user.profilePictureUrl,
                    preferredGenres: user.preferredGenres,
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
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$value',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }
}

class _ProfileHeader extends ConsumerWidget {
  final int userId;
  final String username;
  final List<int> preferredGenres;
  final String? profilePictureUrl;
  final String? profileBannerUrl;
  final int postCount;
  final int followerCount;
  final int followingCount;
  final bool isFollowing;
  final bool isOwnProfile;

  const _ProfileHeader({
    required this.userId,
    required this.username,
    required this.profilePictureUrl,
    required this.profileBannerUrl,
    required this.preferredGenres,
    required this.postCount,
    required this.followerCount,
    required this.followingCount,
    required this.isFollowing,
    required this.isOwnProfile,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                // bottomRight: Radius.circular(20),
              ),
            ),
            child: Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child:
                      (profileBannerUrl != null && profileBannerUrl!.isNotEmpty)
                      ? CachedNetworkImage(
                          width: double.infinity,
                          fit: BoxFit.cover,
                          imageUrl: profileBannerUrl!,
                          placeholder: (context, url) => const ColoredBox(
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
                              const ColoredBox(
                                color: Colors.black26,
                                child: Center(
                                  child: Icon(
                                    Icons.broken_image_outlined,
                                    color: Colors.white54,
                                    size: 32,
                                  ),
                                ),
                              ),
                        )
                      : const ColoredBox(
                          color: Colors.black26,
                        ), // Fallback if no banner
                ),
                Positioned(
                  bottom: 0,
                  child: Container(
                    height: 130,
                    width: 130,
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(100),
                        topRight: Radius.circular(100),
                        bottomRight: Radius.circular(100),
                        bottomLeft: Radius.circular(20),
                      ),
                    ),
                    child: Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(100),
                          topRight: Radius.circular(100),
                          bottomRight: Radius.circular(100),
                          bottomLeft: Radius.circular(20),
                        ),
                      ),
                      child:
                          (profilePictureUrl != null &&
                              profilePictureUrl!.isNotEmpty)
                          ? CachedNetworkImage(
                              fit: BoxFit.cover,
                              imageUrl: profilePictureUrl!,
                              placeholder: (context, url) => const ColoredBox(
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
                              errorWidget: (context, url, error) => ColoredBox(
                                color: Colors.grey.shade300,
                                child: Center(
                                  child: Text(
                                    username.isNotEmpty
                                        ? username[0].toUpperCase()
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
                                  username.isNotEmpty
                                      ? username[0].toUpperCase()
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
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(12, 12, 12, 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              // color: const Color.fromARGB(255, 218, 218, 218),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '@$username',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight(700),
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
                        alignment: Alignment.center,
                        child: _Stat(value: postCount, label: 'Posts'),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        alignment: Alignment.center,
                        child: _Stat(value: followerCount, label: 'Followers'),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        alignment: Alignment.center,
                        child: _Stat(value: followingCount, label: 'Following'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: isOwnProfile
                      ? OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => EditProfileScreen(
                                  initialUsername: username,
                                  initialGenres: preferredGenres,
                                  initialAvatarUrl: profilePictureUrl,
                                  initialBannerUrl: profileBannerUrl,
                                  onProfileUpdated: () async {
                                    await ref
                                        .read(
                                          userDetailProvider(userId).notifier,
                                        )
                                        .refresh();
                                  },
                                ),
                              ),
                            );
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
          ),
        ],
      ),
    );
  }
}
