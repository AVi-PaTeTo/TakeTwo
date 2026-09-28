class PostDetailData {
  final int id;
  final int userId;
  final String username;

  final String title;
  final String content;

  final String movieTitle;
  final String? posterPath;
  final String? customPosterUrl;

  final int likeCount;
  final int commentCount;
  final bool isLiked;

  const PostDetailData({
    required this.id,
    required this.userId,
    required this.username,
    required this.title,
    required this.content,
    required this.movieTitle,
    this.posterPath,
    this.customPosterUrl,
    required this.likeCount,
    required this.commentCount,
    required this.isLiked,
  });
}
