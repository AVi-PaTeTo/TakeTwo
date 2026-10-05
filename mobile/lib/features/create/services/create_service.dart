import 'dart:io';

import 'package:dio/dio.dart';


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
    File? bannerImage,
    File? posterImage,
  }) async {
    // Construct FormData to combine text data and the file attachment
    final formData = FormData.fromMap({
      'movie_id': movieId,
      'title': title,
      'content': content,
      if (bannerImage != null)
        'banner_image': await MultipartFile.fromFile(
          bannerImage.path,
          filename: bannerImage.path.split('/').last,
        ),
      if (posterImage != null)
        'poster_image': await MultipartFile.fromFile(
          posterImage.path,
          filename: posterImage.path.split('/').last,
        ),
    });

    final response = await apiClient.dio.post('posts/create/', data: formData);

    return response.data;
  }
}
