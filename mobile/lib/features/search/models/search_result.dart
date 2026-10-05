class MovieSearchResult {
  final int id;
  final int tmdbId;
  final String mediaType;
  final String title;
  final String? overview;
  final String? posterPath;
  final String? backdropPath;
  final String? releaseDate;
  final List<dynamic> genreIds;
  final String? trailerUrl;

  MovieSearchResult({
    required this.id,
    required this.tmdbId,
    required this.mediaType,
    required this.title,
    this.overview,
    this.posterPath,
    this.backdropPath,
    this.releaseDate,
    required this.genreIds,
    this.trailerUrl,
  });

  factory MovieSearchResult.fromJson(Map<String, dynamic> json) {
    return MovieSearchResult(
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
