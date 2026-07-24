import 'package:dio/dio.dart';

import '../core/network/dio_client.dart';
import '../core/network/response_parser.dart';
import '../models/user.dart';

/// The only layer allowed to call Dio for auth. `AuthController` orchestrates
/// these calls and owns session state; this class just talks to the API.
class AuthRepository {
  AuthRepository(this._dioClient);

  final DioClient _dioClient;

  Future<User> signup({
    required String username,
    required String name,
    required String gender,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        '/auth/signup',
        data: {
          'username': username,
          'name': name,
          'gender': gender,
          'email': email,
          'password': password,
        },
      );
      return User.fromJson(ResponseParser.data(response)!);
    } on DioException catch (e) {
      throw ResponseParser.mapError(e);
    }
  }

  Future<void> verifyEmail({required String email, required String otp}) async {
    try {
      await _dioClient.dio.post(
        '/auth/verify-email',
        data: {'email': email, 'otp': otp},
      );
    } on DioException catch (e) {
      throw ResponseParser.mapError(e);
    }
  }

  Future<void> resendOtp({required String email}) async {
    try {
      await _dioClient.dio.post('/auth/resend-otp', data: {'email': email});
    } on DioException catch (e) {
      throw ResponseParser.mapError(e);
    }
  }

  Future<({User user, String token})> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      final data = ResponseParser.data(response)!;
      return (
        user: User.fromJson(data['user'] as Map<String, dynamic>),
        token: data['token'] as String,
      );
    } on DioException catch (e) {
      throw ResponseParser.mapError(e);
    }
  }

  Future<void> forgotPassword({required String email}) async {
    try {
      await _dioClient.dio.post(
        '/auth/forgot-password',
        data: {'email': email},
      );
    } on DioException catch (e) {
      throw ResponseParser.mapError(e);
    }
  }

  Future<void> verifyResetOtp({
    required String email,
    required String otp,
  }) async {
    try {
      await _dioClient.dio.post(
        '/auth/verify-reset-otp',
        data: {'email': email, 'otp': otp},
      );
    } on DioException catch (e) {
      throw ResponseParser.mapError(e);
    }
  }

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      await _dioClient.dio.post(
        '/auth/reset-password',
        data: {'email': email, 'otp': otp, 'newPassword': newPassword},
      );
    } on DioException catch (e) {
      throw ResponseParser.mapError(e);
    }
  }

  Future<void> logout() async {
    try {
      await _dioClient.dio.post('/auth/logout');
    } on DioException catch (e) {
      throw ResponseParser.mapError(e);
    }
  }
}
