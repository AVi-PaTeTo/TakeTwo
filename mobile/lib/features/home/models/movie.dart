class Movie {
  final int id;
  final int tmdbId;
  final String mediaType;
  final String title;
  final String overview;
  final String posterPath;
  final String backdropPath;
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
    required this.genreIds,
    required this.trailerUrl,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      tmdbId: json['tmdb_id'],
      mediaType: json['media_type'],
      title: json['title'],
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'] ?? '',
      backdropPath: json['backdrop_path'] ?? '',
      genreIds: List<int>.from(json['genre_ids'] ?? []),
      trailerUrl: json['trailer_url'] ?? '',
    );
  }
}
