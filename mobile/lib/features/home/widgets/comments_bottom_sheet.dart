import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/shared/models/comment.dart';

// Use the shared post service provider
import 'package:mobile/shared/providers/post_cache_provider.dart';

class CommentsBottomSheet extends ConsumerStatefulWidget {
  final int postId;

  const CommentsBottomSheet({super.key, required this.postId});

  @override
  ConsumerState<CommentsBottomSheet> createState() =>
      _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends ConsumerState<CommentsBottomSheet> {
  final TextEditingController _commentController = TextEditingController();

  Comment? _replyingTo;

  List<Comment> _comments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    try {
      // Changed to shared postServiceProvider
      final service = ref.read(postServiceProvider);
      final comments = await service.getComments(widget.postId);

      if (!mounted) return;

      setState(() {
        _comments = comments;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to load comments: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Comments',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            Expanded(child: _buildComments()),

            _buildCommentInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildComments() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_comments.isEmpty) {
      return const Center(child: Text('No comments yet.'));
    }

    return ListView.builder(
      itemCount: _comments.length,
      itemBuilder: (context, index) {
        return _buildComment(_comments[index]);
      },
    );
  }

  Widget _buildComment(Comment comment) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text(
            '@${comment.user.username}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(comment.content),
          trailing: _buildLikeButton(comment),
        ),

        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: TextButton(
            onPressed: () {
              setState(() {
                _replyingTo = comment;
              });
            },
            child: const Text('Reply'),
          ),
        ),

        if (comment.replies.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: Column(
              children: comment.replies.map((reply) {
                return _buildReply(reply);
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildReply(Comment reply) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          dense: true,
          title: Text(
            '@${reply.user.username}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            reply.replyTo != null
                ? '@${reply.replyTo!.username} ${reply.content}'
                : reply.content,
          ),
          trailing: _buildLikeButton(reply),
        ),

        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: TextButton(
            onPressed: () {
              setState(() {
                _replyingTo = reply;
              });
            },
            child: const Text('Reply'),
          ),
        ),
      ],
    );
  }

  Widget _buildLikeButton(Comment comment) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () => _toggleCommentLike(comment),
          icon: Icon(
            comment.isLiked ? Icons.favorite : Icons.favorite_border,
            color: comment.isLiked ? Colors.red : null,
          ),
        ),
        Text('${comment.likeCount}'),
      ],
    );
  }

  Widget _buildCommentInput() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          if (_replyingTo != null)
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Replying to @${_replyingTo!.user.username}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _replyingTo = null;
                    });
                  },
                  icon: const Icon(Icons.close),
                ),
              ],
            ),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: _replyingTo == null
                        ? 'Write a comment...'
                        : 'Write a reply...',
                  ),
                ),
              ),
              IconButton(
                onPressed: _submitComment,
                icon: const Icon(Icons.send),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _toggleCommentLike(Comment comment) async {
    // Changed to shared postServiceProvider
    final service = ref.read(postServiceProvider);

    final wasLiked = comment.isLiked;
    final newLikedState = !wasLiked;

    final newLikeCount = comment.likeCount + (newLikedState ? 1 : -1);

    // Optimistic update
    _updateComment(
      comment.id,
      comment.copyWith(isLiked: newLikedState, likeCount: newLikeCount),
    );

    try {
      if (newLikedState) {
        await service.likeComment(comment.id);
      } else {
        await service.unlikeComment(comment.id);
      }
    } catch (e) {
      // Roll back if request fails
      _updateComment(
        comment.id,
        comment.copyWith(isLiked: wasLiked, likeCount: comment.likeCount),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to update like: $e')));
    }
  }

  void _updateComment(int commentId, Comment updatedComment) {
    setState(() {
      _comments = _comments.map((comment) {
        // Root comment
        if (comment.id == commentId) {
          return updatedComment;
        }

        // Reply
        if (comment.replies.any((reply) => reply.id == commentId)) {
          return comment.copyWith(
            replies: comment.replies.map((reply) {
              if (reply.id == commentId) {
                return updatedComment;
              }

              return reply;
            }).toList(),
          );
        }

        return comment;
      }).toList();
    });
  }

  Future<void> _submitComment() async {
    final content = _commentController.text.trim();

    if (content.isEmpty) return;

    // Changed to shared postServiceProvider
    final service = ref.read(postServiceProvider);

    try {
      if (_replyingTo == null) {
        await service.addComment(widget.postId, content);
      } else {
        await service.replyToComment(
          _replyingTo!.id,
          content,
          _replyingTo!.user.id,
        );
      }

      _commentController.clear();

      setState(() {
        _replyingTo = null;
      });

      await _loadComments();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to post comment: $e')));
    }
  }
}
