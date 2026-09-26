import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  final FlutterSecureStorage storage;

  const SecureStorage() : storage = const FlutterSecureStorage();

  Future<void> saveAccessToken(String token) {
    return storage.write(key: 'access_token', value: token);
  }

  Future<String?> getAccessToken() {
    return storage.read(key: 'access_token');
  }

  Future<void> deleteAccessToken() {
    return storage.delete(key: 'access_token');
  }
}
