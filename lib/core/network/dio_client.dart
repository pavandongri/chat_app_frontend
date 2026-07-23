import 'package:dio/dio.dart';

import '../constants/app_constants.dart';
import '../services/secure_storage_service.dart';

/// The single shared Dio instance for the app. Feature repositories consume
/// this via `dioProvider` and must never instantiate their own `Dio()`.
class DioClient {
  DioClient(this._secureStorageService) : dio = Dio(
          BaseOptions(
            baseUrl: ApiConstants.baseUrl,
            connectTimeout: ApiConstants.connectTimeout,
            receiveTimeout: ApiConstants.receiveTimeout,
            contentType: 'application/json',
          ),
        ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _secureStorageService.readAuthToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  final Dio dio;
  final SecureStorageService _secureStorageService;
}
