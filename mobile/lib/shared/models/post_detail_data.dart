class PostDetailData {
  final int id;
  final int userId;
  final String username;
  final String? profilePictureUrl;

  final String title;
  final String content;

  final String movieTitle;
  final String? movieOverview;
  final String? posterPath;
  final String? customPosterUrl;
  final String? bannerUrl;
  final List<int> genreIds;
  final String? releaseDate;

  final int likeCount;
  final int commentCount;
  final bool isLiked;

  const PostDetailData({
    required this.id,
    required this.userId,
    required this.username,
    required this.profilePictureUrl,
    required this.title,
    required this.content,
    required this.movieTitle,
    this.movieOverview,
    this.releaseDate,
    required this.genreIds,
    this.posterPath,
    this.customPosterUrl,
    this.bannerUrl,
    required this.likeCount,
    required this.commentCount,
    required this.isLiked,
  });
}
