import 'package:mobile/shared/models/post_detail_data.dart';

class SearchPost {
  final int id;
  final SearchPostUser user;
  final SearchMovie movie;
  final String title;
  final String content;
  final String? customPosterUrl;
  final int likeCount;
  final int commentCount;
  final bool isLiked;
  final String createdAt;
  final String updatedAt;

  const SearchPost({
    required this.id,
    required this.user,
    required this.movie,
    required this.title,
    required this.content,
    this.customPosterUrl,
    required this.likeCount,
    required this.commentCount,
    required this.isLiked,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SearchPost.fromJson(Map<String, dynamic> json) {
    return SearchPost(
      id: json['id'],
      user: SearchPostUser.fromJson(json['user']),
      movie: SearchMovie.fromJson(json['movie']),
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      customPosterUrl: json['custom_poster_url'],
      likeCount: json['like_count'] ?? 0,
      commentCount: json['comment_count'] ?? 0,
      isLiked: json['is_liked'] ?? false,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  PostDetailData toPostDetailData() {
    return PostDetailData(
      id: id,
      userId: user.id,
      username: user.username,
      profilePictureUrl: user.profilePictureUrl,
      title: title,
      content: content,
      movieTitle: movie.title,
      movieOverview: movie.overview,
      genreIds: movie.genreIds,
      posterPath: movie.posterPath,
      customPosterUrl: customPosterUrl,
      likeCount: likeCount,
      commentCount: commentCount,
      isLiked: isLiked,
    );
  }
}

class SearchPostUser {
  final int id;
  final String username;
  final String? profilePictureUrl;

  const SearchPostUser({
    required this.id,
    required this.username,
    this.profilePictureUrl,
  });

  factory SearchPostUser.fromJson(Map<String, dynamic> json) {
    return SearchPostUser(
      id: json['id'],
      username: json['username'] ?? '',
      profilePictureUrl: json['profile_picture_url'] ?? '',
    );
  }
}

class SearchMovie {
  final int id;
  final int tmdbId;
  final String mediaType;
  final String title;
  final String? overview;
  final String? posterPath;
  final String? backdropPath;
  final String? releaseDate;
  final List<int> genreIds;
  final String? trailerUrl;

  const SearchMovie({
    required this.id,
    required this.tmdbId,
    required this.mediaType,
    required this.title,
    this.overview,
    this.posterPath,
    this.backdropPath,
    this.releaseDate,
    this.genreIds = const [],
    this.trailerUrl,
  });

  factory SearchMovie.fromJson(Map<String, dynamic> json) {
    return SearchMovie(
      id: json['id'],
      tmdbId: json['tmdb_id'],
      mediaType: json['media_type'] ?? 'movie',
      title: json['title'] ?? '',
      overview: json['overview'],
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      releaseDate: json['release_date'],
      genreIds: List<int>.from(json['genre_ids'] ?? []),
      trailerUrl: json['trailer_url'],
    );
  }
}
