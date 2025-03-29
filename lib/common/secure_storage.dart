import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  final _storage = const FlutterSecureStorage();
  final String _accessTokenKey = "accessToken";

  Future<void> setToken(String accessToken) async {
    try {
      await _storage.write(key: _accessTokenKey, value: accessToken);
    } catch (e) {
      throw Exception("Error saving token");
    }
  }

  Future<String?> getToken() async {
    try {
      return await _storage.read(key: _accessTokenKey);
    } catch (e) {
      throw Exception("Error reading token");
    }
  }

  Future<void> clearStorage() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      throw Exception("Error clearing token");
    }
  }
}
