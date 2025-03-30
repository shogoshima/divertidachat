import 'package:divertidachat/common/secure_storage.dart';
import 'package:divertidachat/models/models.dart';
import 'package:divertidachat/services/services.dart';

class ChatService {
  final ApiService api;

  ChatService(this.api);

  Future<Map<String, ChatMessages>> getChats() async {
    final storage = SecureStorage();
    final token = await storage.getToken();
    if (token == null) {
      throw Exception('No token found');
    }

    final data = await api.get('/chats', token);
    if (data == null) {
      throw Exception('Failed to load chats');
    }

    final Map<String, ChatMessages> chats = {};
    for (var chat in data['chats']) {
      final chatMessages = ChatMessages.fromJson(chat);
      chats[chatMessages.chatId] = chatMessages;
    }

    return chats;
  }

  Future<Chat> createChat(String username) async {
    final storage = SecureStorage();
    final token = await storage.getToken();
    if (token == null) {
      throw Exception('No token found');
    }

    final data = await api.post('/chats/$username', {}, token);
    if (data == null) {
      throw Exception('Failed to create chat');
    }

    return Chat.fromJson(data['chat']);
  }
}
