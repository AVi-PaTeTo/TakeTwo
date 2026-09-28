class Movie {
  final int id;
  final int tmdbId;
  final String mediaType;
  final String title;
  final String overview;
  final String posterPath;
  final String backdropPath;
  final String releaseDate;
  final List<int> genreIds;
  final String trailerUrl;

  const Movie({
    required this.id,
    required this.tmdbId,
    required this.mediaType,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.releaseDate,
    required this.genreIds,
    required this.trailerUrl,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] as int,
      tmdbId: json['tmdb_id'] as int,
      mediaType: json['media_type'] as String? ?? 'movie',
      title: json['title'] as String? ?? '',
      overview: json['overview'] as String? ?? '',
      posterPath: json['poster_path'] as String? ?? '',
      backdropPath: json['backdrop_path'] as String? ?? '',
      releaseDate: json['release_date'] as String? ?? '',
      genreIds: (json['genre_ids'] as List<dynamic>? ?? [])
          .map((e) => e as int)
          .toList(),
      trailerUrl: json['trailer_url'] as String? ?? '',
    );
  }
}
