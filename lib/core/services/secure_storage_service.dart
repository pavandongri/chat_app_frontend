import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/app_constants.dart';

/// Wraps [FlutterSecureStorage] for JWT persistence. This is the only place
/// the auth token is read/written from.
class SecureStorageService {
  SecureStorageService(this._storage);

  final FlutterSecureStorage _storage;

  Future<String?> readAuthToken() => _storage.read(key: StorageKeys.authToken);

  Future<void> writeAuthToken(String token) =>
      _storage.write(key: StorageKeys.authToken, value: token);

  Future<void> deleteAuthToken() => _storage.delete(key: StorageKeys.authToken);
}
