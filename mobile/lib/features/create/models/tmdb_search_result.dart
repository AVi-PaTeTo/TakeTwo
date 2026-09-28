class TmdbSearchResult {
  final int tmdbId;
  final String mediaType;
  final String title;
  final String? posterPath;
  final String? releaseDate;
  final String? overview;

  const TmdbSearchResult({
    required this.tmdbId,
    required this.mediaType,
    required this.title,
    this.posterPath,
    this.releaseDate,
    this.overview,
  });

  factory TmdbSearchResult.fromJson(Map<String, dynamic> json) {
    return TmdbSearchResult(
      tmdbId: json['id'] as int,
      mediaType: json['media_type'] as String? ?? 'movie',
      title: json['title'] as String? ?? json['name'] as String? ?? 'Unknown',
      posterPath: json['poster_path'] as String?,
      releaseDate:
          json['release_date'] as String? ?? json['first_air_date'] as String?,
      overview: json['overview'] as String?,
    );
  }
}
