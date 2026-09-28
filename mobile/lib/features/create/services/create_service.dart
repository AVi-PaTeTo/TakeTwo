import '../models/movie.dart';
import '../models/tmdb_search_result.dart';

class CreateService {
  final dynamic apiClient;

  CreateService({required this.apiClient});

  Future<List<TmdbSearchResult>> searchMedia({
    required String query,
    required String type,
  }) async {
    final response = await apiClient.dio.get(
      'movies/search/',
      queryParameters: {'query': query, 'type': type},
    );

    final data = response.data;

    final results = data is List
        ? data
        : (data['results'] as List<dynamic>? ?? []);

    return results
        .map((json) => TmdbSearchResult.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<Movie> getOrCreateMovie({
    required int tmdbId,
    required String type,
  }) async {
    final response = await apiClient.dio.get(
      'movies/$tmdbId/',
      queryParameters: {'type': type},
    );

    return Movie.fromJson(response.data as Map<String, dynamic>);
  }

  Future<dynamic> createPost({
    required int movieId,
    required String title,
    required String content,
  }) async {
    final response = await apiClient.dio.post(
      'posts/create/',
      data: {'movie_id': movieId, 'title': title, 'content': content},
    );
    return response.data;
  }
}
