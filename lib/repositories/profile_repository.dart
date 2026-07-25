import 'dart:io';

import 'package:dio/dio.dart';

import '../core/network/dio_client.dart';
import '../core/network/response_parser.dart';
import '../models/user.dart';

/// The only layer allowed to call Dio for `/profile`.
class ProfileRepository {
  ProfileRepository(this._dioClient);

  final DioClient _dioClient;

  Future<User> getProfile() async {
    try {
      final response = await _dioClient.dio.get('/profile');
      return User.fromJson(ResponseParser.data(response)!);
    } on DioException catch (e) {
      throw ResponseParser.mapError(e);
    }
  }

  Future<User> updateProfile({
    String? name,
    String? gender,
    String? avatarUrl,
  }) async {
    try {
      final response = await _dioClient.dio.put(
        '/profile',
        data: {'name': ?name, 'gender': ?gender, 'avatarUrl': ?avatarUrl},
      );
      return User.fromJson(ResponseParser.data(response)!);
    } on DioException catch (e) {
      throw ResponseParser.mapError(e);
    }
  }

  Future<User> uploadAvatar(File imageFile) async {
    try {
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.uri.pathSegments.last,
        ),
      });
      final response = await _dioClient.dio.post(
        '/profile/avatar',
        data: formData,
      );
      return User.fromJson(ResponseParser.data(response)!);
    } on DioException catch (e) {
      throw ResponseParser.mapError(e);
    }
  }
}
