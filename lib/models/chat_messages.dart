import 'package:divertidachat/models/models.dart';

class ChatMessages {
  final String chatId;
  final String chatName;
  final List<Message> messages;

  ChatMessages({
    required this.chatId,
    required this.chatName,
    required this.messages,
  });

  static ChatMessages fromJson(Map<String, dynamic> json) {
    return ChatMessages(
      chatId: json['chat_id'],
      chatName: json['chat_name'],
      messages: (json['messages'] as List)
          .map((message) => Message.fromJson(message))
          .toList(),
    );
  }
}
