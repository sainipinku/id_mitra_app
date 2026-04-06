import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserSecureStorage {
  static const _storage = FlutterSecureStorage();

  static const _keyToken = 'token';
  static const _keyRole = 'role';

  static Future setToken(String token) async {
    await _storage.write(key: _keyToken, value: token);
  }

  static Future<String?> fetchToken() async {
    return await _storage.read(key: _keyToken);
  }

  static Future setRole(String role) async {
    await _storage.write(key: _keyRole, value: role);
  }

  static Future<String?> fetchRole() async {
    return await _storage.read(key: _keyRole);
  }

  static Future deleteAll() async {
    await _storage.deleteAll();
  }
}