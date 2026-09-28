import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/features/search/models/search_post.dart';

import '../models/tmdb_search_result.dart';
import '../providers/create_provider.dart';
import '../widgets/create_post_form.dart';
import '../widgets/media_type_toggle.dart';
import '../widgets/movie_search_result_tile.dart';
import '../widgets/movie_search_bar.dart';
import '../widgets/selected_movie_header.dart';

class CreateScreen extends ConsumerStatefulWidget {
  const CreateScreen({super.key});

  @override
  ConsumerState<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends ConsumerState<CreateScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  bool get _hasChanges {
    return _titleController.text.trim().isNotEmpty ||
        _contentController.text.trim().isNotEmpty ||
        ref.read(createProvider).selectedMovie != null;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<bool> _confirmExit() async {
    if (!_hasChanges) return true;

    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Leave create post?'),
          content: const Text(
            'Any changes made haven’t been saved. Are you sure you want to exit?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Keep editing'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Exit'),
            ),
          ],
        );
      },
    );

    return shouldExit ?? false;
  }

  Future<void> _handleBack() async {
    final canExit = await _confirmExit();

    if (!mounted || !canExit) return;

    ref.read(createProvider.notifier).reset();
    Navigator.of(context).pop();
  }

  Future<void> _createPost() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title and review.')),
      );
      return;
    }

    try {
      final postJson = await ref
          .read(createProvider.notifier)
          .createPost(title: title, content: content);

      if (!mounted) return;

      final post = SearchPost.fromJson(postJson as Map<String, dynamic>);

      ref.read(createProvider.notifier).reset();

      context.pushReplacement(
        '/posts/${post.id}',
        extra: post.toPostDetailData(),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to create your post. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _handleBack();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: _handleBack,
          ),
        ),
        body: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: state.step == CreateStep.search
                ? _SearchView(state: state)
                : _WritingView(
                    state: state,
                    titleController: _titleController,
                    contentController: _contentController,
                    onCreate: _createPost,
                  ),
          ),
        ),
      ),
    );
  }
}

class _SearchView extends ConsumerWidget {
  final CreateState state;

  const _SearchView({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(createProvider.notifier);

    return Column(
      children: [
        const SizedBox(height: 16),

        MediaTypeToggle(
          selectedType: state.mediaType,
          onChanged: notifier.setMediaType,
        ),

        const SizedBox(height: 16),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: MovieSearchBar(
            initialValue: state.query,
            onChanged: notifier.searchChanged,
          ),
        ),

        const SizedBox(height: 12),

        if (state.isSearching)
          const Expanded(child: Center(child: CircularProgressIndicator()))
        else if (state.isLoadingMovie)
          const Expanded(child: Center(child: CircularProgressIndicator()))
        else if (state.error != null)
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(state.error!, textAlign: TextAlign.center),
              ),
            ),
          )
        else if (state.query.trim().isEmpty)
          const Expanded(
            child: Center(child: Text('Search for a movie or TV show')),
          )
        else if (state.results.isEmpty)
          const Expanded(child: Center(child: Text('No results found')))
        else
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: state.results.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final result = state.results[index];

                return MovieSearchResultTile(
                  result: result,
                  onTap: () => notifier.selectMovie(result),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _WritingView extends StatelessWidget {
  final CreateState state;
  final TextEditingController titleController;
  final TextEditingController contentController;
  final VoidCallback onCreate;

  const _WritingView({
    required this.state,
    required this.titleController,
    required this.contentController,
    required this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              if (state.selectedMovie != null)
                SelectedMovieHeader(movie: state.selectedMovie!),

              const SizedBox(height: 24),

              CreatePostForm(
                titleController: titleController,
                contentController: contentController,
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: state.isCreating ? null : onCreate,
              child: state.isCreating
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Create Post'),
            ),
          ),
        ),
      ],
    );
  }
}
