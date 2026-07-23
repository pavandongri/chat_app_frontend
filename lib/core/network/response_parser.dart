import 'package:dio/dio.dart';

import 'app_exception.dart';

/// Unwraps the backend's `{ success, message, data }` envelope. Repositories
/// must go through this instead of reaching into `response.data` directly.
class ResponseParser {
  ResponseParser._();

  static Map<String, dynamic>? data(Response response) {
    final body = response.data;
    if (body is Map<String, dynamic> && body['data'] is Map<String, dynamic>) {
      return body['data'] as Map<String, dynamic>;
    }
    return null;
  }

  static AppException mapError(DioException error) {
    final body = error.response?.data;
    final message = (body is Map && body['message'] is String)
        ? body['message'] as String
        : error.message ?? 'Something went wrong. Please try again.';

    return AppException(
      statusCode: error.response?.statusCode ?? 0,
      message: message,
    );
  }
}
