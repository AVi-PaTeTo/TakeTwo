import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/shared/widgets/post_card.dart';

import '../../../shared/models/post_detail_data.dart';
import '../providers/search_provider.dart';
import '../models/search_result.dart';
import '../models/search_post.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _PostSearchCard extends StatelessWidget {
  final SearchPost post;
  final VoidCallback onTap;

  const _PostSearchCard({required this.post, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final posterPath = post.customPosterUrl?.isNotEmpty == true
        ? post.customPosterUrl
        : post.movie.posterPath != null
        ? 'https://image.tmdb.org/t/p/w500${post.movie.posterPath}'
        : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (posterPath != null)
              Image.network(
                posterPath,
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return _posterPlaceholder();
                },
              )
            else
              _posterPlaceholder(),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    '${post.movie.title} • @${post.user.username}',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    post.content,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      const Icon(Icons.favorite_border, size: 18),
                      const SizedBox(width: 4),
                      Text('${post.likeCount}'),

                      const SizedBox(width: 16),

                      const Icon(Icons.comment_outlined, size: 18),
                      const SizedBox(width: 4),
                      Text('${post.commentCount}'),
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

  Widget _posterPlaceholder() {
    return Container(
      width: double.infinity,
      height: 220,
      color: Colors.grey.shade300,
      child: const Center(child: Icon(Icons.movie_outlined, size: 48)),
    );
  }
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              onChanged: (value) {
                ref.read(searchProvider.notifier).search(value);
              },
              decoration: InputDecoration(
                hintText: 'Search movies & TV shows',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _controller.clear();
                          ref.read(searchProvider.notifier).clear();
                          setState(() {});
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          Expanded(child: _buildResults(searchState)),
        ],
      ),
    );
  }

  Widget _buildResults(SearchState state) {
    if (state.query.isEmpty) {
      return const Center(
        child: Text('Search for movies, shows, users, or posts'),
      );
    }

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(state.error!),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                ref.read(searchProvider.notifier).search(state.query);
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final users = state.results.users;
    final posts = state.results.posts;

    if (users.isEmpty && posts.isEmpty) {
      return const Center(child: Text('No results found'));
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        if (users.isNotEmpty) ...[
          const Text(
            'Users',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          ...users.map(
            (user) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                child: Text(
                  user.username.isNotEmpty
                      ? user.username[0].toUpperCase()
                      : '?',
                ),
              ),
              title: Text(user.username),
              onTap: () {
                context.push('/users/${user.id}');
              },
            ),
          ),

          const SizedBox(height: 24),
        ],

        if (posts.isNotEmpty) ...[
          const Text(
            'Posts',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          ...posts.map(
            (post) => PostCard(
              post: post,
              onTap: () {
                context.push(
                  '/posts/${post.id}',
                  extra: post.toPostDetailData(),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

class _MovieSearchCard extends StatelessWidget {
  final MovieSearchResult movie;
  final VoidCallback onTap;

  const _MovieSearchCard({required this.movie, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final year = (movie.releaseDate != null && movie.releaseDate!.length >= 4)
        ? movie.releaseDate!.substring(0, 4)
        : null;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: movie.posterPath != null
                  ? Image.network(
                      'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return _placeholder();
                      },
                    )
                  : _placeholder(),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            movie.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),

          if (year != null)
            Text(
              year,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: Colors.grey.shade300,
      child: const Center(child: Icon(Icons.movie_outlined)),
    );
  }
}
