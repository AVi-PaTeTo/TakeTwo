import 'movie.dart';
import 'user_summary.dart';

class Post {
  final int id;
  final UserSummary user;
  final Movie movie;
  final String title;
  final String content;
  final String customPosterUrl;
  final int likeCount;
  final int commentCount;
  final bool isLiked;

  const Post({
    required this.id,
    required this.user,
    required this.movie,
    required this.title,
    required this.content,
    required this.customPosterUrl,
    required this.likeCount,
    required this.commentCount,
    required this.isLiked,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      user: UserSummary.fromJson(json['user']),
      movie: Movie.fromJson(json['movie']),
      title: json['title'],
      content: json['content'],
      customPosterUrl: json['custom_poster_url'] ?? '',
      likeCount: json['like_count'],
      commentCount: json['comment_count'],
      isLiked: json['is_liked'],
    );
  }

  Post copyWith({int? likeCount, bool? isLiked}) {
    return Post(
      id: id,
      user: user,
      movie: movie,
      title: title,
      content: content,
      customPosterUrl: customPosterUrl,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}
