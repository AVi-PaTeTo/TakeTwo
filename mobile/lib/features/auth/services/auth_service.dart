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
}
