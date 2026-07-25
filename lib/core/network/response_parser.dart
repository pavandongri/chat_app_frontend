import 'package:dio/dio.dart';

import '../utils/app_logger.dart';
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

  /// Unwraps a `data` payload that is a JSON array (e.g. friend/search
  /// lists) rather than an object.
  static List<Map<String, dynamic>> list(Response response) {
    final body = response.data;
    if (body is Map<String, dynamic> && body['data'] is List) {
      return (body['data'] as List).cast<Map<String, dynamic>>();
    }
    return const [];
  }

  static AppException mapError(DioException error) {
    AppLogger.logError('ResponseParser.mapError', error, error.stackTrace);

    final body = error.response?.data;
    final serverMessage = (body is Map && body['message'] is String)
        ? body['message'] as String
        : null;

    return AppException(
      statusCode: error.response?.statusCode ?? 0,
      message: serverMessage ?? _fallbackMessage(error),
    );
  }

  /// A user-facing message for failures the backend never got a chance to
  /// describe (unreachable server, timeout, malformed response, ...). Must
  /// never surface `error.message`/`error.toString()` — those carry raw
  /// socket/platform text (e.g. "Failed host lookup: ... errno = -2").
  static String _fallbackMessage(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'The connection timed out. Please try again.';
      case DioExceptionType.connectionError:
        return "Can't reach the server. Check your connection and try again.";
      case DioExceptionType.badCertificate:
        return 'A secure connection could not be established.';
      case DioExceptionType.cancel:
        return 'The request was cancelled.';
      case DioExceptionType.badResponse:
        return 'Something went wrong. Please try again.';
      default:
        return "Can't reach the server. Check your connection and try again.";
    }
  }
}
