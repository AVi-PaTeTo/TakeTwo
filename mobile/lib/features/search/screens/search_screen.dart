import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mobile/shared/providers/post_cache_provider.dart';

import '../../../shared/models/post.dart';
import '../models/search_user.dart';
import '../providers/search_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _controller;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController();

    _controller.addListener(() {
      setState(() {});
    });

    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    _tabController.dispose();

    super.dispose();
  }

  void _onSearchChanged(String value) {
    ref.read(searchProvider.notifier).search(value);
  }

  void _clearSearch() {
    _controller.clear();

    ref.read(searchProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchProvider);

    return Scaffold(
      // backgroundColor: Colors.black,

      appBar: AppBar(
        // backgroundColor: Colors.black,
        elevation: 0,

        title: TextField(
          controller: _controller,
          autofocus: true,

          onChanged: _onSearchChanged,

          style: const TextStyle(color: Colors.white, fontSize: 16),

          decoration: InputDecoration(
            hintText: 'Search users or posts',
            hintStyle: const TextStyle(color: Colors.white38),

            prefixIcon: const Icon(Icons.search, color: Colors.white54),

            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    onPressed: _clearSearch,
                    icon: const Icon(Icons.clear, color: Colors.white54),
                  )
                : null,

            filled: true,
            fillColor: Colors.white10,

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),

      body: Column(
        children: [
          // ------------------------------------------------
          // TABS
          // ------------------------------------------------

          TabBar(
            controller: _tabController,

            indicatorColor: Colors.white,

            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,

            tabs: [
              Tab(
                text: state.userCount > 0
                    ? 'Users (${state.userCount})'
                    : 'Users',
              ),
              Tab(
                text: state.postCount > 0
                    ? 'Posts (${state.postCount})'
                    : 'Posts',
              ),
            ],
          ),

          // ------------------------------------------------
          // CONTENT
          // ------------------------------------------------
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.error != null
                ? _buildError(state.error!)
                : TabBarView(
                    controller: _tabController,
                    children: [_buildUsersTab(state), _buildPostsTab(state)],
                  ),
          ),
        ],
      ),
    );
  }

  // ======================================================
  // USERS
  // ======================================================

  Widget _buildUsersTab(SearchState state) {
    if (state.query.isEmpty) {
      return _buildEmpty(
        icon: Icons.people_outline,
        message: 'Search for users',
      );
    }

    if (state.users.isEmpty) {
      return _buildEmpty(icon: Icons.person_search, message: 'No users found');
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.pixels >=
            notification.metrics.maxScrollExtent - 300) {
          ref.read(searchProvider.notifier).loadMoreUsers();
        }

        return false;
      },

      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 24),

        itemCount: state.users.length + (state.isLoadingMoreUsers ? 1 : 0),

        itemBuilder: (context, index) {
          // Loading indicator
          if (index >= state.users.length) {
            return const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final user = state.users[index];

          return _buildUserTile(user);
        },
      ),
    );
  }

  Widget _buildUserTile(SearchUser user) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),

      leading: CircleAvatar(
        radius: 24,

        backgroundColor: Colors.white12,

        backgroundImage:
            user.profilePictureUrl != null && user.profilePictureUrl!.isNotEmpty
            ? NetworkImage(user.profilePictureUrl!)
            : null,

        child: user.profilePictureUrl == null || user.profilePictureUrl!.isEmpty
            ? const Icon(Icons.person, color: Colors.white54)
            : null,
      ),

      title: Text(
        user.username,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),

      onTap: () {
        context.push('/users/${user.id}');
      },
    );
  }

  // ======================================================
  // POSTS
  // ======================================================

  Widget _buildPostsTab(SearchState state) {
    if (state.query.isEmpty) {
      return _buildEmpty(
        icon: Icons.article_outlined,
        message: 'Search for posts',
      );
    }

    if (state.posts.isEmpty) {
      return _buildEmpty(icon: Icons.search_off, message: 'No posts found');
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.pixels >=
            notification.metrics.maxScrollExtent - 400) {
          ref.read(searchProvider.notifier).loadMorePosts();
        }

        return false;
      },

      child: ListView.builder(
        padding: const EdgeInsets.only(top: 12, bottom: 24),

        itemCount: state.posts.length + (state.isLoadingMorePosts ? 1 : 0),

        itemBuilder: (context, index) {
          if (index >= state.posts.length) {
            return const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final rawPost = state.posts[index];

          // Always read the live normalized version.
          final post = ref.watch(postProvider(rawPost.id)) ?? rawPost;

          return _buildPostCard(post);
        },
      ),
    );
  }

  Widget _buildPostCard(Post post) {
    return GestureDetector(
      onTap: () {
        context.push('/posts/${post.id}', extra: post.toPostDetailData());
      },
      child: Container(
        height: 220,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFF151515),
        ),
        child: Stack(
          children: [
            // -----------------------------------------------
            // BANNER
            // -----------------------------------------------

            Positioned.fill(
              child: post.bannerUrl != null && post.bannerUrl!.isNotEmpty
                  ? Image.network(post.bannerUrl!, fit: BoxFit.cover)
                  : const SizedBox.shrink(),
            ),

            // -----------------------------------------------
            // DARK GRADIENT
            // -----------------------------------------------
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.45, 1.0],
                    colors: [
                      Colors.black.withValues(alpha: 0.15),
                      Colors.black.withValues(alpha: 0.45),
                      const Color.fromARGB(124, 255, 17, 0),
                    ],
                  ),
                ),
              ),
            ),

            // -----------------------------------------------
            // CONTENT
            // -----------------------------------------------
            Positioned(
              left: 16,
              right: 16,
              bottom: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.white12,
                        backgroundImage:
                            post.user.profilePictureUrl != null &&
                                post.user.profilePictureUrl!.isNotEmpty
                            ? NetworkImage(post.user.profilePictureUrl!)
                            : null,
                        child:
                            post.user.profilePictureUrl == null ||
                                post.user.profilePictureUrl!.isEmpty
                            ? const Icon(
                                Icons.person,
                                size: 16,
                                color: Colors.white54,
                              )
                            : null,
                      ),

                      const SizedBox(width: 8),

                      Text(
                        '@${post.user.username}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Post title
                  Text(
                    post.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 3),

                  // Movie
                  Text(
                    post.movie.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white60, fontSize: 13),
                  ),

                  const SizedBox(height: 10),

                  // Engagement
                  Row(
                    children: [
                      Icon(
                        post.isLiked ? Icons.favorite : Icons.favorite_border,
                        size: 17,
                        color: Colors.white70,
                      ),

                      const SizedBox(width: 4),

                      Text(
                        '${post.likeCount}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),

                      const SizedBox(width: 14),

                      const Icon(
                        Icons.chat_bubble_outline,
                        size: 16,
                        color: Colors.white70,
                      ),

                      const SizedBox(width: 4),

                      Text(
                        '${post.commentCount}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
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
    );
  }

  // ======================================================
  // EMPTY
  // ======================================================

  Widget _buildEmpty({required IconData icon, required String message}) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: Colors.white24),

          const SizedBox(height: 12),

          Text(
            message,
            style: const TextStyle(color: Colors.white54, fontSize: 15),
          ),
        ],
      ),
    );
  }

  // ======================================================
  // ERROR
  // ======================================================

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.white38),

            const SizedBox(height: 12),

            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54),
            ),

            const SizedBox(height: 16),

            TextButton(
              onPressed: () {
                if (_controller.text.trim().isNotEmpty) {
                  ref.read(searchProvider.notifier).search(_controller.text);
                }
              },
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
