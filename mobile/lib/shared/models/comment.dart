import 'user_summary.dart';

class Comment {
  final int id;
  final UserSummary user;
  final UserSummary? replyTo;
  final String content;
  final int likeCount;
  final List<Comment> replies;
  final bool isLiked;

  const Comment({
    required this.id,
    required this.user,
    required this.replyTo,
    required this.content,
    required this.likeCount,
    required this.replies,
    required this.isLiked,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      user: UserSummary.fromJson(json['user']),
      replyTo: json['reply_to'] != null
          ? UserSummary.fromJson(json['reply_to'])
          : null,
      content: json['content'],
      likeCount: json['like_count'],
      isLiked: json['is_liked'] ?? false,
      replies: (json['replies'] as List<dynamic>? ?? [])
          .map((json) => Comment.fromJson(json))
          .toList(),
    );
  }

  Comment copyWith({int? likeCount, bool? isLiked, List<Comment>? replies}) {
    return Comment(
      id: id,
      user: user,
      replyTo: replyTo,
      content: content,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
      replies: replies ?? this.replies,
    );
  }
}
