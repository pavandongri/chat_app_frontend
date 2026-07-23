import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/network/dio_client.dart';
import '../core/services/secure_storage_service.dart';
import '../core/services/shared_preferences_service.dart';

/// Overridden in `main.dart` with the resolved [SharedPreferences] instance
/// before `runApp`.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider not overridden'),
);

final secureStorageProvider = Provider<FlutterSecureStorage>(
  (ref) => const FlutterSecureStorage(),
);

final secureStorageServiceProvider = Provider<SecureStorageService>(
  (ref) => SecureStorageService(ref.watch(secureStorageProvider)),
);

final sharedPreferencesServiceProvider = Provider<SharedPreferencesService>(
  (ref) => SharedPreferencesService(ref.watch(sharedPreferencesProvider)),
);

final dioClientProvider = Provider<DioClient>(
  (ref) => DioClient(ref.watch(secureStorageServiceProvider)),
);
