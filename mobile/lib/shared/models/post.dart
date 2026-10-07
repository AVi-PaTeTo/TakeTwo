import 'post_detail_data.dart';
import 'movie.dart';
import 'user_summary.dart';

class Post {
  final int id;
  final UserSummary user;
  final Movie movie;
  final String title;
  final String content;
  final String? customPosterUrl;
  final String? bannerUrl;
  final int likeCount;
  final int commentCount;
  final bool isLiked;
  final String? createdAt;
  final String? updatedAt;

  const Post({
    required this.id,
    required this.user,
    required this.movie,
    required this.title,
    required this.content,
    this.customPosterUrl,
    this.bannerUrl,
    required this.likeCount,
    required this.commentCount,
    required this.isLiked,
    this.createdAt,
    this.updatedAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      user: UserSummary.fromJson(json['user']),
      movie: Movie.fromJson(json['movie']),
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      customPosterUrl: json['custom_poster_url'],
      bannerUrl: json['banner_url'],
      likeCount: json['like_count'] ?? 0,
      commentCount: json['comment_count'] ?? 0,
      isLiked: json['is_liked'] ?? false,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Post copyWith({
    int? likeCount,
    bool? isLiked,
    String? title,
    String? content,
    int? commentCount,
  }) {
    return Post(
      id: id,
      user: user,
      movie: movie,
      title: title ?? this.title,
      content: content ?? this.content,
      customPosterUrl: customPosterUrl,
      bannerUrl: bannerUrl,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      isLiked: isLiked ?? this.isLiked,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  PostDetailData toPostDetailData() {
    return PostDetailData(
      id: id,
      userId: user.id,
      username: user.username,
      profilePictureUrl: user.profilePictureUrl,
      createdAt: createdAt,
      title: title,
      content: content,
      movieTitle: movie.title,
      movieOverview: movie.overview,
      releaseDate: movie.releaseDate,
      genreIds: movie.genreIds,
      posterPath: movie.posterPath,
      customPosterUrl: customPosterUrl ?? '',
      bannerUrl: bannerUrl ?? '',
      likeCount: likeCount,
      commentCount: commentCount,
      isLiked: isLiked,
    );
  }
}
