import 'package:dio/dio.dart';

import '../storage/secure_storage.dart';

class ApiClient {
  final Dio dio;

  ApiClient(SecureStorage storage)
    : dio = Dio(
        BaseOptions(
          baseUrl: "http://localhost:8000/api/",
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {'Content-Type': 'application/json'},
        ),
      ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await storage.getAccessToken();

          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          handler.next(options);
        },
      ),
    );
  }
}
