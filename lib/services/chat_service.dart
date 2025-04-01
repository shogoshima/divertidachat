import 'package:divertidachat/common/date_time_storage.dart';
import 'package:divertidachat/common/secure_storage.dart';
import 'package:divertidachat/models/models.dart';
import 'package:divertidachat/services/services.dart';

class ChatService {
  final ApiService api;

  ChatService(this.api);

  Future<Map<String, ChatDetails>> getAllUpdatedChats(
      List<String> chatIds) async {
    if (chatIds.isEmpty) {
      return {};
    }

    final storage = SecureStorage();
    final token = await storage.getToken();
    if (token == null) {
      throw Exception('No token found');
    }

    // Get the last updated timestamp from storage.
    DateTime? sentAfter =
        await DateTimeStorage.getLastUpdatedTimestamp() ?? DateTime(1900, 1, 1);

    // Build query parameters. Our `get` method will handle converting list values properly.
    final queryParams = {
      'chat_ids': chatIds,
      'sent_after': sentAfter.toUtc().toIso8601String(),
    };

    // Pass the endpoint, query parameters, and token.
    final data = await api.get('/chats/', token, queryParams);
    if (data == null) {
      throw Exception('Failed to load chats');
    }

    final Map<String, ChatDetails> chats = {};
    if (data['chats'] == null) {
      return chats;
    }

    for (var chat in data['chats']) {
      final chatDetails = ChatDetails.fromJson(chat);
      chats[chatDetails.chatId] = chatDetails;
    }

    return chats;
  }

  Future<ChatDetails> getSingleUpdatedChat(
      String chatId, DateTime sentAfter) async {
    final storage = SecureStorage();
    final token = await storage.getToken();
    if (token == null) {
      throw Exception('No token found');
    }

    // Build query parameters. Our `get` method will handle converting list values properly.
    final queryParams = {
      'sent_after': sentAfter.toUtc().toIso8601String(),
    };

    // Pass the endpoint, query parameters, and token.
    final data = await api.get('/chats/$chatId', token, queryParams);
    if (data == null) {
      throw Exception('Failed to load chats');
    }

    return ChatDetails.fromJson(data['chat']);
  }

  Future<List<ChatTimestamp>> getTimestamps() async {
    final storage = SecureStorage();
    final token = await storage.getToken();
    if (token == null) {
      throw Exception('No token Found');
    }

    final data = await api.get('/chats/timestamps', token);
    if (data == null) {
      throw Exception('Could not fetch updated timestamps');
    }

    List<ChatTimestamp> timestamps = [];
    if (data['timestamps'] == null) {
      return timestamps;
    }

    for (var timestamp in data['timestamps']) {
      final chatTimestamp = ChatTimestamp.fromJson(timestamp);
      timestamps.add(chatTimestamp);
    }

    return timestamps;
  }

  Future<ChatDetails> createChat(String username) async {
    final storage = SecureStorage();
    final token = await storage.getToken();
    if (token == null) {
      throw Exception('No token found');
    }

    final data = await api.post('/chats/$username', {}, token);
    if (data == null) {
      throw Exception('Failed to create chat');
    }

    return ChatDetails.fromJson(data['chat']);
  }
}
