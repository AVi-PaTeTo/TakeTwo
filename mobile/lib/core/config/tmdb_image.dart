class TmdbImage {
  static const String _baseUrl = 'https://image.tmdb.org/t/p';

  static String poster(String path) {
    return '$_baseUrl/w780$path';
  }

  static String backdrop(String path) {
    return '$_baseUrl/w1280$path';
  }
}
