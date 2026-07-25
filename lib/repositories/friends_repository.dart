import 'package:dio/dio.dart';

import '../core/network/dio_client.dart';
import '../core/network/response_parser.dart';
import '../models/friend.dart';
import '../models/friend_request.dart';
import '../models/public_user.dart';

/// The only layer allowed to call Dio for `/users/search` and `/friends*`.
class FriendsRepository {
  FriendsRepository(this._dioClient);

  final DioClient _dioClient;

  Future<List<PublicUser>> searchUsers(String name) async {
    try {
      final response = await _dioClient.dio.get(
        '/users/search',
        queryParameters: {'name': name},
      );
      final data = ResponseParser.list(response);
      return data.map((json) => PublicUser.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ResponseParser.mapError(e);
    }
  }

  Future<String> sendFriendRequest(String receiverId) async {
    try {
      final response = await _dioClient.dio.post(
        '/friends/request',
        data: {'receiverId': receiverId},
      );
      return ResponseParser.data(response)!['id'] as String;
    } on DioException catch (e) {
      throw ResponseParser.mapError(e);
    }
  }

  Future<List<Friend>> getFriends() async {
    try {
      final response = await _dioClient.dio.get('/friends');
      final data = ResponseParser.list(response);
      return data.map((json) => Friend.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ResponseParser.mapError(e);
    }
  }

  Future<({List<FriendRequest> incoming, List<FriendRequest> outgoing})>
  getFriendRequests() async {
    try {
      final response = await _dioClient.dio.get('/friends/requests');
      final data = ResponseParser.data(response)!;
      return (
        incoming: (data['incoming'] as List)
            .map((json) => FriendRequest.fromJson(json))
            .toList(),
        outgoing: (data['outgoing'] as List)
            .map((json) => FriendRequest.fromJson(json))
            .toList(),
      );
    } on DioException catch (e) {
      throw ResponseParser.mapError(e);
    }
  }

  Future<void> acceptRequest(String requestId) async {
    try {
      await _dioClient.dio.post(
        '/friends/accept',
        data: {'requestId': requestId},
      );
    } on DioException catch (e) {
      throw ResponseParser.mapError(e);
    }
  }

  Future<void> rejectRequest(String requestId) async {
    try {
      await _dioClient.dio.post(
        '/friends/reject',
        data: {'requestId': requestId},
      );
    } on DioException catch (e) {
      throw ResponseParser.mapError(e);
    }
  }

  Future<void> cancelRequest(String requestId) async {
    try {
      await _dioClient.dio.delete(
        '/friends/cancel',
        data: {'requestId': requestId},
      );
    } on DioException catch (e) {
      throw ResponseParser.mapError(e);
    }
  }
}
