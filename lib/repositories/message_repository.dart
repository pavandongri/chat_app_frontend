import 'package:dio/dio.dart';

import '../core/network/app_exception.dart';
import '../core/network/dio_client.dart';
import '../core/network/response_parser.dart';
import '../core/utils/app_logger.dart';
import '../models/conversation.dart';
import '../models/message.dart';

const _unexpectedErrorMessage = 'Something went wrong. Please try again.';

class ConversationPage {
  const ConversationPage({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
  });

  final List<Message> items;
  final int page;
  final int limit;
  final int total;
}

/// The only layer allowed to call Dio for `/messages*`.
///
/// Note: `GET /messages/:friendId` marks the friend's SENT/DELIVERED
/// messages as SEEN as a server-side side effect of being called at all —
/// there is no separate "mark seen" endpoint, and no endpoint ever
/// transitions a message to DELIVERED (the backend never triggers that
/// transition in Phase 1). So "mark seen" happens implicitly whenever the
/// conversation is fetched — that's why there's no dedicated method for it
/// here.
class MessageRepository {
  MessageRepository(this._dioClient);

  final DioClient _dioClient;

  Future<ConversationPage> getConversation(
    String friendId, {
    required int page,
    required int limit,
  }) async {
    try {
      final response = await _dioClient.dio.get(
        '/messages/$friendId',
        queryParameters: {'page': page, 'limit': limit},
      );
      final data = ResponseParser.data(response)!;
      return ConversationPage(
        items: (data['items'] as List)
            .map((json) => Message.fromJson(json))
            .toList(),
        page: data['page'] as int,
        limit: data['limit'] as int,
        total: data['total'] as int,
      );
    } on DioException catch (e) {
      throw ResponseParser.mapError(e);
    } catch (e, st) {
      AppLogger.logError('MessageRepository', e, st);
      throw const AppException(statusCode: 0, message: _unexpectedErrorMessage);
    }
  }

  Future<List<ConversationSummary>> getConversationSummaries() async {
    try {
      final response = await _dioClient.dio.get('/messages');
      final data = ResponseParser.list(response);
      return data.map(ConversationSummary.fromJson).toList();
    } on DioException catch (e) {
      throw ResponseParser.mapError(e);
    } catch (e, st) {
      AppLogger.logError('MessageRepository', e, st);
      throw const AppException(statusCode: 0, message: _unexpectedErrorMessage);
    }
  }

  Future<Message> sendMessage({
    required String receiverId,
    required String message,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        '/messages',
        data: {'receiverId': receiverId, 'message': message},
      );
      return Message.fromJson(ResponseParser.data(response)!);
    } on DioException catch (e) {
      throw ResponseParser.mapError(e);
    } catch (e, st) {
      AppLogger.logError('MessageRepository', e, st);
      throw const AppException(statusCode: 0, message: _unexpectedErrorMessage);
    }
  }

  Future<Message> editMessage(String messageId, String newMessage) async {
    try {
      final response = await _dioClient.dio.put(
        '/messages/$messageId',
        data: {'message': newMessage},
      );
      return Message.fromJson(ResponseParser.data(response)!);
    } on DioException catch (e) {
      throw ResponseParser.mapError(e);
    } catch (e, st) {
      AppLogger.logError('MessageRepository', e, st);
      throw const AppException(statusCode: 0, message: _unexpectedErrorMessage);
    }
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      await _dioClient.dio.delete('/messages/$messageId');
    } on DioException catch (e) {
      throw ResponseParser.mapError(e);
    } catch (e, st) {
      AppLogger.logError('MessageRepository', e, st);
      throw const AppException(statusCode: 0, message: _unexpectedErrorMessage);
    }
  }
}
