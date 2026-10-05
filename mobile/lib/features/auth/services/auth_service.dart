import 'dart:io';

import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage.dart';
import '../models/user.dart';
import '../models/genre.dart';

class AuthService {
  final ApiClient apiClient;
  final SecureStorage storage;

  AuthService({required this.apiClient, required this.storage});

  Future<User> login({
    required String username,
    required String password,
  }) async {
    final response = await apiClient.dio.post(
      'auth/login/',
      data: {'username': username, 'password': password},
      // data: {'username': 'Abhi', 'password': 'password123'},
    );

    await storage.saveAccessToken(response.data['access']);

    return getMe();
  }

  Future<User> getMe() async {
    final response = await apiClient.dio.get('auth/me/');

    return User.fromJson(response.data);
  }

  Future<void> logout() async {
    await storage.deleteAccessToken();
  }

  Future<void> register({
    required String username,
    required String email,
    required String password,
    required List<int> preferredGenres,
  }) async {
    await apiClient.dio.post(
      'auth/register/',
      data: {
        'username': username,
        'email': email,
        'password': password,
        'preferred_genres': preferredGenres,
      },
    );
  }

  Future<List<Genre>> getGenres() async {
    final response = await apiClient.dio.get('movies/genres/');

    return (response.data as List).map((json) => Genre.fromJson(json)).toList();
  }

  Future<void> updateProfile({
    String? username,
    List<int>? preferredGenres,
    File? profilePicture,
    File? bannerPicture,
  }) async {
    try {
      // Build FormData for multipart/form-data upload
      FormData formData = FormData();

      if (username != null && username.isNotEmpty) {
        formData.fields.add(MapEntry('username', username));
      }

      if (preferredGenres != null) {
        for (var genreId in preferredGenres) {
          formData.fields.add(MapEntry('preferred_genres', genreId.toString()));
        }
      }

      if (profilePicture != null) {
        formData.files.add(
          MapEntry(
            'profile_picture',
            await MultipartFile.fromFile(profilePicture.path),
          ),
        );
      }

      if (bannerPicture != null) {
        formData.files.add(
          MapEntry(
            'banner_picture',
            await MultipartFile.fromFile(bannerPicture.path),
          ),
        );
      }

      // Send request to your Django backend
      await apiClient.dio.patch('/auth/profile/update/', data: formData);
    } catch (e) {
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }
}
