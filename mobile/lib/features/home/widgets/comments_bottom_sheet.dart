import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/shared/models/comment.dart';

// Use the shared post service provider
import 'package:mobile/shared/models/user_summary.dart';
import 'package:mobile/core/router/navigation_helpers.dart';
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
    final keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.65,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Comments',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Flexible(child: _buildComments()),
            _buildCommentInput(),
            if (keyboardHeight == 0)
              const SafeArea(top: false, child: SizedBox.shrink()),
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
          leading: GestureDetector(
            onTap: () {
              openUserProfile(context, ref, comment.user.id);
            },
            child: _buildUserAvatar(comment.user),
          ),
          title: GestureDetector(
            onTap: () {
              openUserProfile(context, ref, comment.user.id);
            },
            child: Text(
              '@${comment.user.username}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          subtitle: Text(comment.content),
          trailing: _buildLikeButton(comment),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 72),
          child: TextButton(
            style: TextButton.styleFrom(
              minimumSize: Size.zero,
              padding: EdgeInsets.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
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
            child: Column(children: comment.replies.map(_buildReply).toList()),
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
          leading: GestureDetector(
            onTap: () {
              openUserProfile(context, ref, reply.user.id);
            },
            child: _buildUserAvatar(reply.user),
          ),
          title: GestureDetector(
            onTap: () {
              openUserProfile(context, ref, reply.user.id);
            },
            child: Text(
              '@${reply.user.username}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          subtitle: Text(
            reply.replyTo != null
                ? '@${reply.replyTo!.username} ${reply.content}'
                : reply.content,
          ),
          trailing: _buildLikeButton(reply),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 60),
          child: TextButton(
            style: TextButton.styleFrom(
              minimumSize: Size.zero,
              padding: EdgeInsets.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
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

  Widget _buildUserAvatar(UserSummary user) {
    final hasProfilePicture =
        user.profilePictureUrl != null && user.profilePictureUrl!.isNotEmpty;

    return CircleAvatar(
      radius: 18,
      backgroundColor:
          Colors.primaries[user.username.hashCode % Colors.primaries.length],
      backgroundImage: hasProfilePicture
          ? NetworkImage(user.profilePictureUrl!)
          : null,
      child: hasProfilePicture
          ? null
          : Text(
              user.username.isNotEmpty ? user.username[0].toUpperCase() : 'U',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
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
          Container(
            padding: const EdgeInsets.fromLTRB(18, 2, 6, 2),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: _replyingTo == null
                          ? 'Write a comment...'
                          : 'Write a reply...',
                      hintStyle: const TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.send_rounded, size: 20),
                  color: Colors.red,
                  onPressed: _submitComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleCommentLike(Comment comment) async {
    final service = ref.read(postServiceProvider);

    final wasLiked = comment.isLiked;
    final newLikedState = !wasLiked;
    final newLikeCount = comment.likeCount + (newLikedState ? 1 : -1);

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
        if (comment.id == commentId) {
          return updatedComment;
        }

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

      final currentPost = ref.read(postProvider(widget.postId));
      if (currentPost != null) {
        ref
            .read(postCacheProvider.notifier)
            .updatePost(
              currentPost.copyWith(commentCount: currentPost.commentCount + 1),
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
