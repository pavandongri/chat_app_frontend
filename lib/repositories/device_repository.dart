import 'package:dio/dio.dart';

import '../core/network/app_exception.dart';
import '../core/network/dio_client.dart';
import '../core/network/response_parser.dart';
import '../core/utils/app_logger.dart';

const _unexpectedErrorMessage = 'Something went wrong. Please try again.';

/// The only layer allowed to call Dio for `/devices*` (FCM token
/// registration for push notifications).
class DeviceRepository {
  DeviceRepository(this._dioClient);

  final DioClient _dioClient;

  Future<void> registerToken({
    required String token,
    required String platform,
  }) async {
    try {
      await _dioClient.dio.post(
        '/devices/register',
        data: {'token': token, 'platform': platform},
      );
    } on DioException catch (e) {
      throw ResponseParser.mapError(e);
    } catch (e, st) {
      AppLogger.logError('DeviceRepository', e, st);
      throw const AppException(statusCode: 0, message: _unexpectedErrorMessage);
    }
  }

  Future<void> unregisterToken(String token) async {
    try {
      await _dioClient.dio.delete('/devices/register', data: {'token': token});
    } on DioException catch (e) {
      throw ResponseParser.mapError(e);
    } catch (e, st) {
      AppLogger.logError('DeviceRepository', e, st);
      throw const AppException(statusCode: 0, message: _unexpectedErrorMessage);
    }
  }
}
